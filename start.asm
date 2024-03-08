global _start
section .data
 variable: db 0
        ; Align to the nearest 2 byte boundary, must be a power of two
        ;align 2
        ; String, which is just a collection of bytes, 0xA is newline
        ;str:     db 'Hello, world!',0xA
        ;strLen:  equ $-str
section .bss
 buf: resb 1 
section .text
_start:
 ;jmp dbg_write
 read_next:
  ; read a byte from stdin
  mov eax, 3		 ; 3 is recognized by the system as meaning "read"
  mov ebx, 0		 ; read from standard input
  mov ecx, buf        ; address to pass to
  mov edx, 1		 ; input length (one byte)
  int 0x80                 ; call the kernel
  ;jnz read_next

 ;dbg_write:
  
 write_next:
  mov eax, 4           ; the system interprets 4 as "write"
  mov ebx, 1           ; standard output (print to terminal)
  mov ecx, buf    ; pointer to the value being passed
  mov edx, 1           ; length of output (in bytes)
  int 0x80             ; call the kernel
 mov eax, 1
 int 0x80