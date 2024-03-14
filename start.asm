section .data
    buf_size: db 20
section .bss
    buf: resb 20
    input: resb 200000
    ;input_next:
section .text
    global _start

_start:
    lea rbx, [input]

read_next:
    push rbx
    mov eax, 3		 ; read
    mov ebx, 0		 ; standard input
    mov ecx, buf        ; address to pass to
    mov edx, [buf_size]		 ; input length 
    int 0x80
    pop rbx               
    or eax, eax
    jz proceed

    ; save buf
    mov ecx, eax
    lea rsi, [buf]
    lea rdi, [rbx]
    cld
    rep movsb
    add ebx, eax
    jmp read_next

proceed:
    mov byte [ebx], 0x0

; test
write_next:
    mov eax, 4           ; write
    mov ecx, input          ; address to the value
    sub ebx, ecx
    mov edx, ebx           ; length of output 
    push rbx
    mov ebx, 1           ; standard output
    int 0x80             

exit:
    mov eax, 1
    int 0x80