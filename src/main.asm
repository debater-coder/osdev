org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
        jmp main

;
; Prints help text
;
;
help:
        mov si, msg_help
        call print
        ret

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

        mov bx, 0
        
.loop:
        ; get input
        call input

        ; check if enter
        cmp al, 13
        je .enter

        ; check if backspace
        cmp al, 8
        je .backspace

        ; check if string overflowed
        cmp bx, 20
        jge .loop

        ; add to input_string
        mov [input_string + bx], al
        inc bx
        
        jmp .loop

.backspace:
        mov si, msg_bs
        call print

        dec bx
        
        jmp .loop

.enter:
        mov si, msg_newline
        call print

        mov [input_string + bx], word 0

.check_help:
        ; check if help
        mov cx, bx
        mov si, input_string
        mov di, cmd_help
        repe cmpsb
        jne .unknown

        call help
        jmp .end

.unknown:
        mov si, msg_unknown_command
        call print
        mov si, input_string
        call print
        mov si, msg_newline
        call print
        jmp .end

.end:
        mov bx, 0
        mov si, msg_prompt
        call print

        jmp .loop        

.halt:
        hlt
        jmp .halt

cmd_help: db 'help', 0

msg_boot_success: db 'Bootloader v0.1.0 ran successfully.', ENDL, 0
msg_prompt: db '> ', 0
msg_bs: db ' ', 8, 0
msg_newline: db ENDL, 0

msg_help: db 'MyOS v0.1.0', ENDL, ENDL, 'Commands:', ENDL, '    - help: display help', ENDL, '    - shutdown: terminate system', ENDL, 0
msg_unknown_command: db 'Unknown command: ', 0
input_string: db '                    ', 0

times 510-($-$$) db 0
dw 0AA55h