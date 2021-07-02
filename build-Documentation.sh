#!/usr/bin/env bash

## Set default Architecture to x86_64
ARCH=
PLATFORM=
BUILD_DIR=barrelfish/build
BOOT=

## Install PdfLatex (for documentation / technical notes)
sudo apt install -y -q \
 	graphviz \
 	texlive-science \
 	texlive-latex-extra \
 	lhs2tex

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

## Build
if [[ ! -f Makefile ]]
then
	../hake/hake.sh -s .. -j $(nproc)
fi

## Build documentation
make Documentation -j $(nproc)
