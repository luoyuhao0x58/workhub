# workhub

两个容器，一台当远程开发机，一台当浏览器里的桌面。

- **devops**：`debian:13-slim` 开发环境，内置完整工具链和运维工具，纯命令行，可以当远程开发机，也可以当 AI Agent 的执行机。
- **desktop**：`fedora:44` 桌面环境，labwc + selkies，浏览器打开就是一台能用的桌面。

两边用户名、uid/gid、home 路径一致（`agent` / 1000 / `/mnt/workspace`），数据各自独立。

## devops

### 项目做什么

用 Docker 起一个开箱即用的开发环境：

- 系统：debian:13-slim 环境、GMT+8 时区、sudo 免密
- 开发工具：git、zsh、vim、tmux、ssh、python、node、golang、java、rust、ruby、php、playwright
- 运维工具：docker-cli、kubectl、mysql、mongosh、postgresql、redis、sqlite
- agent 工具：openspec、pi
- 单用户 agent（uid/gid 1000），supervisord 托管 sshd 等常驻服务

镜像构建和发布的代码逻辑见 [docs/devops.md](docs/devops.md)。

## desktop

浏览器访问的远程桌面：Wayland 合成器（labwc）+ Selkies 流服务 + PipeWire 音频，状态栏、启动器、通知、截图、剪贴板历史齐全，预装终端、文件管理器、浏览器。图形会话随容器启动，不需要手动拉。

```bash
docker compose up -d desktop
# 浏览器打开 http://localhost:1121，用户名 agent
```

密码看 `GUI_AUTH_PASSWORD`；没设就读容器里的 `~/.config/selkies/auth`（首次启动随机生成并持久化）。

构建、认证、排障、国内源这些细节见 [docs/desktop.md](docs/desktop.md)。

## 怎么用

### 前置

本机装好 Docker 和 Docker Compose。

### 1. 配置 .env

`.env` 不入库（见 `.gitignore`），首次使用自己建一份：

```bash
touch .env
```

内容如下：

```dotenv
# 用哪个镜像。可用 ghcr 上预构建的镜像。
DEVOPS_IMAGE=ghcr.io/luoyuhao0x58/devops
DESKTOP_IMAGE=ghcr.io/luoyuhao0x58/desktop
```

### 2. 启动

```bash
docker compose up -d            # 两个都起
docker compose up -d devops     # 只要命令行环境
docker compose up -d desktop    # 只要桌面
```

### 3. 进入容器

```bash
docker compose exec -it devops zsh
docker compose exec -it desktop bash
```


### 可选：本地覆盖配置

可参考[官方文档](https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/)自行编写 `compose.override.yml` ，用来挂载 docker.sock、个人代码目录等，按需自行创建即可。
