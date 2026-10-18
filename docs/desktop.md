# desktop 服务

桌面容器：浏览器打开就是一台 Fedora 桌面。和 devops 是"同一个用户的另一台机器"——用户名、uid、home 路径完全一致，数据各管各的。

这份文档讲怎么构建、怎么起、怎么用，以及踩过的坑。

## 为什么单独一个容器

devops 只做命令行。桌面要合成器、音频栈、浏览器，塞进 devops 意味着只写代码的人也要背一身图形依赖，镜像从 1.x GB 涨到 4 GB 出头。拆开之后两个镜像各自升级、各自发布，坏人只能碰到其中一个。

代价是两个容器不共享 home：代码想带进桌面，得在 `compose.override.yml` 里显式挂目录。

## 目录结构

```
desktop/
├── Dockerfile                  # 基础镜像，fedora:44 + 官方源
├── Dockerfile.china            # 国内源变体
├── entrypoint.sh               # 随机密码、.init 钩子、拉起 supervisord
└── build/
    ├── install-base-tools/     # 系统、agent 用户、supervisor、GUI 运行时依赖
    ├── install-desktop-apps/   # foot / nautilus / firefox / imv / mpv / 字体
    ├── install-desktop-shell/  # labwc rc.xml / waybar / fuzzel / mako
    ├── install-selkies/        # pipx 安装 selkies
    ├── install-gui-session/    # 会话 wrapper + supervisord 片段
    └── configure-china-mirrors/  # dnf / pip 国内源
```

四组 install 目录沿用 devops 的模式：一个 `install.sh`，遍历编号子目录里的 `setup.sh`。README 里的思路一样，子目录编号只是排序用。

## 起容器

compose 里已经定义好 `desktop` 服务：

```bash
docker compose up -d desktop
```

默认映射 1121 端口。`.env` 里两个变量可调（`GUI_PORT` 只改宿主机端口，容器内始终是 1121）：

```dotenv
DESKTOP_IMAGE=ghcr.io/luoyuhao0x58/desktop:latest
GUI_PORT=1121
```

宿主数据落在 `${STORE_PATH}/desktop/home`（默认 `.data/desktop/home`），挂到容器的 `/mnt/workspace`。

## 登录

用户名 `agent`。密码二选一：

- 设了 `GUI_AUTH_PASSWORD`，用它；
- 没设，首次启动随机生成 16 位密码，存到 `/mnt/workspace/.config/selkies/auth`（持久卷里，容器重建也不变），同时往会话日志打一条 WARNING。

```bash
docker compose exec desktop cat /mnt/workspace/.config/selkies/auth
# 首次生成时的那条 WARNING（supervisord 的 silent 模式不会把它转到 docker logs）
docker compose exec desktop grep 'generated a random password' /var/log/supervisor/gui-selkies/stderr.log
```

## 桌面里能干什么

合成器是 **labwc**（wlroots）。它在容器里跑 headless 后端（没有 DRM 设备），发布 `wayland-0`，selkies 抓的就是这个输出。

| 组件 | 作用 |
|---|---|
| labwc | 会话合成器：窗口管理、键位、工作区 |
| waybar | 顶部菜单栏：启动项在左、状态与时钟在右（macOS 风格的一条，无按钮块） |
| fuzzel | 动作菜单与应用启动器（键盘驱动，见下） |
| mako | 通知守护进程 |
| fcitx5 | 输入法框架，中文走拼音，`Ctrl+Space` 切换 |
| swaybg | 桌面背景色（`#222731`，不是图片） |

预装应用：foot（终端）、nautilus（文件管理器）、firefox（浏览器）、imv（看图）、mpv（视频）。字体是 Noto CJK + DejaVu + JetBrains Mono + Noto Emoji + Font Awesome。

### 中文输入法

fcitx5 + `fcitx5-chinese-addons`。输入法组里是 `keyboard-us` 和 `pinyin` 两项，**`Ctrl+Space` 切换**，`Shift` 在两者间来回。候选窗是 fcitx5 的经典界面（Qt 绘制，深色）。启动后顶栏右侧会出现一个「拼」字状态图标，点它（或 `Ctrl+Space`）都能切换。

