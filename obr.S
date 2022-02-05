%include "boot.inc" 
SECTION OBR vstart=OBR_START
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

    ; 死循环
    jmp $