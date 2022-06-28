ARG version=1.22.2
ARG base=kindest/node
FROM ${base}:v${version}

LABEL org.opencontainers.image.authors="mohammad.f.zaman@nokia.com"
LABEL description="kind workers able to run ENC/vSR with Nokia proxy"
LABEL version="$version"


RUN echo "Acquire::http::Proxy \"http://135.245.48.34:8000\";\n\
Acquire::https::Proxy \"http://135.245.48.34:8000\";\n"\
>> /etc/apt/apt.conf


# See https://kind.sigs.k8s.io/docs/design/node-image for a walkthrough of
# the kind base image. In particular, that its entrypoint enables to start
# a systemd instance, hence honoring the below systemctl enable commands.

RUN mkdir /etc/systemd/system/containerd.service.d/
RUN echo "[Service] \n\
Environment=\"HTTP_PROXY=http://135.245.48.34:8000\"\n\
Environment=\"HTTPS_PROXY=http://135.245.48.34:8000\"\n\
Environment=\"NO_PROXY=localhost,127.0.0.1,::1\"\n"\
>> /etc/systemd/system/containerd.service.d/http-proxy.conf

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y iputils-ping libnl-utils net-tools tcpdump lldpd ssh vim
RUN systemctl enable lldpd
RUN systemctl enable containerd
RUN bash -c 'curl -sL https://get-gnmic.kmrd.dev | bash'
