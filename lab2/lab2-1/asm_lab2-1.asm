use16
org 100h

mov ax, 0xb800

mov es, ax
mov di, 2720
mov si, msg
mov cx, 15
lp:
	movsw
	loop lp

mov ax,0
int 16h
int 20h

msg:
	dw 0xCE41, 0xCE6D, 0xCE69, 0xCE72, 0xCE20, 0xCE54, 0xCE65, 0xCE6D, 0xCE69, 0xCE72, 0xCE6C, 0xCE61, 0xCE6E, 0xCE6F, 0xCE76
