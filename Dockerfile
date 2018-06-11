ARG QEMU_ARCH=armhf
ARG OPENWRT_ARCH=armvirt
ARG QEMU_VER=v2.12.0

FROM ubuntu:latest as builder
RUN apt-get update && apt-get install -y wget
ADD https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VER}/x86_64_qemu-${QEMU_ARCH}-static.tar.gz /usr/bin

FROM scratch
ENV QEMU_VER=${QEMU_VER}
ENV QEMU_ARCH=${QEMU_ARCH}
ENV OPENWRT_ARCH=${OPENWRT_ARCH}
ENV OPENWRT_VERSION=17.01.4
ADD https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/armvirt/generic/lede-${OPENWRT_VERSION}-${OPENWRT_ARCH}-default-rootfs.tar.gz /
COPY --from=builder /usr/bin/qemu-arm-system /usr/bin

