#!/usr/bin/env bash

## Set default Architecture to x86_64
ARCH=x86_64
PLATFORM=X86_64_Basic
BUILD_DIR=barrelfish/build
BOOT=qemu_x86_64

## Install QEMU
sudo apt install -y -q \
	qemu-system-x86 \
	qemu-efi \
	ipxe-qemu

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

## Build
if [[ ! -f Makefile ]]
then
	../hake/hake.sh -s .. -a "$ARCH" -j $(nproc)
fi

## Build documentation
## optional LaTeX Live required!
# make Documentation -j $(nproc)

## Compile Barrelfish for Architecture
#make "$PLATFORM" -j $(nproc)

## Compile Barrelfish for platform
make "$BOOT" -j $(nproc)
