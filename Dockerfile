FROM ubuntu:latest as builder

ARG QEMU_ARCH=arm
ARG OPENWRT_ARCH=armvirt
ARG QEMU_VER=v2.12.0

RUN apt-get update && apt-get install -y wget tar
ADD https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VER}/x86_64_qemu-${QEMU_ARCH}-static.tar.gz /usr/bin

RUN tar -xvf /usr/bin/x86_64_qemu-${QEMU_ARCH}-static.tar.gz
RUN mv qemu-arm-static /usr/bin/qemu-arm-static 
#RUN tar -xvf lede-17.01.4-armvirt-default-rootfs.tar.gz

#RUN /usr/bin/qemu-arm-static /bin/sh -c "tar -xvf lede-17.01.4-armvirt-default-rootfs.tar.gz"

RUN mkdir /openwrt
WORKDIR /openwrt
ADD https://downloads.openwrt.org/releases/17.01.4/targets/armvirt/generic/lede-17.01.4-armvirt-default-rootfs.tar.gz /openwrt
RUN tar -xvf lede-17.01.4-armvirt-default-rootfs.tar.gz
RUN ls -lrt /openwrt

FROM scratch
ENV QEMU_VER=${QEMU_VER}
ENV QEMU_ARCH=${QEMU_ARCH}
ENV OPENWRT_ARCH=${OPENWRT_ARCH}
ENV OPENWRT_VERSION=17.01.4

COPY --from=builder /openwrt /
COPY --from=builder /usr/bin/qemu-arm-static /usr/bin

RUN mkdir /var/lock
RUN opkg update
RUN opkg install curl make ca-bundle tar gcc perl perlbase-module pkg-config libevent binutils

RUN ln -s /usr/bin/gcc /usr/bin/cc

#Install OpenSSL
RUN curl -fsSL "https://www.openssl.org/source/openssl-1.0.2m.tar.gz" | tar zxvf -
WORKDIR openssl-1.0.2m
RUN ./config --prefix=/usr no-shared no-dso
RUN make -j$(nproc)
RUN make install
WORKDIR ..

#Install libevent
RUN curl -fsSL "https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz" | tar zxvf -
WORKDIR libevent-2.1.8-stable
RUN ./configure --prefix=/usr \
                --disable-shared \
                --enable-static \
                --with-pic
RUN make -j$(nproc)
RUN make install
WORKDIR ..

#Make redsocks
RUN curl -fsSL "https://github.com/semigodking/redsocks/archive/release-0.66.tar.gz" | tar zxvf -
WORKDIR redsocks-release-0.66
RUN make -j$(nproc)
