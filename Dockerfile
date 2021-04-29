ARG HELM_VERSION=3.2.4
ARG KUBERNETES_VERSION=1.15.12
ARG ALPINE_VERSION=3.12

FROM "registry.gitlab.com/gitlab-org/cluster-integration/helm-install-image/releases/${HELM_VERSION}-kube-${KUBERNETES_VERSION}-alpine-${ALPINE_VERSION}"

# https://github.com/sgerrand/alpine-pkg-glibc
ARG GLIBC_VERSION=2.31-r0

# Install Dependencies
RUN apk add --no-cache openssl curl tar gzip bash jq \
  && curl -sSL -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
  && curl -sSL -O https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
  && apk add glibc-${GLIBC_VERSION}.apk \
  && apk add ruby jq ruby-json \
  && rm glibc-${GLIBC_VERSION}.apk

COPY src/ build/
COPY assets/ assets/

RUN ln -s /build/bin/* /usr/local/bin/
