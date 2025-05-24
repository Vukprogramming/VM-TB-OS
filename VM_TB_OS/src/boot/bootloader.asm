BITS 16
ORG 0x7C00

start:
    cli                 ; Disable interrupts
    xor ax, ax          ; Clear ax
    mov ds, ax          ; Set DS to 0
    mov es, ax          ; Set ES to 0

    ; Read kernel from disk into memory at 0x1000
    mov ah, 0x02        ; Function: read sector
    mov al, 3           ; Number of sectors to read
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Sector 2 (bootloader is in sector 1)
    mov dh, 0           ; Head 0
    mov dl, 0x00        ; Drive 0 (first floppy or hard drive)
    mov bx, 0x1000      ; Load address = ES:BX = 0x0000:0x1000
    int 0x13            ; BIOS disk service
    jc disk_error       ; Jump to disk_error if the read fails

    ; Jump to kernel code at 0x1000:0x0000
    jmp 0x0000:0x1000

disk_error:
    hlt                 ; Hang if error occurs

times 510 - ($ - $$) db 0
dw 0xAA55