ARG BUILD_UID=1000
ARG BUILD_GID=1000
ARG BUILD_USER_NAME=agent
ARG BUILD_GROUP_NAME=devops
ARG BUILD_USER_HOME=/mnt/workspace
ARG PYTHON27_DEB_IMAGE=ghcr.io/luoyuhao0x58/python:2.7-deb

FROM ${PYTHON27_DEB_IMAGE} AS python27-deb

FROM debian:13-slim AS builder
ARG DEBIAN_FRONTEND=noninteractive
COPY --from=shinsenter/su-exec:latest \
  --chown=root:root --chmod=0755 \
  /su-exec /usr/local/sbin/su-exec
ARG BUILD_UID
ARG BUILD_GID
ARG BUILD_USER_NAME
ARG BUILD_GROUP_NAME
ARG BUILD_USER_HOME
ARG BUILD_LANG=zh_CN.UTF-8
ARG BUILD_TZ=Etc/GMT-8
COPY ./build/install-base-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build
COPY --from=python27-deb /py27.deb /tmp/
COPY ./build/install-dev-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build
ARG BUILD_DOCKER_GID=991
COPY ./build/install-ops-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build
ARG BUILD_OPENSPEC_VERSION=latest
ARG BUILD_PI_VERSION=latest
COPY ./build/install-agent-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && rm -rf /tmp/build
COPY ./entrypoint.sh /.entrypoint.sh
COPY ./build/clean.sh /tmp/clean.sh
RUN /tmp/clean.sh


FROM scratch
COPY --from=builder / /
ARG BUILD_UID
ARG BUILD_USER_HOME
WORKDIR ${BUILD_USER_HOME}
ENTRYPOINT ["/.entrypoint.sh"]
USER ${BUILD_UID}
