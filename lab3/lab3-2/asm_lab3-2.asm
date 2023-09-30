use16
org 100h

call main

mov ax,0
int 16h
int 20h

main:
    mov ax, 0x1234
    mov bx, 0x4678
    mov cx, 0x9ABC
    mov dx, 0xDEF0
    mov si, 0x0001 
    mov di, 0x0002 
    mov bp, 0x0004

    pushf 
    push bp
    push di  
    push si
    push es  
    push ds
    push ss  
    push cs
    push dx  
    push cx
    push bx  
    push ax

    

    ;AX  
    mov ah, 0x09
    mov dx, msg_ax
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;BX
    mov ah, 0x09
    mov dx, msg_bx
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;CX
    mov ah, 0x09
    mov dx, msg_cx
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;DX
    mov ah, 0x09
    mov dx, msg_dx
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;CS
    mov ah, 0x09
    mov dx, msg_cs
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;SS
    mov ah, 0x09
    mov dx, msg_ss
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;DS
    mov ah, 0x09
    mov dx, msg_ds
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;ES
    mov ah, 0x09
    mov dx, msg_es
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;SI
    mov ah, 0x09
    mov dx, msg_si
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;DI
    mov ah, 0x09
    mov dx, msg_di
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;SP
    mov ah, 0x09
    mov dx, msg_sp
    int 21h

    mov ax, sp
    mov ax, 0x003
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;BP
    mov ah, 0x09
    mov dx, msg_bp
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h

    ;FLAG
    mov ah, 0x09
    mov dx, msg_flag
    int 21h

    pop ax
    call get_symbols
    mov ah, 0x09
    mov dx, endline_msg
    int 21h


    
    ret

    




get_symbols:

    push cx 
    mov cx, ax

    mov ah, 0x02

    mov dl,ch
	shr dl,4
	call get_ascii
	int 21h

	mov dl,ch
	and dl,0x0f
	call get_ascii 
	int 21h


	mov dl,cl
	shr dl,4
	call get_ascii   
	int 21h

	mov dl,cl
	and dl,0x0f
	call get_ascii 
	int 21h

    pop cx

    ret


get_ascii:
	cmp dl,0x09          
	ja word_symbol	
	jmp digit_symbol

word_symbol:
	add dl,0x37
	ret

digit_symbol:
	add dl,0x30
	ret


msg_ax:
    db 'AX=0x$'

msg_bx:
    db 'BX=0x$'

msg_cx:
    db 'CX=0x$'

msg_dx:
    db 'DX=0x$'

msg_cs:
    db 'CS=0x$'

msg_ss:
    db 'SS=0x$'

msg_ds:
    db 'DS=0x$'

msg_es:
    db 'ES=0x$'

msg_si:
    db 'SI=0x$'

msg_di:
    db 'DI=0x$'

msg_sp:
    db 'SP=0x$'

msg_bp:
    db 'BP=0x$'

msg_flag:
    db 'FLAGS=0x$'


endline_msg:
	db 0xd, 0xa, '$'
