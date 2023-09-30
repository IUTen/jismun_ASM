use16
org 100h

call main

mov ax, 0
int 16h
int 20h


main:
    mov bx, 0x008c

    mov cx, 16
    lp1:
        push cx
        mov cx, 16    
        lp2:
            call print
            inc bx
            loop lp2
        call endline
        pop cx
        loop lp1

    ret


print:
    pusha
    mov cl, byte[bx]
    call print_symbols
    call print_space

    popa
    ret


print_space:

    mov dx, 0x20
    mov ah, 0x02
    int 21h

    ret

endline:
    pusha
    
    mov ah, 0x09
    mov dx, endl
    int 21h

    popa
    ret


endl:
    db 0xd, 0xa, '$'

print_symbols:

    pusha
    mov ah, 0x02

    mov dl, cl
    shr dl, 4
    call get_ascii
    int 21h

    mov dl, cl
    and dl, 0x0f
    call get_ascii
    int 21h

    popa
    ret


get_ascii:
    cmp dl, 0x09
    ja word_symbol
    jmp digit_symbol

word_symbol:
    add dl, 0x37
    ret

digit_symbol:
    add dl, 0x30
    ret



