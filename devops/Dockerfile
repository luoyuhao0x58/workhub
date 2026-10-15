FROM debian:13-slim
ARG DEBIAN_FRONTEND=noninteractive

COPY --from=shinsenter/su-exec:latest \
  --chown=root:root --chmod=0755 \
  /su-exec /usr/local/sbin/su-exec

ARG BUILD_UID=1000
ARG BUILD_GID=1000
ARG BUILD_USER_NAME=agent
ARG BUILD_GROUP_NAME=devops
ARG BUILD_USER_HOME=/mnt/workspace

ARG BUILD_LANG=zh_CN.UTF-8
ARG BUILD_TZ=Etc/GMT-8

COPY ./build/install-base-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /home/*/.cache \
  && rm -rf /tmp/*


COPY ./build/install-dev-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /home/*/.cache \
  && rm -rf /tmp/*


ARG BUILD_DOCKER_GID=991
COPY ./build/install-ops-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /home/*/.cache \
  && rm -rf /tmp/*


ARG BUILD_OPENSPEC_VERSION=latest
ARG BUILD_PI_VERSION=latest
COPY ./build/install-agent-tools /tmp/build
RUN cd /tmp/build \
  && ./install.sh \
  && apt clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /home/*/.cache \
  && rm -rf /tmp/*


COPY ./entrypoint.sh /.entrypoint.sh
WORKDIR ${BUILD_USER_HOME}
ENTRYPOINT ["/.entrypoint.sh"]
USER ${BUILD_USER_NAME}
