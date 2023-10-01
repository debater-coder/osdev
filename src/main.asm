org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
        jmp main

;
; Prints a null-terminated string to the screen
; Params:
;     - ds:si points to string
;
print:
        ; save registers we will modify
        push si
        push ax

.loop:
        lodsb                ; loads next character in al
        
        or al, al            ; check if next character is null?
        jz .done

        mov ah, 0x0e         ; call tty bios interrupt
        mov bh, 0
        int 0x10
        
        jmp .loop

.done:
        pop ax
        pop si
        ret


main:
        ; setup data segments
        mov ax, 0
        mov ds, ax
        mov es, ax

        ; setup stack
        mov ss, ax
        mov sp, 0x7C00

        mov si, msg_hello_world
        call print
        
        
        hlt

.halt:
        jmp .halt

msg_hello_world: db 'Hello, World!', ENDL, 0

times 510-($-$$) db 0
dw 0AA55h