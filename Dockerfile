ARG APP_IMAGE=recommendation
ARG APP_VERSION=1.0.0


FROM quay.io/kameshsampath/${APP_IMAGE}:${APP_VERSION} as app

# TODO move to distroless
FROM docker.io/istio/base:1.11-dev.10

ARG KUBECTL_VERSION=v1.21.5
ARG ISTIO_VERSION=1.11.5
ARG ISTIOD_ADDRESS
ARG ISTIOD_PORT=15012
ARG VM_APP=blue-green-canary
ARG VM_NAMESPACE=vm-blue-green-canary
ARG SERVICE_ACCOUNT=vm-blue-green-canary
ARG CLUSTER_NETWORK=bgc-network1
ARG VM_NETWORK=bgc-vm-network
ARG CLUSTER=cluster1
ARG ISTIO_CLUSTER
ARG VM_WORK_DIR="/var/lib/istio/vm-files"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update

RUN apt install -y apt-file vim wget jq gettext dumb-init

RUN mkdir -p /root/.kube \
    && wget -q https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /bin/kubectl \
    && chmod +x /bin/kubectl \
    && mkdir -p /var/lib/istio/.kube /root/.kube \
    && chown -R istio-proxy /var/lib/istio/.kube \
    && curl -LO https://storage.googleapis.com/istio-release/releases/${ISTIO_VERSION}/deb/istio-sidecar.deb \
    && sudo dpkg -i istio-sidecar.deb

ADD  utils/entrypoint.sh /entrypoint

ADD  utils/vm-setup.sh /usr/local/bin
COPY --from=app /application /usr/local/bin/application
COPY .kube/config /root/.kube/config
COPY --chown=istio-proxy:istio-proxy .kube/config /var/lib/istio/.kube/config

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER istio-proxy

WORKDIR /var/lib/istio
VOLUME VM_WORK_DIR

ENV ISTIO_VERSION=${ISTIO_VERSION}
ENV ISTIO_HOME=/var/lib/istio/istio-${ISTIO_VERSION}
ENV ISTIOD_ADDRESS=${ISTIOD_ADDRESS}
ENV ISTIOD_PORT=${ISTIOD_PORT}
ENV KUBECONFIG=/var/lib/istio/.kube/config

RUN sudo mkdir -p /var/lib/istio/.kube \
    && sudo chown -R istio-proxy:istio-proxy /var/lib/istio/.kube

RUN sudo mkdir -p ${VM_WORK_DIR} \
    && curl -L https://istio.io/downloadIstio | sudo -E sh - \
    && sudo -E /usr/local/bin/vm-setup.sh

CMD ["/entrypoint"]