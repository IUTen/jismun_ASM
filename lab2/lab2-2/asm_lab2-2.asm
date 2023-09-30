use16
org 100h

mov ah, 0x09


mov dx, msg1
int 21h

mov ax, 0xba12

mov cx, ax
mov ah, 0x02
call main

mov ah,0x09
mov dx, msg2
int 21h

mov bx,0xde34

mov cx, bx
mov ah,0x02
call main

mov ax,0
int 16h
int 20h

main:
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



msg1:
	db 'AX=0x$'
msg2:
	db ' BX=0x$'
endline_msg:
	db 0xd, 0xa, '$'
