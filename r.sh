#!/bin/bash
make clean
make all
qemu-system-x86_64 -drive file=iso/os/disk.img,format=raw -serial stdio
