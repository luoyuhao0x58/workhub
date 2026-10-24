# workhub

基于 `debian:13-slim` 的开发环境容器镜像，内置完整的开发工具链、运维工具。单用户模型，可以当远程开发机用，也可以当 AI Agent 的执行机用。

## 项目做什么

用 Docker 起一个开箱即用的开发环境：

- 系统：debian:13-slim 环境、GMT+8 时区、sudo 免密
- 开发工具：git、zsh、vim、tmux、ssh、python、node、golang、java、rust、ruby、php、playwright
- 运维工具：docker-cli、kubectl、mysql、mongosh、postgresql、redis、sqlite
- agent 工具：openspec、pi
- 单用户 agent（uid/gid 1000），supervisord 托管 sshd 等常驻服务

镜像构建和发布的代码逻辑见 [docs/devops.md](docs/devops.md)。

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
```

### 2. 启动

```bash
docker compose up -d
```

### 3. 进入容器

```bash
docker compose exec -it devops zsh
```


### 可选：本地覆盖配置

可参考[官方文档](https://docs.docker.com/compose/how-tos/multiple-compose-files/merge/)自行编写 `compose.override.yml` ，用来挂载 docker.sock、个人代码目录等，按需自行创建即可。
