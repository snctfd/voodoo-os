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
    mov ah, 0x0E
.loop:
    lodsb               ; Loads a byte from the string to AL
    or al, al           ; Check if AL == 0
    jz .done
    int 0x10
    jmp .loop
.done:
    mov ah, 0x0E
    mov al, 0x0A ; Line feed
    int 0x10

    mov al, 0x0D ; Carriage return
    int 0x10

    ret