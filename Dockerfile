ARG HELM_INSTALL_IMAGE_VERSION=v0.274-helm-3.10.2-kube-1.24.8-alpine-3.15

FROM "registry.gitlab.com/gitlab-org/cluster-integration/helm-install-image:${HELM_INSTALL_IMAGE_VERSION}"

# https://github.com/sgerrand/alpine-pkg-glibc
ARG GLIBC_VERSION=2.31-r0

# Install shared dependencies
RUN apk add --no-cache \
  bash \
  curl \
  gzip \
  jq \
  openssl \
  ruby \
  ruby-json \
  tar

# Install legacy glibc dependency on amd64
RUN curl -sSL -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
      && curl -sSL -O https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
      && apk add glibc-${GLIBC_VERSION}.apk \
      && rm glibc-${GLIBC_VERSION}.apk

COPY src/ build/
COPY assets/ assets/

RUN ln -s /build/bin/* /usr/local/bin/
