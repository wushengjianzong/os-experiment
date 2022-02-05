; 创建一个汇编语言源文件mbr.S
; 定义一个名为vstart的代码块
; 根据BIOS规范，MBR引导程序从0x7c00开始
; 引入boot.inc
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
	mov sp, MBR_START
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

	; 读取第二扇区的内容
	mov eax, 2
	; 从bx指定的地址开始写入内存
	mov bx, OBR_START
	; 读取1个扇区
	mov cx, 1
	; 调用硬盘读写的代码
	call lba
	
	; MBR——Main Boot Record
	; OBR——OS Boot Record
	; 跳转到加载入内存的OBR程序
	jmp OBR_START

lba:
	; 备份eax到esi
	mov esi, eax
	; 备份cx到di
	mov di, cx

	; 将读取扇区数1写入0x01f2通道
	; 0x01f2: sector count
	mov dx, 0x01f2
	mov al, cl
	out dx, al
	; 恢复eax
	mov eax, esi

	; LBA——Logic Block Access，逻辑区块地址
	; 0x01f3: LBA地址0~7位
	; eax低16是ax，ax低8位就是al
	mov dx, 0x01f3
	out dx, al

	; eax中的LBA地址右移8位
	mov cl, 8
	shr eax, cl
	; 0x01f4: LBA地址8~15位
	mov dx, 0x01f4
	out dx, al

	; eax中的LBA地址左移8位
	shr eax, cl
	; 0x01f5: LBA地址16~23位
	mov dx, 0x01f5
	out dx, al

	; 0x01f6: device寄存器，低四位依然是LBA地址
	shr eax, cl
	and al, 0x0f
	; 这里所说的第n位按自低向高顺序，从0开始计数
	; 第4位DEV为1表示使用主盘
	; 第6位MOD表示使用LBA寻址模式
	; 第5和第7位固定为1，称为MBS位
	or al, 0xe0
	mov dx, 0x01f6
	out dx, al

	; 0x01f7: 状态寄存器
	; 写入读命令0x20
	mov dx, 0x01f7
	mov al, 0x20
	out dx, al

.check
	nop
	; 读取硬盘状态
	in al, dx
	; 第3位DRQ为1表示硬盘就绪
	; 第7位BSY为1表示硬盘正忙
	and al, 0x88
	cmp al, 0x08
	; 若检查不成功，循环检查
	jnz .check

	; 将读取的扇区数装入ax
	mov ax, di
	; 一个扇区512字节，一次读2字节，需要读256次
	mov dx, 256
	; dx乘以ax，结果存入ax，表示总读取次数
	mul dx
	; ax存入cx，控制循环次数
	mov cx, ax
	; 0x01f0: 数据寄存器
	mov dx, 0x01f0

.read:
	; 从硬盘读取数据到dx
	in ax, dx
	; 将ax中的数据存入bx指向的内存地址
	mov [bx], ax
	; 因为一次写2个字节，bx所指的地址加2
	add bx, 0x02
	; 循环读盘直至结束
	loop .read
	; 从call调用返回
	ret

	; 整个MBR引导程序总共写入磁盘512字节
	; MBR的最后两个字节是0x55和0xaa这样的固定内容
	; times: nasm中表示重复执行
	; $$代表这个vstart这个代码段的起始地址
	; db: 即define byte，定义字节类型
	; 从当前行到MBR结束标志的扇区全部填充为0
	times 510-($-$$) db 0
	db 0x55, 0xaa
