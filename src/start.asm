section .data
    buf_size: db 20
section .bss
    buf: resb 20
    input: resb 200000
    ;input_next:
section .text
    global _start

_start:
    lea rbx, [buf]
    read_entry:
        call read_line
        add rbx, rax   ; move to the end
        or rax, rax    ; number of bytes read
        jnz read_entry
    mov byte [rbx], 0x0

    jmp write_test
    ;jmp exit

read_line:
    push rbp
    mov rbp, rsp
    mov rax, 3		 ; read
    mov rcx, rbx        ; address to pass to
    push rbx
    mov rbx, 0		 ; standard input
    mov rdx, [buf_size]		 ; input length 
    int 0x80
    pop rbx 
    leave
    ret

    ; save buf
    ;mov rcx, rax
    ;lea rsi, [buf]
    ;lea rdi, [rbx]
    ;cld
    ;rep movsb
    ;add rbx, rax
    ;jmp read_line

ascii_to_number:
    push rbp
    mov rbp, rsp
    ;
    leave
    ret

compare_strs:
    push rbp
    mov rbp, rsp
    ;
    leave
    ret

;compare <key> with each <line> of heap
parse_heap:
    push rbp
    mov rbp, rsp
    ;
    leave
    ret

add_heap_entry:
    push rbp
    mov rbp, rsp
    ;
    leave
    ret

add_matrix_entry:
    push rbp
    mov rbp, rsp
    ;
    leave
    ret

upd_matrix_entry:
    push rbp
    mov rbp, rsp
    ;
    leave
    ret

write_test:
    mov rax, 4           ; write
    mov rcx, buf          ; address to the value
    sub rbx, rcx
    mov rdx, rbx           ; length of output 
    mov rbx, 1           ; standard output
    int 0x80             

exit:
    mov rax, 1
    xor rbx, rbx
    int 0x80