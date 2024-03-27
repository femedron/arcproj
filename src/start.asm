section .data
    buf_size: db 24    ; 16 (key) + 1 (' ') + 6 (val) + 1 (0x0A)
section .bss
    buf: resb 24         ; each line
    heap: resb 170000      ; (16 (key) + ' ') * 10000 , 0x0 at tail
    heap_end: resq 1        ; heap free address
    matrix: resb 10000*14   ; (4 (val) + 2 (count) + 8 (key addr in heap)) * 10000
    matrix_end: resq 1      ; matrix free row address 
section .text
    global _start

_start:
    lea rax, [matrix]
    mov [matrix_end], rax
    lea rax, [heap]
    mov [heap_end], rax
    handle_entry:
        call read_line
        cmp byte [rcx], 0    ; is 0x0 ?
        jz proceed
        lea rbx, [rcx - 1]   ; number end

        push rbx  ;p
        call ascii_to_number
        push rax           ; value

        lea rcx, [buf + 1]
        sub rbx, rcx
        mov rcx, rbx
        inc rcx             ; length of key + 1 (' ')

        push rcx 
        push rcx ;p
        call parse_heap
        pop rcx
        cmp rax, 0
        jnz str_found
            push rcx ;p
            call add_heap_entry
            mov rbx, rax        ; key addr
            pop rax             ; value
            push rbx ;p
            push rax ;p
            call add_matrix_entry
            jmp handle_entry
        str_found:
            mov rbx, rax        ; key addr
            pop rax             ; value
            push rbx ;p
            push rax ;p
            call upd_matrix_entry
            jmp handle_entry
    proceed:
    call print_matrix
    jmp exit
    ;jmp number_write_test
    ;jmp write_test


read_line:
    ; returns:
    ; rcx - addr of line end
    push rbp
    mov rbp, rsp
    lea rcx, [buf]           ; address to pass to
    read_char:
        mov rbx, 0		         ; standard input
        mov rax, 3		         ; read
        mov rdx, 1		 ; input length 
        int 0x80
        cmp byte [rcx], 0x0A
        jz term_found
        cmp byte [rcx], 0
        jz term_found
        inc rcx
        jmp read_char

    term_found:
    leave
    ret

ascii_to_number:
    ; rbx - pointer on number end
    ; returns:
    ; the value in rax
    ; rbx points on number start
    pop rax ;r
    pop rbx
    push rax
    push rbp
    mov rbp, rsp
    xor rax, rax             ; return value
    xor rcx, rcx             ; counter
    
    ascii_to_number_loop:
        mov dl, byte [rbx]
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
        neg rax
        dec rbx
    ascii_to_number_end:
        inc rbx
        leave
        ret

compare_strs:
    ; rax and rbx, rcx - length
    ; returns:
    ; equal? 1 : 0 in rax
    pop rdx ;r
    pop rax
    pop rbx
    pop rcx
    push rdx
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
        mov rax, rdx
        leave
        ret

parse_heap:
    ;; compare <key> with each <line> of heap
    ; rcx - length of target
    ; returns:
    ; found? addr : 0 in rax
    pop rdx ;r
    pop rcx
    push rdx
    push rbp
    mov rbp, rsp
    push rcx
    lea rbx, [heap]     ; heap iterator
    compare_next:
        lea rax, [buf]      ; target
        mov rcx, [rsp]
        push rcx ;p
        push rbx ;p
        push rax ;p
        call compare_strs
        cmp rax, 1
        jz str_present
        cmp rbx, qword [heap_end]
        jz str_absent
        find_space:
            cmp byte [rbx], 0x20    ; ' '
            jz end_find_space
            inc rbx
            jmp find_space
        end_find_space:
        inc rbx
        cmp rbx, qword [heap_end]
        jz str_absent
        jmp compare_next
    str_present:
    mov rax, rbx            ; addr of match
    str_absent:
    leave
    ret

add_heap_entry:
    ; rcx - length
    ; returns:
    ; rax - addr
    pop rdx ;r
    pop rcx
    push rdx
    push rbp
    mov rbp, rsp

    lea rsi, [buf]
    lea rdi, [heap_end]
    lea rax, [heap_end]        ; str addr
    cld
    rep movsb
    inc rdi 
    mov qword [heap_end], rdi
    leave
    ret

add_matrix_entry:
    ; rax - value, rbx - key addr
    pop rdx
    pop rax
    pop rbx
    push rdx
    push rbp
    mov rbp, rsp
    
    lea rdx, [matrix_end]
    mov dword [rdx], eax
    mov word [rdx + 4], 1
    mov qword [rdx + 6], rbx
    add rdx, 14
    mov [matrix_end], rdx
    leave
    ret

upd_matrix_entry:
    ; rax - extra value, rbx - key addr
    pop rdx
    pop rax
    pop rbx
    push rdx
    push rbp
    mov rbp, rsp
    check_next:
        lea rcx, [matrix + 6]    ; first key's addr' start
        mov rdx, qword [rcx]
        cmp rdx, rbx
        jz entry_found
        add rcx, 14
        jmp check_next
    entry_found:
    mov edx, dword [rcx - 6]
    add rdx, rax                  ; val1 + val2
    mov dword [rcx - 6], edx
    mov edx, dword [rcx - 2]
    inc rdx                       ; count++
    mov dword [rcx - 2], edx
    leave
    ret

write_line:
    ; rax - line
    pop rdx
    pop rax
    push rdx
    push rbp
    mov rbp, rsp
    write_char:
        cmp byte [rax], ' '
        jz term_reached
        cmp byte [rax], 0x0A
        jz term_reached
        cmp byte [rax], 0
        jz term_reached
        push rax
        mov rax, 4           ; write
        mov rdx, 1           ; length of output 
        mov rcx, rax          ; address to the value
        mov rbx, 1           ; standard output
        int 0x80
        pop rax
        inc rax
        jmp write_char
    term_reached:
    leave
    ret

print_matrix:
    push rbp
    mov rbp, rsp
    lea rax, [matrix + 6]
    print_next:
        cmp rax, [matrix_end]
        jge all_printed
        mov rbx, [rax]
        add rax, 14
        push rax
        push rax
        call write_line
        pop rax
        jmp print_next
    all_printed:
    leave 
    ret
write_test:
    mov rax, 4           ; write
    mov rdx, [buf_size]           ; length of output 
    mov rcx, buf          ; address to the value
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