# Target architecture
ARCH = armv8
# Destination to copy the built barrelfish kernel to
CP_DIR = .
# File temporarily holding the Docker container ID (CID)
CID_FILE := $(shell mktemp)

default: run

build: Dockerfile
	docker build --build-arg ARCH=$(ARCH) -t barrelfish:$(ARCH) .

run: build
	docker run -it barrelfish:$(ARCH)

Zynq7000:
	# Compile Barrelfish for Zynq7000 (ARMv7)
	docker build --build-arg ARCH=armv7 --build-arg PLATFORM=$@ -t barrelfish:armv7-$@ .
	# Copy compiled files to local storage
	docker create barrelfish:armv7-$@ > $(CID_FILE)
	docker cp `cat $(CID_FILE)`:/home/builder/barrelfish/build $@
	docker rm `cat $(CID_FILE)`

cp:
	@echo "Clean up previous build"
	rm -rf $(CP_DIR)/build
	docker create barrelfish:$(ARCH) > $(CID_FILE)
	docker cp `cat $(CID_FILE)`:/home/builder/barrelfish/build $(CP_DIR)
	docker rm `cat $(CID_FILE)`

.PHONY: build run cp
