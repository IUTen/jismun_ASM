format MZ 
entry code_seg:main
stack 200h

;--------------------------------------------------
segment data_seg
filename db "MemCard.txt"
buff db 3 dup(?)
MemCard_buff db 140 dup(?)
;--------------------------------------------------

segment code_seg
main:
	mov ax, data_seg	;Defining data segment
	mov ds, ax
	mov es, ax		 

	xor ebx, ebx		
	mov di, MemCard_buff	;declaring buffer where we gonna put a data from memory card
	call 	get_MemCard	;Function of putting data from memory card to buffer for memory card
	
	mov dx, filename	;Declaring filename where we gonna write info from memory dump	
	mov ax, 0x3C00		;Creating file
	mov cx, 0		;File is not hidden (make cx equal to 1 to make it hidden)
	int 21h			;It writes logic address to ax
	jc fini
	mov bx, ax		;We save ax to bx, 'cause writing info in file needs logic address that it searchs in bx

	mov ax, 7		;number of rows to write in file	
	call dump	
	
	jmp fini		;exit flag

dump:	
	mov cx, ax 
	lp:
		mov dx, ax
		sub dx, cx
		push ax
		mov ax, 20
		mul dx
		mov si, MemCard_buff	;Setting start offset to get data from MBR
		add si, ax		;Shifting offset to 20*row bytes to get data of the "next raw" 
		
		push cx
		mov cx, 20 
		lp2:
			call get_offset	;get the offset to do little-endian
			call fprint
			loop lp2

		push ax
		mov ax, 0x4201		;Shifting pointer of file to the end of row to write 0x0d0a
		xor cx, cx
		mov dx, 20 
		int 21h 
		pop ax

		pop cx
		call endl		;print endline after ending of writing 16 bytes of memory data to give a matrix form to memory dump
		pop ax
		loop lp
	ret
	
get_offset:
	cmp cx, 20
	je eight1
	cmp cx, 12
	je eight2
	cmp cx, 4
	je four
	dec si
	back:
	ret
four:
	add si, 11 
	jmp back
eight1:
	add si, 7
	jmp back
eight2:
	add si, 15 
	jmp back

get_MemCard:
	push ax
	push ebx
	push ecx
	push edx	
	cld


	cycle:
		mov ax, 0xE820 		;function
		mov edx, 534d4150h	;"SMAP"
		mov ecx, 140 		;buffer size (min 20 bytes)
		int 15h
		jc fini 		;error handling
		add di, cx		;shifting offset from buffer to the size of written bytes to write next data
		cmp ebx, 0		;checking if ebx is zero. When ebx is zero, then all data from memory card has been copied
		jnz cycle		;if ebx is not zero, repeating the cycle	
	
	pop edx
	pop ecx
	pop ebx	
	pop ax

	ret	


fprint:
	push si
	push cx
	push ax
	push dx

	mov di, buff 			;Defining di as buffer 
	call print	
	call print_symbols		;Getting ascii codes of each tetrad of each byte of dump and putting it into dx register
	mov byte[ds:di], dh		;dh contains ascii code of first tetrad that's why we put it into buff
	inc di
	mov byte[ds:di], dl		;dl contains ascii code of second tetradthat's why we increment di and put it "near" ascii code of fisrt tetrad
	inc di

	mov byte[ds:di], 0x20		;adding space to separate bytes of dump
	

	mov ax, 0x4000 			
	mov cx, 3 			;That's how much bytes we gonna write into file
	mov dx, buff			;That's offset of data segment (buffer in our case) where we gonna take data to write in file 
	int 21h				;interruption to write data in file (ah 40h)

	pop dx	
	pop ax
	pop cx	
	pop si
	ret

print_symbols:
	push cx	
	
	mov cl, byte[es:si]	;getting first tetrad 
	shr cl, 4
    	call get_ascii		;getting ascii code of first tetrad
	mov dh, cl		;putting it into dh

	mov cl, byte[es:si]	;getting second tetrad and putting it into dl
	and cl, 0x0f
	call get_ascii		;getting ascii code of second tetrad
	mov dl, cl		;putting it into dl
	
	pop cx
    	ret

print:
	pusha
	mov dx, 20		;getting loop iteration variable
	sub dx, cx
	
	mov ax, 2		;getting offset of file pointer by the function dx=16*3-2*iter
	mul dx
	push ax

	mov dx,	60 
	sub dx, ax		;setting file pointer to starting position with function dx=60-2*iter

	mov ax, 0x4201
	xor cx, cx		;CX*2^16 + DX, that's why cx is zero. We need only offset that equal to DX
	int 21h 
		
	mov ah, 0x40			
	mov cx, 1 			;That's how much bytes we gonna write into file
	xor dx, dx
	mov dh, byte[es:si]		;That's offset of data segment (buffer in our case) where we gonna take data to write in file 
	int 21h				;interruption to write data in file (ah 40h)
	pop ax
	mov dx, -61			;returning file pointer to previous position with function dx=-61+2*iter
	add dx, ax 
	

	mov ax, 0x4201
	mov cx, -1			;CX is equal to -1 to set the sign of offset
	int 21h 

	popa
	ret


get_ascii:
	cmp cl, 0x09
	ja word_l
	jmp digit_l

word_l:
	add cl, 0x37
	ret
digit_l:
	add cl, 0x30
	ret

endl:
	push cx
	push ax

	mov di, buff		;declaring buffer 
	mov dx, 0x0d0a		;0x0d - CR, 0x0a - LF 
	mov byte[ds:di], dh	;putting 0xd and 0xa to buffer
	inc di
	mov byte[ds:di], dl
	mov ax, 0x4000		
	mov cx, 2 		;we write 2 bytes to file
	mov dx, buff		;putting buffer data to dx for interruption use
	int 21h

	pop ax
	pop cx
	ret


fini:
	mov ah, 0x4C
	int 21h			;exit
	
