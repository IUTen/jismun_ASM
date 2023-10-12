use16
org 100h

call main

xor ax, ax
int 16h
int 20h



main:
	mov ax, 0xb800
	mov es, ax
	
	xor di, di
	
	call print_loop	

	ret

print_loop:
	cld
	mov cx, 25
	lp1:	
		call drive
	
		call Delay

		mov word[es:di], 0x0000
		add di, 160	

		loop lp1
		
	call drive	
	
	ret


Delay:
	pusha
	mov ah, 0x0
	int 1ah
.Wait:
	push dx
	mov ah,0x0
	int 1ah
	pop bx
	cmp bx, dx
	je .Wait
	popa
	ret

drive:	
	pusha
	mov si, msg

	mov cx, 5 
	lp:
		movsw
		call endl
		loop lp

	popa
	ret

endl:
	add di, 158
	ret


msg dw 0xCE48, 0xCE65, 0xCE6C, 0xCE6C, 0xCE6F 