走的是 Wayland 原生输入法协议，不需要给客户端配任何东西：labwc 暴露 `zwp_input_method_v2` 和 `zwp_text_input_v3`，fcitx5 作为输入法服务挂上去，foot、GTK3（Firefox）、GTK4（nautilus）、Qt 全部直接可用。

**`GTK_IM_MODULE` 刻意不设**，这点违反直觉但实测如此：把它设成 `fcitx` 不会让 GTK 更好用，反而会把 GTK4 从原生路径上拽下来，nautilus 然后既没有 preedit 下划线也弹不出候选窗（`fcitx5-remote` 还会把 IM 切成 `keyboard-us`）。去掉之后 nautilus 里搜中文文件名、Firefox 地址栏输中文都正常。只有 `QT_IM_MODULE`（Qt）和 `XMODIFIERS`（Xwayland）还在导出，因为它们没有自己的原生路径。

云拼音默认关闭：它会把正在拼的每个字发到远端换候选词，本地词库够用。要开就改 `~/.config/fcitx5/conf/pinyin.conf` 里的 `CloudPinyinEnabled`。

配置的初始默认值装在 `/etc/xdg/fcitx5/`（`profile` 和 `conf/pinyin.conf`），不是装到家目录。原因很实际：`/mnt/workspace` 是绑定卷，构建阶段往家目录写的东西会被挂载遮掉，静默失效。fcitx5 在用户目录找不到条时会回退到 `/etc/xdg`，读到后**会立刻把结果写回 `~/.config/fcitx5/`**，所以家目录里那几份文件本身就是系统默认值展开出来的，两者不一致时以家目录为准。想让设置回到镜像默认值，删掉 `~/.config/fcitx5/profile` 和 `conf/pinyin.conf` 再重启 fcitx5 就行。


### 快捷键

| 按键 | 动作 |
|---|---|
| `Super+Return` | 终端（foot） |
| `Super+Space` | 应用启动器（fuzzel，全部 `.desktop` 条目） |
| `Super+D` | 动作菜单（终端/文件/浏览器/应用列表/剪贴板历史/截图/退出） |
| `Super+E` | 文件管理器（nautilus） |
| `Super+W` | 浏览器（firefox） |
| `Super+V` | 剪贴板历史 |
| `Print` | 区域截图 |
| `Super+Q` | 关闭当前窗口 |
| `Super+F` | 全屏切换 |
| `Super+M` | 最大化切换 |
| `Super+方向键` | 窗口吸附到屏幕边缘 |
| `Super+Ctrl+→ / ←` | 向右放宽 / 向左收窄窗口 |
| `Super+Ctrl+↓ / ↑` | 向下加高 / 向上压低窗口 |
| `Super+Tab` | 切换到下一个窗口 |
| `Super+1..4` | 切换工作区 |
| `Super+Shift+1..4` | 把当前窗口送到指定工作区 |
| `Super+Shift+R` | 重新加载 labwc 配置 |
| `Ctrl+Space` | 切换中英文输入（fcitx5） |

桌面空白处的左键和右键**都不弹菜单**（Windows 习惯）。原因见下一节：这里的菜单点不动，弹出来反而只能挡住视线、还关不掉。

功能键位（`Super+E`/`W`/`V`）刻意避开 Shift 组合：selkies 注入的虚拟键盘送的是小写 keysym 加 Shift 修饰，labwc 匹配 `W-Shift-f` 这类绑定时并不可靠，实测不触发。写新绑定时优先用单字母。

### 菜单为什么只能用键盘选

**这是本方案唯一的硬伤，知情使用即可。**

selkies 通过 `zwlr_virtual_pointer` 的 absolute motion 注入指针。wlroots（labwc）把它实现成 cursor warp，只产生 `enter`/`leave`，**不产生 `wl_pointer.motion`**。fuzzel、下拉框、列表这些靠 motion 更新悬停项的控件因此收不到指针移动——`wev` 在 labwc 会话里抓到的 `motion` 计数是 **0**。

表现：菜单能弹出来，但高亮永远停在第 1 项，鼠标点哪都没反应。

