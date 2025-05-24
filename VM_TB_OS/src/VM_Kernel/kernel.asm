BITS 16
ORG 0x1000

start:
    call boot_clear_screen

    mov ah, 0x02        ; Set cursor position
    mov bh, 0x00        ; Page number
    mov dl, 32          ; Column
    mov dh, 0           ; Row
    int 0x10

    mov si, message
    call print_string

main_loop:

    mov si, user_input
    call get_input_loop

    mov ax, ds
    mov es, ax

    mov si, user_input        
    mov di, vm_ver_cmd        
    call compare_strings
    cmp ax, 1                  
    je VM_ver

    mov si, user_input
    mov di, shut_down_cmd
    call compare_strings
    cmp ax, 1
    je shut_down

    mov si, user_input
    mov di, clear_screen_cmd
    call compare_strings
    cmp ax, 1
    je clear_screen

    mov si, user_input
    mov di, beep_cmd
    call compare_strings
    cmp ax, 1
    je do_beep

    mov si, invalid_cmd_str
    call print_string
    jmp main_loop

VM_ver:
    mov si, vm_ver_cmd_str
    call print_string
    jmp main_loop

print_string:
    lodsb
    cmp al, 0
    je done_print_string
    mov ah, 0x0E
    int 0x10
    jmp print_string

done_print_string:
    ret

get_input_loop:
    call get_key
    cmp al, 8
    je handle_backspace
    mov ah, 0x0E
    int 0x10
    cmp al, 0x0D              
    je done_input
    mov [si], al
    inc si
    jmp get_input_loop

done_input:
    mov byte [si], 0          
    ret
    jmp get_input_loop

handle_backspace:
    mov al, 8
    mov ah, 0x0E
    int 0x10

    mov al, ' '
    mov ah, 0x0E
    int 0x10
    
    mov al, 8
    mov ah, 0x0E
    int 0x10

    dec si
    jmp get_input_loop

done:
    jmp $

get_key:
    mov ah, 0x00
    int 0x16
    ret

compare_strings:

compare_loop:
    lodsb                      
    scasb                    
    jne not_equal              
    cmp al, 0                    
    je equal                    
    jmp compare_loop            

equal:
    mov ax, 1                    
    ret

not_equal:
    xor ax, ax                   
    ret

message:
    db 'Welcome to VM OS :)', 13, 10
    db 13, 10
    db 0
    
shut_down:
    mov al, 0x00
    out 0xF4, al
    hlt

clear_screen:
    mov ah, 0x06           
    mov al, 0              
    mov bh, 0x07          
    mov cx, 0              
    mov dx, 0x184F         
    int 0x10

    mov ah, 0x02           
    mov bh, 0              
    mov dh, 0              
    mov dl, 0              
    int 0x10

    mov ah, 0x01           
    mov cx, 0x0607         
    int 0x10

    jmp main_loop

boot_clear_screen:
    mov ah, 0x06           
    mov al, 0              
    mov bh, 0x07          
    mov cx, 0              
    mov dx, 0x184F         
    int 0x10

    mov ah, 0x02           
    mov bh, 0              
    mov dh, 0              
    mov dl, 0              
    int 0x10

    mov ah, 0x01           
    mov cx, 0x0607         
    int 0x10

    ret

do_beep:
    call beep
    jmp main_loop

beep:
    ;Enable to test if beep command works if your qemu build dosent have pcspk
    ;To check if your qemu build has pcspk enter "qemu-system-i386 -device help" to check
;  --------------
    ;mov al, '*'
    ;mov ah, 0x0E
    ;int 0x10
;  --------------

    mov al, 7        ; BEL character
    mov ah, 0x0E     ; BIOS teletype function
    int 0x10
    ret
    
vm_ver_cmd_str:
    db 10, 13
    db 10, 13
    db 'OS: VM OS', 13, 10
    db 'VM Version: VM TB Alpha 0.1', 13, 10
    db 10, 13
    db 0

user_input:
    db 80 dup(0)

invalid_cmd_str:
    db 10, 13
    db 'Error: Invalid Command', 13, 10
    db 10, 13
    db 0

clear_screen_cmd: db 'cls', 0
beep_cmd:         db 'aud beep', 0
vm_ver_cmd:       db 'VM --ver', 0
shut_down_cmd:    db 'pwr> 0', 0

; Command to update kernel: nasm -f bin kernel.asm -o kernel.bin
; Command to update OS: copy /b bootloader.bin + kernel.bin VM_TB_OS.bin
; Command to run in Qemu: qemu-system-i386 -fda VM_TB_OS.bin