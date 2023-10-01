org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
        jmp main

;
; Get a character of input and echo it to the screen
;
; Returns:
;     - al contains ASCII keycode
input:
        ; save registers we will modify
        push bx

        ; get input
        mov ah, 0
        int 0x16

        ; echo to screen
        mov bh, 0
        mov ah, 0x0e
        int 0x10

        ; return
        pop bx
        ret

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

        mov si, msg_boot_success
        call print
        
        mov si, msg_prompt
        call print
        
.loop:
        ; get input
        call input

        ; check if enter
        cmp al, 13
        jne .loop

        mov si, msg_prompt
        call print        
            
        jmp .loop        
        
        hlt

.halt:
        jmp .halt

msg_boot_success: db 'Bootloader v0.1.0 ran successfully.', ENDL, 0
msg_prompt: db ENDL, '> ', 0

times 510-($-$$) db 0
dw 0AA55h