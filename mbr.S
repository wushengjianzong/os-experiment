; 创建一个汇编语言源文件mbr.S
; 定义一个名为vstart的代码块
; 根据BIOS规范，MBR引导程序从0x7c00开始
%include "boot.inc"
SECTION MBR vstart=MBR_START
	; BIOS执行完后cs:ip寄存器为0x0000:0x7c00
	; 这里用先用cs寄存器初始化ax寄存器
	; 段寄存器ds/es/ss/fs不能使用立即数初始化
	; 因此使用ax寄存器初始化这4个段寄存器
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov fs, ax
	; 初始化堆栈指针
	mov sp, 0x7c00
	; gs段寄存器写入显存段基址
	mov ax, 0xb800
	mov gs, ax

	; ax:0x0600——操作号06，清屏
	; bx:0x0700——背景黑色，前景白色
	; cx:0x0000——左上角(0, 0)
	; dx:0x184f——右下角(80, 25)
	; 0x18=0d24, 0x4f=0d79
	mov ax, 0x0600
	mov bx, 0x0f00
	mov cx, 0x0000
	mov dx, 0x184f
	int 0x10

	mov eax, 0x00000002
	mov bx, OBR_START
	mov cx, 1
	call lba
	
	jmp OBR_START

lba:
	mov esi, eax
	mov di, cx

	mov dx, 0x01f2
	mov al, cl
	out dx, al
	mov eax, esi

	; LBA 7~0 
	mov dx, 0x01f3
	out dx, al

	; LBA 15~8
	mov cl, 8
	shr eax, cl
	mov dx, 0x01f4
	out dx, al

	; LBA 24~16
	shr eax, cl
	mov dx, 0x01f5
	out dx, al

	; LBA 24~27
	shr eax, cl
	and al, 0x0f
	or al, 0xe0
	mov dx, 0x01f6
	out dx, al

	mov dx, 0x01f7
	mov al, 0x20
	out dx, al

.check
	nop
	in al, dx
	and al, 0x88
	cmp al, 0x08
	jnz .check

	mov ax, di
	mov dx, 256
	mul dx
	mov cx, ax
	mov dx, 0x01f0

.read:
	in ax, dx
	mov [bx], ax
	add bx, 0x02
	loop .read
	ret

	times 510-($-$$) db 0
	db 0x55, 0xaa
