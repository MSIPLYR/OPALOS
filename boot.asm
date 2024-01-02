section .data
    msg db 0   ; Attribute byte (0 for black background and black foreground)
    space db ' ' ; Blank character
    cols equ 80 ; Number of columns in the text mode
    rows equ 25 ; Number of rows in the text mode
    msg db 'OPAL-OS', 0

section .text
    global _start

_start:
    mov eax, 4        ; system call number for sys_write
    mov ebx, 1        ; file descriptor 1 is stdout
    mov ecx, hello    ; pointer to the message
    mov edx, 16       ; message length
    int 0x80          ; call kernel

    ; Exit the program
    mov eax, 1        ; system call number for sys_exit
    xor ebx, ebx      ; exit code 0
    int 0x80          ; call kernel

    ; Set the video mode to 3 (text mode, 80x25)
    mov ah, 0 ; Set video mode function
    mov al, 3 ; 80x25 text mode
    int 10h   ; Call BIOS interrupt

    ; Blank the screen
    mov ah, 9 ; Write character and attribute at current cursor position
    mov al, space ; ASCII code for blank space
    mov bh, 0 ; Page number
    mov bl, msg ; Attribute byte
    mov cx, cols * rows ; Number of characters to write
    int 10h ; Call BIOS interrupt

    ; Halt the program
    int 20h

    ; Set video mode to 13h (320x200, 256 colors)
    mov ax, 13h
    int 10h

    ; Set palette color 1 to blue
    mov dx, 03C8h
    mov al, 1
    out dx, al
    inc dx
    mov al, 0
    out dx, al
    out dx, al
    out dx, al

    ; Draw a filled blue rectangle in the middle of the screen
    mov ax, 0A000h
    mov es, ax
    mov cx, 100 ; Width of the rectangle (320/4)
    mov dx, 50  ; Height of the rectangle (200/4)
    mov di, 320 * 50 ; Starting position in the frame buffer

    ; Fill the rectangle with color 1 (blue)
    mov ax, 0101h
    rep stosw

    ; Display text
    mov ax, 0B800h
    mov es, ax
    mov di, 160 * 10 + 40 ; Position in the text buffer
    mov si, msg
    mov cx, 13 ; Length of the message

    ; Copy the message to the text buffer
    rep movsb

    ; Wait for a key press
    mov ah, 0
    int 16h

    ; Set video mode back to text mode (3)
    mov ax, 3
    int 10h

    ; Halt the program
    int 20h

    ; Set up segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Load message to memory location 0xB800:0x0000 (video memory)
    mov si, message
    mov di, 0xB800
    mov cx, 12 ; Message length

    copy_loop:
        mov al, [si]
        mov [di], ax
        add si, 1
        add di, 2
        loop copy_loop

    ; Infinite loop
    hlt

message db 'Official OpalOS', 0

times 510-($-$$) db 0  ; Fill the rest of the sector with zeros
dw 0xAA55             ; Boot signature

; bootloader.asm
org 0x7C00

section .text
    ; Bootloader code here

section .bss
    ; BSS section for uninitialized data

section .data
    ; Data section for initialized data

section .boot
    ; Boot signature and bootloader code
    times 510-($-$$) db 0
    db 0x55
    db 0xAA

; kernel.asm
section .text
    ; Kernel code here

section .data
    ; Data section for initialized data

section .bss
    ; BSS section for uninitialized data

section .boot
    ; Boot signature and bootloader code
    times 510-($-$$) db 0
    db 0x55
    db 0xAA
