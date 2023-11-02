format MZ 
entry code_seg:main
stack 200h

;--------------------------------------------------
segment data_seg
filename db "MBR.txt"
buff db 48 dup(?)
mbr_buff db 512 dup(?)
;--------------------------------------------------

segment code_seg
main:
	mov ax, data_seg	;Defining data segment
	mov ds, ax
	mov es, ax		 

	mov bx, mbr_buff	;Defining buffer for saving data from MBR
	call get_MBR		;Function putting data from MBR to buffer for MBR
	mov si, mbr_buff	;Setting start offset to get data from MBR
	
	mov dx, filename	;Declaring filename where we gonna write info from memory dump
	
	mov ax, 0x3C00		;Creating file
	mov cx, 0		;File is not hidden (make cx equal to 1 to make it hidden)
	int 21h			;It writes logic address to ax
	jc fini
	mov bx, ax		;We save ax to bx, 'cause writing info in file needs logic address that it searchs in bx
	
	call dump	
	
	jmp fini		;exit flag

dump:	
	mov cx, 32
	lp:
		push cx
		mov cx, 16
		lp2:
			call fprint
			loop lp2
		mov ax, 0x4201		;Shifting pointer of file to the end of row to write 0x0d0a
		xor cx, cx
		mov dx, 16
		int 21h 

		pop cx
		call endl		;print endline after ending of writing 16 bytes of memory data to give a matrix form to memory dump
		loop lp
	ret
	


get_MBR:
	push ax
	push cx
	push dx	
	cld

	mov ah, 0x02 	;
	mov al, 1	;Number of sectors to read
	mov ch, 0	;Primary cylinder
	mov cl, 1	;Primary sector (6-7 bits are high bits of primary cylinder address)
	mov dh, 0	;Head
	mov dl, 0x80	;Getting from Hard disk, 'cause starts from 80h. 00h..7fh - is floppy disk
	int 13h
	jc fini

	pop dx
	pop cx
	pop ax	
	
	ret	


fprint:
	push cx
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

print:
	pusha
	mov dx, 16		;getting loop iteration variable
	sub dx, cx
	
	mov ax, 2		;getting offset of file pointer by the function dx=16*3-2*iter
	mul dx
	push ax

	mov dx, 48
	sub dx, ax

	mov ax, 0x4201
	xor cx, cx		;CX*2^16 + DX, that's why cx is zero. We need only offset that equal to DX
	int 21h 
		
	mov ah, 0x40			
	mov cx, 1 			;That's how much bytes we gonna write into file
	xor dx, dx
	mov dh, byte[es:si]			;That's offset of data segment (buffer in our case) where we gonna take data to write in file 
	int 21h				;interruption to write data in file (ah 40h)

	pop ax
	mov dx, -49			;returning filr pointer to previous position with function dx=-49+2*iter
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

	mov di, buff		;declaring buffer 
	mov dx, 0x0d0a		;0x0d - CR, 0x0a - LF 
	mov byte[ds:di], dh	;putting 0xd and 0xa to buffer
	inc di
	mov byte[ds:di], dl
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
	
