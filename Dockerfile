FROM ubuntu:18.04

MAINTAINER Benno Bielmeier "benno.bielmeier@st.othr.de"

## Build with "docker build --build-arg ARCH=<arch> -t barrelfish:git ."
## where <arch> is one of barrelfish's supported architectures.
## Examples for <arch>:
##   x86_64
##   armv7
##   armv8
##   k1om

## Install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get install -y -q \
  sudo \
  git \
## GCC 7.4.0 for x86_64, ARMv7 and ARMv8 \
  build-essential \
  g++ \
  gcc-arm-linux-gnueabi \
  g++-arm-linux-gnueabi \
  gcc-aarch64-linux-gnu \
  g++-aarch64-linux-gnu \
  binutils \
  make \
## GHC v8.0.2 and Parsec 3.1 \
  cabal-install \
  libghc-src-exts-dev \
  libghc-ghc-paths-dev \
  libghc-parsec3-dev \
  libghc-random-dev \
  libghc-ghc-mtl-dev \
  libghc-async-dev \
  libghc-aeson-pretty-dev \
  libghc-aeson-dev \
  libghc-missingh-dev \
## FreeBSD's libelf \
  libelf-freebsd-dev \
  freebsd-glue \
## Optional: LibUSB 1.0 (for the usbboot tool) \
#  libusb-1.0-0-dev \
## Optional: QEMU with e1000e EFI ROM \
#  qemu-system-x86 \
#  qemu-efi \
#  qemu-ipxe \
## Optional: PdfLatex (for documentation / technical notes) \
  graphviz \
  texlive-science \
  texlive-latex-extra \
  lhs2tex

## If QEMU with e1000e EFI ROM
# RUN cd /usr/lib/ipxe/qemu/ && wget https://github.com/qemu/qemu/raw/master/pc-bios/efi-e1000e.rom

## Create the user 'builder'
RUN adduser --disabled-password --gecos '' builder \
 && usermod -aG sudo builder \
 && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

## Configure new user
USER builder
ENV HOME /home/builder
ENV LANG en_US.UTF-8

## Prepare build
RUN cabal update \
 && cabal install bytestring-trie pretty-simple
RUN git clone -q --single-branch git://git.barrelfish.org/git/barrelfish /home/builder/barrelfish
WORKDIR /home/builder/barrelfish
RUN mkdir build

## Set default Architecture to x86_64
ARG ARCH=x86_64

## Build
RUN cd build \
 && ../hake/hake.sh -s .. -a ${ARCH} -j $(nproc)

## Build documentation
RUN cd build \
 && make Documentation -j $(nproc)
