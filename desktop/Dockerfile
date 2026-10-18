ARG BASE_IMAGE=fedora:44

FROM ${BASE_IMAGE} AS builder
COPY --from=shinsenter/su-exec:latest \
  --chown=root:root --chmod=0755 \
  /su-exec /usr/local/sbin/su-exec
ARG BUILD_UID=1000
ARG BUILD_GID=1000
ARG BUILD_USER_NAME=agent
ARG BUILD_GROUP_NAME=devops
ARG BUILD_USER_HOME=/mnt/workspace
ARG BUILD_TZ=Etc/GMT-8
# empty = stock Fedora repositories; set it to a mirror URL for domestic builds
ARG DNF_MIRROR=

COPY ./build/install-base-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build

COPY ./build/install-desktop-apps /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build

COPY ./build/install-input-method /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build

COPY ./build/install-desktop-shell /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build

COPY ./build/install-selkies /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build

COPY ./build/install-gui-session /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build

COPY ./entrypoint.sh /.entrypoint.sh
COPY ./build/clean.sh /tmp/clean.sh
RUN chmod 0755 /.entrypoint.sh /tmp/clean.sh \
  && /tmp/clean.sh


FROM scratch
COPY --from=builder / /
ARG BUILD_UID=1000
ARG BUILD_USER_HOME=/mnt/workspace
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Session environment is baked in so `docker compose exec desktop <app>` works
# without sourcing a shell profile first.
ENV LANG=C.UTF-8
# labwc owns the session and publishes wayland-0; :0 is the X display its
# Xwayland takes.
# fcitx5 gets its keyboard events through labwc's zwp_input_method_v2 and the
# clients report through zwp_text_input_v3, so nothing has to be exported for
# Wayland-native toolkits. GTK_IM_MODULE is deliberately left unset: forcing it
# to fcitx removes GTK4 from the native path and nautilus then loses both the
# preedit display and the candidate window (measured). The two below only serve
# clients that have no native path of their own - Qt and Xwayland.
ENV XDG_RUNTIME_DIR=/tmp/runtime-agent \
    WAYLAND_DISPLAY=wayland-0 \
    DISPLAY=:0 \
    DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-agent/bus \
    XDG_CURRENT_DESKTOP=labwc \
    XDG_SESSION_TYPE=wayland \
    QT_IM_MODULE=fcitx \
    XMODIFIERS=@im=fcitx
WORKDIR ${BUILD_USER_HOME}
ENTRYPOINT ["/.entrypoint.sh"]
USER ${BUILD_UID}
