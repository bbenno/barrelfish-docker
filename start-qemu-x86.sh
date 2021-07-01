#!/usr/bin/env bash

cd barrelfish/build

qemu-system-x86_64 \
	-machine type=q35 \
	-smp 4 \
	-m 4G \
	-enable-kvm \
	-netdev user,id=network0 \
	-device e1000,netdev=network0 \
	-device ahci,id=ahci \
	-device ide-hd,drive=disk,bus=ahci.0 \
	-drive id=disk,file=hd.img,if=none \
	-nographic \
	-kernel x86_64/sbin/elver \
	-append 'loglevel=3' \
	-initrd 'x86_64/sbin/cpu loglevel=3,x86_64/sbin/init,x86_64/sbin/mem_serv,x86_64/sbin/monitor,x86_64/sbin/ramfsd boot,x86_64/sbin/skb boot,eclipseclp_ramfs.cpio.gz nospawn,skb_ramfs.cpio.gz nospawn,x86_64/sbin/kaluga boot,x86_64/sbin/acpi boot,x86_64/sbin/spawnd boot,x86_64/sbin/proc_mgmt boot,x86_64/sbin/startd boot,x86_64/sbin/routing_setup boot,x86_64/sbin/pci auto,x86_64/sbin/corectrl auto,x86_64/sbin/ahcid auto,x86_64/sbin/serial_pc16550d auto,x86_64/sbin/hpet auto,x86_64/sbin/e1000n auto,x86_64/sbin/net_sockets_server nospawn,x86_64/sbin/fish nospawn,x86_64/sbin/angler serial0.terminal xterm'
