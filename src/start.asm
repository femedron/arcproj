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
    mov rax, 3		 ; read
    mov rbx, 0		 ; standard input
    mov rcx, buf        ; address to pass to
    mov rdx, [buf_size]		 ; input length 
    int 0x80
    pop rbx               
    or rax, rax 
    jz proceed

    ; save buf
    mov rcx, rax
    lea rsi, [buf]
    lea rdi, [rbx]
    cld
    rep movsb
    add rbx, rax
    jmp read_next

proceed:
    mov byte [rbx], 0x0

; test
write_next:
    mov rax, 4           ; write
    mov rcx, input          ; address to the value
    sub rbx, rcx
    mov rdx, rbx           ; length of output 
    push rbx
    mov rbx, 1           ; standard output
    int 0x80             

exit:
    mov rax, 1
    int 0x80