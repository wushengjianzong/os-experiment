clean:
	rm -f *.img
	rm -f *.bin

bin:
	nasm -I include/ mbr.S -o mbr.bin
	nasm -I include/ obr.S -o obr.bin

image:
	qemu-img create -f qcow2 hdd.img 60M
	dd if=./mbr.bin of=./hdd.img bs=512 count=1 conv=notrunc
	# OBR引导程序写入第2扇区，所以偏移量为2
	dd if=./obr.bin of=./hdd.img bs=512 count=1 seek=2 conv=notrunc

qemu:
	qemu-system-i386 -drive file=hdd.img,index=0,media=disk,format=raw

all: clean bin image qemu