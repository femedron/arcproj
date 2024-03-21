section .data
    buf_size: db 24    ; 16 (key) + 1 (' ') + 6 (val) + 1 (0x0)
section .bss
    buf: resb 24         ; each line
    heap: resb 170000      ; (16 (key) + ' ') * 10000 , 0x0 at tail
    matrix: resb 10000*14   ; (4 (val) + 2 (count) + 8 (key addr in heap)) * 10000
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

    dec rbx
    call ascii_to_number


    dec rbx              
    lea rcx, [buf]
    sub rbx, rcx
    xchg rbx, rcx     
    push rcx        ; length of key
    push rbx        ; key
    push rax        ; value

    ;; compare strings including terminating character !!!

    jmp number_write_test
    ;jmp write_test
    jmp exit


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
    ; rbx - pointer on number end
    ; returns the value in rax
    ; then rbx points on number start
    push rbp
    mov rbp, rsp
    xor rax, rax             ; return value
    xor rcx, rcx             ; counter
    
    ascii_to_number_loop:
        mov rdx, [rbx]
        cmp rdx, ' '
        jz ascii_to_number_end
        cmp rdx, '-'
        jz ascii_to_number_neg
        sub rdx, 48               ; 48 == ascii '0'
        push rax
        push rcx
        mov rax, 1
        power:
            cmp ecx, 0
            jz end_power
            imul rax, 10                                             
            dec ecx
            jmp power
        end_power:
        imul rdx, rax
        pop rcx
        pop rax
        add rax, rdx
        inc rcx
        dec rbx
        jmp ascii_to_number_loop

    ascii_to_number_neg:
        dec rbx
        neg rax
    ascii_to_number_end:
        inc rbx
        leave
        ret

compare_strs:
    ; rax and rbx
    ; rcx - length
    ; returns 0 or 1 in rdx
    push rbp
    mov rbp, rsp
    xor rdx, rdx
    lea rsi, [rax]
    lea rdi, [rbx]
    cld
    repe cmpsb
    jnz not_equal
    inc rdx
    not_equal:
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
    jmp exit

number_write_test:
    add rax, 48
    mov byte [rbx], al
    mov rax, 4           ; write
    mov rcx, buf          ; address to the value
    mov rdx, 1           ; length of output 
    mov rbx, 1           ; standard output
    int 0x80       
    jmp exit

exit:
    mov rax, 1
    xor rbx, rbx
    int 0x80