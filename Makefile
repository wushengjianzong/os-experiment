clean:
	rm -f hdd.img
	rm -f mbr.bin

compile:
	nasm mbr.S -o mbr.bin

disk:
	qemu-img create -f qcow2 hdd.img 60M
	dd if=./mbr.bin of=./hdd.img bs=512 count=1 conv=notrunc

run:
	qemu-system-i386 -drive file=hdd.img,index=0,media=disk,format=raw

all: clean compile disk run