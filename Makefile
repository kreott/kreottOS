KERNEL_BIN = iso/kernel/kernel.bin
COMP_FLAGS = -Isrc/libs -fno-asynchronous-unwind-tables -march=x86-64 -ffreestanding -fno-exceptions -fno-rtti -fno-stack-protector -fno-pie -fno-pic -m64 -O0
LIB_SRC = $(wildcard src/libs/*.cpp)
LIB_OBJ = $(patsubst src/libs/%.cpp,iso/bin/libs/%.o,$(LIB_SRC))


all:
	mkdir -p iso/os
	mkdir -p iso/bin/libs
	mkdir -p iso/bin/kernel


	nasm -f elf64 src/kernel/kernel.asm -o iso/bin/kernel/kernel_asm.o
	
	# cpp kernel
	x86_64-elf-g++ $(COMP_FLAGS) -c src/kernel/kernel.cpp -o iso/bin/kernel/kernel_cpp.o 

	# compile libs: each .cpp -> own .o
	$(foreach src_file,$(LIB_SRC), \
		x86_64-elf-g++ $(COMP_FLAGS) -c $(src_file) -o iso/bin/libs/$$(basename $(src_file) .cpp).o;)

	
	ld -m elf_x86_64 -z max-page-size=0x1000 -T src/kernel/kernel.ld -o iso/bin/kernel/kernel.elf iso/bin/kernel/kernel_asm.o iso/bin/kernel/kernel_cpp.o $(LIB_OBJ)
	x86_64-elf-objcopy -O binary iso/bin/kernel/kernel.elf iso/bin/kernel/kernel.bin

	cp /usr/share/limine/limine-bios.sys iso/bin/kernel/
	
	dd if=/dev/zero of=iso/os/disk.img bs=1M count=11
	parted iso/os/disk.img mklabel msdos
	parted iso/os/disk.img mkpart primary 1MiB 10MiB

	limine bios-install iso/os/disk.img


	# Mount the image (loopback) or use syslinux/fat to copy files
	# Example with loop device:
	losetup -Pf iso/os/disk.img
	mkfs.fat /dev/loop0p1
	mount /dev/loop0p1 /mnt
	ls -l /mnt
	cp iso/bin/kernel/kernel.elf /mnt/
	cp /usr/share/limine/limine-bios.sys /mnt/
	cp src/limine/limine.conf /mnt/

	umount /mnt
	losetup -d /dev/loop0





clean:
	@LOOPS=$$(losetup -j iso/os/disk.img | cut -d: -f1); \
	for loop in $$LOOPS; do \
		echo "Detaching $$loop"; \
		sudo losetup -d $$loop; \
	done
	rm -rf iso/*