**labwc 自己的原生菜单也一样**（合成器内部渲染的 root-menu、client-menu）：试过右键调 `ShowMenu root-menu`，弹出 Terminal/Reconfigure/Exit 三项，鼠标点不中，而且它不会自己消失——只能按 Esc 或者重启会话。现在桌面无菜单是靠**空的 `menu.xml`** 实现的：`<openbox_menu>` 里不定义 `root-menu`，继承来的 `ShowMenu root-menu` 找不到目标就成了空操作，同时 `rc.xml` 里把桌面左右键显式绑成 `action name="None"`。

`rc.xml` 的 `<default />` **必须保留**：labwc 靠它维护鼠标按下/释放的配对。删掉之后窗口装饰的**单击会被丢弃、只剩双击生效**（表现为「单击没反应，双击直接把窗口关了」）。这是踩过的坑，别再动它。

用法：`Super+Space`（或 `Super+D`）打开 → 直接打字过滤（`fire`、`foot`）→ 回车。fuzzel 的 `ignore-case=yes` 已开，大小写都能匹配。鼠标点击按钮（waybar、应用内控件）**不受影响**，只有 Wayland 原生菜单的悬停态有问题。

### 为什么最后没用 niri

做过一版完整的 niri 方案，结论是**看起来更好，实际更难用**，已回退。

niri（smithay 合成器）把同样的绝对注入实现成真实指针运动（`wev` 能抓到 42 个 motion 事件），所以它的 Wayland 菜单能正常点到。代价是 **niri 26.04 不给虚拟键盘做路由**：

- 源码里只有 `delegate_virtual_keyboard_manager!(State)`（`src/handlers/mod.rs`），用 smithay 的默认 handler
- 结果：`zwp_virtual_keyboard` 送来的按键被直接转给焦点客户端，绕过 niri 自己的 bind 管线
- 所以 niri 的所有 `binds` 一条都不响应，而 labwc 走 `wlr_seat_keyboard_notify_key`，事件进完整管线，键位正常

用 `wtype`（另一个虚拟键盘客户端）交叉验证过：`Super+Q` 对 labwc 有效、对 niri 完全无效，说明不是 selkies 的问题。上游 main 分支已修（PR #4548 新增 `src/handlers/virtual_keyboard.rs`，显式调用 `process_input_event`），但 v26.04 没有这个文件。

取舍后选择 labwc：**键盘是主力输入方式，鼠标点菜单是次要需求**。菜单改成键盘驱动（本页上一节），换取全部快捷键可用。等 niri 发布带该修复的版本后，如果要换回去，`openspec/changes/archive/` 里那版 niri 实现可以直接参考。

顺带一提，回退还白拿了两件事：画面不用再做 CSS 翻转（labwc 输出方向是对的），窗口有了服务端装饰（标题栏、关闭按钮）。

### 没有桌面图标

labwc 不显示桌面图标。文件管理器从 `Super+E`、状态栏按钮或动作菜单打开。

## 会话管理

和 devops 不同，这里的图形会话**随容器自启**：起 desktop 就是为了用桌面，没必要再手动拉一次。

```bash
docker compose exec desktop supervisorctl status
docker compose exec desktop supervisorctl stop 'gui:*'
docker compose exec desktop supervisorctl start 'gui:*'
```

六个进程按优先级依次起来：`gui-dbus`(5) → `gui-pipewire`(10) → `gui-labwc`(20) → `gui-mako`(25) → `gui-shell`(35) → `gui-selkies`(40)。每个 wrapper 自己等依赖的 socket 就绪（比如 `gui-mako` 会等到 `wayland-0` 出现才启动），所以单个进程重启不会把顺序搞乱。

socket 约定：labwc 发布 `wayland-0`，Xwayland 在 `:0`。这两个值同时写死在镜像 `ENV`、`desktop-session.env` 和各 supervisord 片段里，改一处就要全部同步。

日志在容器内 `/var/log/supervisor/gui-*/`。

## GPU 加速

`labwc` 用 pixman 做合成，这一层始终是软件渲染，不受下面的配置影响；真正走 GPU 的是容器里的客户端应用（浏览器、视频、3D 程序）。把宿主显卡暴露进容器，这部分配置依赖宿主平台，所以**不进仓库的 `compose.yml`**，而是写在本地 `compose.override.yml` 里。

### 原生 Linux（有 `/dev/dri`）

Mesa 会自动认出设备并选用对应驱动（`radeonsi`、`iris`、`nouveau` 等），不需要任何环境变量：

