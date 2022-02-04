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

	; ah:0x03——子功能号3，获取光标位置
	; bh:0x00——待获取光标的页号
	mov ah, 0x03
	mov bh, 0x00
	; 发起BIOS中断调用
	int 0x10

	; 文本地址存入ax
	mov ax, msg
	; 初始化基址寄存器
	mov bp, ax
	; 字符串长度，不包括结束符0
	mov cx, len
	; ah:0x13——子功能号13，显示字符串
	; al:0x01——光标跟随移动
	mov ax, 0x1301
	; bh:0x00——第0页
	; bl:0x0f——黑底白字
	mov bx, 0x000f
	int 0x10

	; 使程序悬停在这里，相当于一个死循环
	; nasm中的$代表当前行地址
	jmp $

	; 定义一个message变量
	; db: nasm中表示define byte，字节类型
	msg db "hello world"
	; 获取字符串长度
	len equ $-msg
	; 整个MBR引导程序总共写入磁盘512字节
	; MBR的最后两个字节是0x55和0xaa这样的固定内容
	; times: nasm中表示重复执行
	; $$代表这个vstart这个代码段的起始地址
	; 从当前行到MBR结束标志的扇区全部填充为0
	times 510-($-$$) db 0
	db 0x55, 0xaa
