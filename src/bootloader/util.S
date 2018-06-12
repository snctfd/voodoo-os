;--------------------------------------------------
; File: util.S
; Date: 2018-06-11
; Author: snctfd (Rasmus Beck)
; 
; Contains various utility functions.
; 
;--------------------------------------------------

;--------------------------------------------------
; print_line
; 
; Prints a line. Quite shocking, really.
; Arguments:
; DS:SI should contain the address of a null-
; terminated string.
;--------------------------------------------------

print_line:
    cld ; Make sure we're moving the right direction
.loop:
    lodsb               ; Loads a byte from the string to AL
    cmp al, 0           ; Check if AL == 0
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    call new_line

    ret
new_line:
    mov ah, 0x0E
    mov al, 0x0A ; Line feed
    int 0x10

    mov ah, 0x0E
    mov al, 0x0D ; Carriage return
    int 0x10

    ret