```yaml
# compose.override.yml
services:
  desktop:
    devices:
      - "/dev/dri:/dev/dri"
```

### WSL2（Windows 11）

WSL2 不暴露 `/dev/dri`，GPU 通过 `/dev/dxg`（微软的 DirectX 半虚拟化设备）访问，OpenGL 由 Mesa 的 **`d3d12` gallium 后端**翻译成 DirectX 调用。所以除了设备，还要把 WSL 提供的 D3D12 库目录塞进 `LD_LIBRARY_PATH`，否则 Mesa 找不到 `libd3d12core.so`：

```yaml
# compose.override.yml
services:
  desktop:
    devices:
      - "/dev/dxg:/dev/dxg"
    environment:
      LD_LIBRARY_PATH: "/usr/lib/wsl/lib"
    volumes:
      - "/usr/lib/wsl:/usr/lib/wsl:ro"
```

`GALLIUM_DRIVER=d3d12` 不是必需的——只要库可见，Mesa 会自动挑 d3d12 后端。只有多显卡机器想指定适配器时才需要 `MESA_D3D12_DEFAULT_ADAPTER_NAME=<厂商>`。

### 验证

```bash
# 先装工具（镜像没预装）
docker compose exec -u root desktop dnf install -y glx-utils

# 看渲染器
docker compose exec desktop bash -lc 'glxinfo -B | grep "OpenGL renderer"'
```

- 输出形如 `D3D12 (AMD Radeon(TM) 890M Graphics)` 或 `AMD Radeon 780M (radeonsi, ...)` → 硬件
- 输出 `llvmpipe (LLVM ..., 256 bits)` → 仍是软件渲染，设备或库路径没接上

再量一下帧率（`vblank_mode=0` 关掉垂直同步）：

```bash
docker compose exec desktop bash -lc 'vblank_mode=0 glxgears'
```

### 两个平台的差异

| | 原生 Linux | WSL2 |
|---|---|---|
| 设备节点 | `/dev/dri/card0`、`renderD128` | `/dev/dxg` |
| Mesa 驱动 | 原生（`radeonsi` / `iris` / `nouveau`） | `d3d12` gallium 后端 |
| 额外依赖 | 无 | `LD_LIBRARY_PATH=/usr/lib/wsl/lib` + `/usr/lib/wsl` 挂载 |
| 缺少时的表现 | 软件渲染 | 软件渲染 |

容器镜像本身不含任何平台判断代码，两种平台跑的是同一个镜像。

一层的画面编码（selkies）目前仍是 CPU。镜像里带了 Mesa 的 `d3d12_drv_video.so`（VA-API over D3D12），理论上编码也能走硬件，但没有验证过。

## 国内源

`Dockerfile.china` 在基础镜像上把 dnf 和 pip 切到 aliyun，产出日期 tag（和 devops 的约定一致）。

本地在境内构建基础镜像时，官方源会慢到不可用，用 build-arg 直接加速：

```bash
docker build -t desktop:latest \
  --build-arg DNF_MIRROR=https://mirrors.aliyun.com/fedora \
  ./desktop
```

注意两件事：

- 国内镜像没有 `fedora-cisco-openh264` 仓库，脚本会自动 `enabled=0`，否则 dnf 直接报 "No valid source" 失败；
- 不再需要 `dnf makecache`，切源后一次装完即可。

## 排障

**画面黑屏 / 连不上**

先看 `docker compose logs desktop`，再看容器内 `/var/log/supervisor/gui-selkies/stderr.log`。如果日志显示 `Selkies server running on http://127.0.0.1:1121`，说明 `--public` 参数没生效，端口映射连不进去。

**没声音**

```bash
docker compose exec desktop bash -lc 'pw-cli ls Node | grep node.description'
```

有 `Dummy Output` 就说明 PipeWire 起来了；再试 `pw-play /path/to.wav` 看是否返回 0。如果日志里有 `pcmflux library not found`，是缺 `libICE`/`libSM`。

镜像里没有 `pactl`（那是 `pulseaudio-utils` 包），要按 PulseAudio 客户端排障就自己装一个。

**桌面应用报连不上 wayland**

```bash
docker compose exec desktop bash -lc 'echo $XDG_RUNTIME_DIR $WAYLAND_DISPLAY; ls /tmp/runtime-agent/wayland-0'
```

