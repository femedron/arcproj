section .data
    buf_size: db 24    ; 16 (key) + 1 (' ') + 6 (val) + 1 (0x0A)
    NEW_LINE: db 0x0a
section .bss
    buf: resb 24         ; each line
    heap: resb 170000      ; (16 (key) + ' ') * 10000 , 0x0 at tail
    heap_end: resq 1        ; heap free address
    matrix: resb 10000*14   ; (4 (val) + 2 (count) + 8 (key addr in heap)) * 10000
    matrix_end: resq 1      ; matrix free row address 
    entries: resq 10000     ; pointers to matrix entries (used for sorting) 
    entries_end: resq 1
section .text
    global _start

_start:
    init:
        lea rax, [matrix]
        mov [matrix_end], rax
        lea rax, [heap]
        mov [heap_end], rax
        lea rax, [entries]
        mov [entries_end], rax
        mov rax, 1
        push rax                
    handle_entry:
        pop rax
        or rax, rax         ; continue flag
        jz proceed

        call read_line
        or rax, rax         ; 0 if ends with 0x0
        jnz entry_present
            cmp rcx, buf     ; 0 if only 0x0
            jz proceed
                ; line ends with 0x0
                xor rax, rax      ; clear continue flag
        entry_present:
        push rax        
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
    call calc_avg
    call sort
    call print_keys
    jmp exit

read_line:
    ; returns:
    ; rcx - addr of line end
    ; rax - (last byte == 0x0)? 0 : 1
    push rbp
    mov rbp, rsp
    lea rcx, [buf]           ; address to pass to
    read_char:
        mov rbx, 0		         ; standard input
        mov rax, 3		         ; read
        mov rdx, 1		 ; input length 
        int 0x80
        or rax, rax         ; number of bytes read, 0 if read 0x0
        jz term_found       
        cmp byte [rcx], 0x0A
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
        xor rdx, rdx
        mov dl, byte [rbx]
        cmp dl, ' '
        jz ascii_to_number_end
        cmp dl, '-'
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
    mov rdi, qword [heap_end]
    mov rax, rdi        ; str addr
    cld
    rep movsb
    mov qword [heap_end], rdi     ; point to free space
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
    
    ; put entry address in entries[]
    mov rdx, qword [matrix_end]
    mov rcx, qword [entries_end]
    mov qword [rcx], rdx            
    add rcx, 8
    mov qword [entries_end], rcx
    ; set entry
    mov dword [rdx], eax            
    mov word [rdx + 4], 1
    mov qword [rdx + 6], rbx
    add rdx, 14
    mov qword [matrix_end], rdx
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
    lea rcx, [matrix + 6]    ; first key's addr' start
    check_next:
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
        mov rcx, rax          ; address to the value
        mov rax, 4           ; write
        mov rdx, 1           ; length of output 
        mov rbx, 1           ; standard output
        int 0x80
        pop rax
        inc rax
        jmp write_char
    term_reached:
    mov rcx, NEW_LINE          ; address to the value
    mov rax, 4           ; write
    mov rdx, 1           ; length of output 
    mov rbx, 1           ; standard output
    int 0x80
    leave
    ret

print_keys:
    push rbp
    mov rbp, rsp
    lea rax, [entries]
    print_next:
        cmp rax, qword [entries_end]
        jge all_printed
        mov rbx, qword [rax]        ; matrix entry
        add rbx, 6
        mov rbx, qword [rbx]        ; key string
        add rax, 8                  ; entry pointer length  
        push rax
        push rbx
        call write_line
        pop rax
        jmp print_next
    all_printed:
    leave 
    ret

calc_avg:
    lea rbx, [matrix]
    calc_next:
        cmp rbx, qword [matrix_end]
        jge avg_done
        xor rax, rax
        xor rcx, rcx
        mov eax, dword [rbx]        ; value
        mov cx, word [rbx+4]       ; count
        cdq 
        idiv ecx
        mov dword [rbx], eax        ; avg
        add rbx, 14                ; matrix entry length
        jmp calc_next
    avg_done:
    ret

sort:
    mov rax, qword [entries_end]
    mov rbx, entries
    sub rax, rbx
    mov rcx, 8
    cqo
    div rcx  ; entry count
    mov rcx, rax
    dec rcx  ; count-1
    jz end_sort
    outerLoop:
        push rcx
        lea rsi, entries
    innerLoop:
        mov rax, qword [rsi]    ; entry
        mov edx, dword [rax]    ; avg 
        mov rbx, qword [rsi+8]    ; next entry
        cmp edx, dword [rbx]
        jge nextStep
        mov qword [rsi], rbx    ; switch in entries[]
        mov qword [rsi+8], rax
    nextStep:
        add rsi, 8
        loop innerLoop
        pop rcx
        loop outerLoop
    end_sort:
    ret
exit:
    mov rax, 1
    xor rbx, rbx
    int 0x80