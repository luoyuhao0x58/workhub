# devops 镜像构建逻辑

devops 是 workhub 的开发环境镜像，本地用 docker compose 起容器。

本文讲镜像是怎么构建出来的：两个 Dockerfile 的分工、四组安装脚本的模式、容器入口、大陆环境配置，以及 CI 发布流程。

桌面能力不在这个镜像里，由独立的 [desktop](desktop.md) 服务提供。

## 两个镜像的分工

镜像分两层构建：

- **基础镜像**（`devops/Dockerfile`）：官方源构建，干净可复现，适合 CI 这类海外构建环境，发布为 `latest`。
- **中国大陆环境镜像**（`devops/Dockerfile.china`）：在基础镜像之上再跑一段配置，把各类运行时源切到中国大陆可访问的镜像。

中国大陆的网络环境和其他地区不同，部分源不可达或访问很慢，所以单独用一个 Dockerfile 叠一层配置。代码只有一份，两个镜像的差别就是一个配置层，改工具只改一处。

## 目录结构

```
devops/
├── Dockerfile                  # 基础镜像
├── Dockerfile.china            # 中国大陆环境镜像
├── entrypoint.sh               # 容器启动入口
└── build/
    ├── install-base-tools/     # 系统基础：git、zsh、ssh 等
    ├── install-dev-tools/      # 语言工具链：python、node、golang 等
    ├── install-ops-tools/      # 运维工具：docker-cli、kubectl 等
    ├── install-agent-tools/    # agent 工具：openspec、pi
    └── configure-china-mirrors/  # 大陆环境配置，system/ + langs/
```

四组 install 目录是同一个模式：一个 `install.sh`，下面放若干子目录，每个子目录一个 `setup.sh`，分别管一组工具：

- `install-base-tools`：系统基础（git、zsh、ssh、supervisor 等）
- `install-dev-tools`：语言工具链（python、node、golang、java、rust、ruby、php、vscode-server 等）
- `install-ops-tools`：运维工具（docker-cli、kubectl、mysql、mongosh 等）
- `install-agent-tools`：agent 工具（openspec、pi）

子目录名开头的数字编号没有业务含义，只是让 `install.sh` 按顺序执行——它对目录名排序后逐个跑 setup.sh。

## Dockerfile 构建过程

`Dockerfile` 从 `debian:13-slim` 起步，按层构建：

1. 拷入 `su-exec`（来自 shinsenter/su-exec，容器内降权用）。
2. 用 ARG 声明可调参数：uid/gid（默认 1000）、用户名（agent）、组名（devops）、home（/mnt/workspace）、locale（zh_CN.UTF-8）、时区（Etc/GMT-8）、docker 组 gid、openspec 和 pi 的版本。
3. 依次 COPY 四组 install 目录并 RUN 各自的 `install.sh`，每组结束 `apt clean` 并清掉缓存和 `/tmp`，控制镜像体积。
4. COPY `entrypoint.sh`，WORKDIR 设到 `/mnt/workspace`，USER 切到 agent，设置 ENTRYPOINT。

### install.sh 的模式

`install-dev-tools`、`install-ops-tools`、`install-agent-tools` 的 install.sh 是同一套写法：`apt-get update` 后遍历 `./*-*/setup.sh`，逐个进入目录执行。新增工具就是加一个子目录，不需要动 install.sh。

`install-base-tools` 在遍历之前多做两件事：

- 系统级初始化：apt 源开 contrib/non-free 并切 https，装 ca-certificates，配置 locale、时区、history、limits，再装一批基础包（sudo、curl、网络工具等）。
- 创建用户：`groupadd` + `useradd` 建 agent（uid/gid 1000，组 devops，加入 sudo，NOPASSWD），umask 0002，并在用户 `.bashrc` 末尾加上循环 source `~/.bashrc.d/*.sh` 的逻辑。

### 用户模型

镜像里只有一个交互用户 agent（uid/gid 1000，sudo 免密），构建期 home 是 `/mnt/workspace`。各语言工具通过 setup-user.sh 把自己的 bashrc 模板放进 `~/.bashrc.d/`，文件名以语言结尾（如 `*-nodejs.sh`），登录时被统一 source。占位块机制和大陆环境配置都依赖这个目录。

## 容器入口 entrypoint.sh

容器启动时按顺序做：

1. 给 root 和当前用户生成随机密码（chpasswd）。
2. 给 su-exec 设置 setuid 位。
3. 过滤 HOME/USER 等会话环境变量。
4. 用户 home 下有 `.init` 脚本就执行（首次初始化钩子，比如注入 ssh key、clone 代码）。
5. 以 su-exec root 启动 supervisord，托管 sshd 等常驻服务。

## 中国大陆环境配置（Dockerfile.china）

`Dockerfile.china` 本身很薄：`FROM ${BASE_IMAGE}`（基础镜像名用 ARG 参数化，默认 `devops:latest`），切 root，ADD 进 `configure-china-mirrors`，RUN 它的 `install.sh`，清缓存，切回 agent。

配置脚本分两部分：

- `system/*.sh`：写文件的系统级源配置——apt、`/etc/pip.conf`、npm registry、cargo（`/.cargo/config.toml`）、gem。
- `langs/*.sh`：按语言声明环境变量（nodejs 的 `NVM_NODEJS_ORG_MIRROR`、`COREPACK_NPM_REGISTRY`，以及 golang、rust、python、ruby、php 各自的镜像变量），注入到对应的 `~/.bashrc.d/*-<lang>.sh`。

注入逻辑在 `lib.sh`：各语言 bashrc 模板里预留了占位块：

```
# >>> mirrors: <lang> >>>
# <<< mirrors: <lang> <<<
```

`inject_bashrc` 把变量写进这块，重复执行先清旧块再写新块，所以脚本幂等，容器里手动重跑 `install.sh` 也能重新配置。

脚本只覆盖运行时源。构建期用到的下载源（node tarball、k8s/mongosh 的 apt 仓库、php 编译源）容器运行后用不到，不纳入。

## CI 发布

`.github/workflows/build-publish.yml` 手动触发（Actions 页面点 Run workflow），流程：

1. 登录 GHCR（workflow 声明 `packages: write` 权限）。
2. 构建基础镜像，推 `ghcr.io/<owner>/devops:latest`。
3. 算日期 tag：`v$(date +%Y.%-m.%-d)`，月和日不补零（如 `v2026.10.16`、`v2027.1.1`）。
4. 以 `BASE_IMAGE=<镜像>:latest` 构建 `Dockerfile.china`，推日期 tag。

几个细节：

- owner 用 `${{ github.repository_owner }}` 动态解析，仓库迁入组织不用改 workflow。
- workflow 设了 `TZ: Asia/Shanghai`，日期 tag 按东八区算。
- ghcr 包默认 private，首次发布后要在 ghcr 页面手动设为 public 才能被拉取。
- 同一天多次触发，日期 tag 相同，后一次覆盖前一次。

## 本地手动构建

对应 CI 的两步，本地想自己构建：

```bash
# 基础镜像（官方源）
docker build -t devops:latest ./devops

# 中国大陆环境镜像
docker build -t devops:china \
  --build-arg BASE_IMAGE=devops:latest \
  -f ./devops/Dockerfile.china \
  ./devops
```

然后 `.env` 里 `DEVOPS_IMAGE=devops:china` 即可。

桌面环境（labwc + selkies）不在这里，见 [docs/desktop.md](desktop.md)。