`desktop-session.env` 没生效时，手动 source 一遍即可（`.bashrc` 会自动加载）。

**输入法打不出中文**

先看 fcitx5 有没有接上合成器：

```bash
docker compose exec desktop bash -lc 'grep -E "Failed to open wayland|native input method protocol" /var/log/supervisor/gui-fcitx5/stderr.log | tail -2'
```

期望看到 `Using Wayland native input method protocol: 1`。如果是 `Failed to open wayland connection`，说明 fcitx5 在 labwc 把 socket 建好之前就开始连了——supervisor 的 `priority` 只排 fork 顺序，不等待就绪。镜像里的 `gui-fcitx5-session.sh` 会先等 socket 再 exec，所以正常启动不会碰上；如果手动单独特权重启过 fcitx5 才会复现，再重启一次就好。

如果协议握手正常但某个应用还是打不出中文，**检查有没有多设置 `GTK_IM_MODULE`**。强迫 GTK4 走 immodule 会让它失去原生 `text-input-v3` 路径，nautilus 然后既没有 preedit 下划线也弹不出候选窗。正确的状态是 `env | grep GTK_IM_MODULE` 什么都不输出。

**菜单点不动 / 高亮不跟随鼠标**

不是 bug，是 wlroots 的已知限制：绝对指针注入只产生 `enter`/`leave`，没有 `motion`。用键盘选（上下键 + 回车，或直接打字过滤）。详见上文“菜单为什么只能用键盘选”。

**窗口拖边框调不了大小**

拖边框需要持续的指针 `motion` 事件，绝对指针注入给不出来（同“菜单点不动”的根因）。用键盘调：

```text
Super+Ctrl+方向键    按 25px 步进调整对应边
```

`rc.xml` 里的 `ResizeRelative` 只改边缘尺寸，完全不需要指针输入。

**GTK4 应用启动慢（nautilus 等）**

先确认 `GSK_RENDERER`：

```bash
docker compose exec desktop sh -c 'echo $GSK_RENDERER'
# 期望 cairo
```

这个镜像里没有 `/dev/dri`，GPU 只能经 `/dev/dxg` 走 Mesa 的 d3d12 后端。建一个 GL 上下文要将近一秒，而纯 CPU 的 cairo 渲染不需要初始化。实测 nautilus 从启动到首帧（同一台机器，`grim` 轮询抓帧）：

| 渲染器 | 第 1 次 | 第 2 次 | 第 3 次 |
|---|---|---|---|
| 默认（ngl / GL） | 1093 ms | 1046 ms | 1070 ms |
| `cairo`（纯 CPU） | 270 ms | 304 ms | 294 ms |

所以 Dockerfile 里固定了 `ENV GSK_RENDERER=cairo`。**这不影响视频硬解**：selkies 的服务端编码、浏览器的 WebCodecs 解码走的是各自的路径，与 GTK 的渲染器无关；`mpv`、`firefox` 自己做绘制，也不读这个变量。

**文件管理器第一次打开很慢**

`localsearch`（原 tracker）的默认设置是索引整个 `$HOME`，而这里的 home 是数据卷，动辄几十 GB，首次启动时索引器在扫目录树。`gui-shell-session.sh` 每次会话启动都会把两个索引目录设成空：

```bash
gsettings get org.freedesktop.Tracker3.Miner.Files index-recursive-directories
# 期望输出 @as []
```

代价是文件内容全文搜索不可用；按文件名浏览、缩略图、最近的正常。想恢复索引就往里填目录，别填 `$HOME`。

**快捷键没反应**

先确认事件有没有到合成器：

```bash
docker compose exec desktop bash -lc \
  'WAYLAND_DISPLAY=/tmp/runtime-agent/wayland-0 wtype -M logo -k q -m logo'
```

`wtype` 没装就 `dnf install -y wtype`。这条能关掉当前窗口，说明绑定本身没问题，那就是浏览器那边没把按键送到（检查 selkies 页面是否获得焦点）。

labwc 的绑定写在 `/etc/xdg/labwc/rc.xml`，改完 `Super+Shift+R` 重载。配置有语法错误时 labwc 会拒绝加载并保留旧配置，看 `docker compose logs desktop`。

**画面上下颠倒**

