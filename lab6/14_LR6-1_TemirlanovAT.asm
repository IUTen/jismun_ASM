format MZ
entry code_seg:main
stack 200h

;--------------------------------------------------
segment data_seg
filename db "tmp.txt"
buff db 24 dup(?)
;--------------------------------------------------

segment code_seg
main:
	mov ax, data_seg	;Defining data segment
	mov ds, ax

	xor ax, ax
	mov es, ax		;Defining segment where we gonna do dump from
	mov si, 100h		;Defining offset from segment to set start point
		
	mov dx, filename	;Declaring filename where we gonna write info from memory dump
	
	mov ax, 0x3C00		;Creating file
	mov cx, 0		;File is not hidden (make cx equal to 1 to make it hidden)
	int 21h			;It writes logic address to ax

	mov bx, ax		;We save ax to bx, 'cause writing info in file needs logic address that it searchs in bx
	
	call dump	
	
	jmp fini		;exit flag

dump:	
	mov cx, 16
	lp:
		push cx
		mov cx, 16
		lp2:
			call fprint
			loop lp2
		pop cx
		call endl		;print endline after ending of writing 16 bytes of memory data to give a matrix form to memory dump
		loop lp
	ret
	

fprint:
	push cx
	mov di, buff 			;Defining di as buffer

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

	pop cx	
	ret

print_symbols:

	mov cl, byte[es:si]	;getting first tetrad 
	shr cl, 4
    	call get_ascii		;getting ascii code of first tetrad
	mov dh, cl		;putting it into dh

	mov cl, byte[es:si]	;getting second tetrad and putting it into dl
	and cl, 0x0f
	call get_ascii		;getting ascii code of second tetrad
	mov dl, cl		;putting it into dl
	
	inc si			;incrementing offset to get next byte

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

	mov di, buff		;declaring buffer 
	mov dx, 0x0d0a		;0x0d - CR, 0x0a - LF 
	mov byte[ds:di], dh	;putting 0xd and 0xa to buffer
	inc di
	mov byte[ds:di], dl
	inc di
	mov ax, 0x4000		
	mov cx, 2 		;we write 2 bytes to file
	mov dx, buff		;putting buffer data to dx for interruption use
	int 21h

	pop cx
	ret


fini:
	xor ax, ax
	mov ah, 0x4C
	int 21h			;exit
	
