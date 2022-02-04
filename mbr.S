; 创建一个汇编语言源文件mbr.S
; 定义一个名为vstart的代码块
; 根据BIOS规范，MBR引导程序从0x7c00开始
SECTION MBR vstart=0x7c00
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
	; 使用gs段寄存器作为显存段基址
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

	; 直接写显存，在屏幕前5个位置显示cloud
	; 低字节为ascii码，高字节为颜色设置
	; 0x0f: 背景黑色，前景白色
	mov byte [gs:0x0000], 'c'
	mov byte [gs:0x0001], 0x0f

	mov byte [gs:0x0002], 'l'
	mov byte [gs:0x0003], 0x0f

	mov byte [gs:0x0004], 'o'
	mov byte [gs:0x0005], 0x0f

	mov byte [gs:0x0006], 'u'
	mov byte [gs:0x0007], 0x0f

	mov byte [gs:0x0008], 'd'
	mov byte [gs:0x0009], 0x0f

	; 使程序悬停在这里，相当于一个死循环
	; nasm中的$代表当前行地址
	jmp $

	; 整个MBR引导程序总共写入磁盘512字节
	; MBR的最后两个字节是0x55和0xaa这样的固定内容
	; times: nasm中表示重复执行
	; $$代表这个vstart这个代码段的起始地址
	; 从当前行到MBR结束标志的扇区全部填充为0
	times 510-($-$$) db 0
	db 0x55, 0xaa