labwc 的输出方向是对的，selkies 抓到也是正的（同一时刻 `grim` 抓屏和浏览器画面一致），**不需要任何 CSS 补偿**。之前的翻转补丁只对 niri 有意义，已随 niri 一起删掉。

如果还看到翻转，检查两处：浏览器是不是缓存了旧页面（`Ctrl+Shift+R`），或者容器是不是还在跑带补丁的旧镜像：

```bash
docker compose exec desktop grep -c workhub-flip \
  /opt/pipx/venvs/selkies/lib/python3.14/site-packages/selkies/selkies_web/index.html
```

返回 `0` 才是对的。改成其他值时说明镜像里残留了补丁，重新构建即可。

注意 selkies 启动时会把 web 资源复制到 `/tmp/selkies_web*/`，手工改 `site-packages` 里的文件后必须重启 `gui:gui-selkies` 才生效。

**背景是纯黑**

`swaybg` 没起来。检查 `pgrep -a swaybg` 和 `/var/log/supervisor/gui-shell/`。labwc 正常合成 layer-shell 的 background 层，所以 `swaybg -c '#222731'` 是有效的（换成 niri 时会失效，niri 不合成那一层）。

**D-Bus 报错**

会话同时起了 system bus（`/run/dbus/system_bus_socket`）和 session bus（`/tmp/runtime-agent/bus`）。检查 `DBUS_SESSION_BUS_ADDRESS` 是否指向后者。session bus 必须以 `agent` 身份跑（`su-exec`），用 root 起会让客户端连不上。

**改了 niri 配置不生效**

niri 只读 `~/.config/niri/config.kdl`，镜像默认配置在 `/etc/niri/config.kdl`，由 `gui-niri-session.sh` 在启动时 seed 过去。注意两个坑：

- niri 第一次启动会自己生成一份带 `This config is in the KDL format` 注释的默认配置，它比 `/etc/niri/config.kdl` 优先级高；session 脚本会识别这个特征并覆盖，但你在容器里手改过 `~/.config/niri/config.kdl` 之后，改 `/etc/niri/config.kdl` 就不会再生效。
- 校验语法用 `niri validate -c /etc/niri/config.kdl`（它只读 `-c` 指定的文件，不会去翻 `/etc/xdg`）。输出走 stderr，`grep` 时要带 `2>&1`。

改完重启 niri 生效：`docker compose exec desktop supervisorctl restart gui:gui-niri`。

**会话分辨率怎么调**

目前没有做成参数：`gui-labwc-session.sh` 用 wlroots 的 headless 后端，输出走 wlroots 默认的 1280x720，niri 的 winit 窗口跟随这个尺寸（`niri-config.kdl` 里没有 `output "winit"` 段）。要改得从 labwc 侧下手（headless 输出尺寸），改完确认 niri 窗口跟着变——这条没有验证过，属于待办。

## 已知限制

- **窗口大小和菜单一样依赖键盘**：拖边框改成 `Super+Ctrl+方向键`，原因同上一条指针限制。窗口移动（拖标题栏）是正常的，因为它只需要按下时的一个位置。
- **所有菜单只能用键盘操作**：客户端菜单（fuzzel）和 labwc 原生菜单都一样，因为 wlroots 把 selkies 的绝对指针注入降级成 cursor warp，不产生 `wl_pointer.motion`。桌面左右键都不弹菜单，入口在快捷键和状态栏按钮上。详见“菜单为什么只能用键盘选”。
- **截图框选待真机确认**：点按钮能拉起 `slurp`，`grim` 全屏抓取实测正常，但自动化环境里合成的拖拽没有取到选区。真鼠标按一次就能确认；若确实不行，改成全屏 `grim` 或换 `swappy`。
- **swappy 已装未接线**：镜像里有 `swappy`，但截图脚本存盘后直接返回，没有接标注环节。要用的话手动 `swappy -f <图片>`。
- 单用户、单会话，没有多桌面。
- 1121 是明文 HTTP + basic auth，公网必须套反向代理 + TLS，并转发 WebSocket 升级头。
- Fedora 支持周期约 13 个月，镜像的 `BASE_IMAGE` 参数化，过期就改 ARG 重建。
- 音频、输入、剪贴板依赖 selkies 上游实现，Fedora 上没有官方支持承诺。
