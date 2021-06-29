FROM ubuntu:18.04

MAINTAINER Benno Bielmeier "benno.bielmeier@st.othr.de"

## Build with "docker build --build-arg ARCH=<arch> --build-arg PLATFORM=<ARCH-dependent platform> -t barrelfish:git ."
## where <arch> is one of barrelfish's supported architectures.
## Examples for <arch>:
## 	x86_64
## 	armv7
## 	armv8
## 	k1om

## Install dependencies
ENV DEBIAN_FRONTEND noninteractive
RUN apt update
RUN apt upgrade -y -q

## GCC 7.4.0 for x86_64, ARMv7 and ARMv8
RUN apt install -y -q \
	build-essential \
	cpio \
	git \
	sudo \
	gcc-aarch64-linux-gnu \
	g++-aarch64-linux-gnu \
	gcc-arm-linux-gnueabi \
	g++-arm-linux-gnueabi

## GHC v8.0.2 and Parsec 3.1
RUN apt install -y -q \
	cabal-install \
	libghc-ghc-mtl-dev \
	libghc-ghc-paths-dev \
	libghc-parsec3-dev \
	libghc-src-exts-dev \
	libghc-async-dev \
	libghc-random-dev \
	libghc-aeson-pretty-dev \
	libghc-aeson-dev \
	libghc-ghc-paths-dev \
	libghc-missingh-dev

## FreeBSD's libelf
# RUN apt install -y -q \
# 	libelf-freebsd-dev \
# 	freebsd-glue

## Optional: LibUSB 1.0 (for the usbboot tool)
# RUN apt install -y -q \
# 	libusb-1.0-0-dev
## Optional: QEMU with e1000e EFI ROM
# RUN apt install -y -q \
# 	qemu-system-x86 \
# 	qemu-efi \
# 	qemu-ipxe

## Optional: PdfLatex (for documentation / technical notes)
# RUN apt install -y -q \
# 	graphviz \
# 	texlive-science \
# 	texlive-latex-extra \
# 	lhs2tex

## If QEMU with e1000e EFI ROM
# RUN cd /usr/lib/ipxe/qemu/ \
#  && wget https://github.com/qemu/qemu/raw/master/pc-bios/efi-e1000e.rom

## Create the user 'builder'
RUN adduser --disabled-password --gecos '' builder \
 && usermod -aG sudo builder \
 && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

## Configure new user
USER builder
ENV HOME /home/builder
ENV LANG en_US.UTF-8

RUN git clone -q git://git.barrelfish.org/git/barrelfish /home/builder/barrelfish
WORKDIR /home/builder/barrelfish
RUN mkdir build

## Prepare build
RUN cabal update
RUN cabal install bytestring-trie pretty-simple async

## Set default Architecture to x86_64
ARG ARCH=x86_64

## Build
WORKDIR /home/builder/barrelfish/build
RUN ../hake/hake.sh -s .. -a ${ARCH} -j $(nproc)

## Build documentation
# RUN make Documentation -j $(nproc)

## Available platforms depends on chosen ${ARCH}itecture
ARG PLATFORM

## Compile Barrelfish for platform
RUN test -n "$PLATFORM" \
 && make ${PLATFORM} -j $(nproc)
