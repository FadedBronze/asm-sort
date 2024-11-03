READ_BUFFER_SIZE equ 256
WRITE_BUFFER_SIZE equ 256

section .data
  newline db 10

section .bss
  result resq 100
  result_len resq 1

  read_buffer resb READ_BUFFER_SIZE
  read_buffer_len resq 1
  
  write_buffer resb WRITE_BUFFER_SIZE
  write_buffer_len resq 1

section .text
  global _start

ten_to_the_n:
  mov rcx, 0

ten_to_the_n_loop:
  cmp r9, rcx
  je ten_to_the_n_exit
  imul rax, rax, 10
  inc rcx
  jmp ten_to_the_n_loop

ten_to_the_n_exit:
  ret

parse:
  mov r8, -1
  cmp qword [read_buffer_len], 2
  jl parse_end
parse_reset:
  mov r9, 0
parse_loop:
  inc r8
  mov rdx, [read_buffer_len]
  sub rdx, 1
  sub rdx, r8
  mov rax, 0
  movzx rax, byte [read_buffer + rdx]

  cmp rax, 10
  je parse_reset
  cmp rax, 32
  je parse_reset
  cmp rax, '0'
  jl parse_reset
  cmp rax, '9'
  jg parse_reset
  sub rax, '0'
  cmp r9, 0
  jne parse_skip_inc
  add qword [result_len], 1
parse_skip_inc:
  call ten_to_the_n
  mov rcx, [result_len]
  add [8*rcx - 8 + result], rax

  inc r9
  cmp rdx, 0
  je parse_end
  jmp parse_loop
parse_end:
  ret

sort:
  mov rdx, -1

sort_out_loop:
  inc rdx
  mov rcx, rdx
  dec rcx

  cmp rdx, [result_len]
  je sort_exit
  
sort_in_loop:
  inc rcx
  
  cmp rcx, [result_len]
  je sort_out_loop

  mov rax, [result + 8*rdx]
  mov r8, [result + 8*rcx]
  cmp rax, r8
  jle sort_in_loop

  mov [result + 8*rcx], rax
  mov [result + 8*rdx], r8

  jmp sort_in_loop

sort_exit:
  ret

; rcx length
; r8 reversing bytes
reverse_bytes:
  push rbx

  mov rax, rcx
  mov rdx, 0
  mov rbx, 2
  div rbx

  mov rdx, -1

reverse_bytes_loop:
  inc rdx
  cmp rdx, rax
  je reverse_bytes_end

  mov rbx, rcx
  sub rbx, 1
  sub rbx, rdx

  movzx r10, byte [r8 + rdx]
  movzx r9, byte [r8 + rbx]

  mov [r8 + rbx], r10b
  mov [r8 + rdx], r9b
  
  jmp reverse_bytes_loop

reverse_bytes_end:
  pop rbx
  ret

; rax integer arguement
; r8 out paramter
; rcx length
format_integer:
  mov rcx, -1
  push rbx

format_integer_loop:
  inc rcx
  mov rbx, 10
  mov rdx, 0
 
  div rbx
  add rdx, '0'

  mov [r8 + rcx], rdx

  cmp rax, 0
  je format_integer_exit

  jmp format_integer_loop

format_integer_exit:
  inc rcx
  call reverse_bytes
  pop rbx
  ret


format_all:
  push rbx
  mov rbx, -1
  mov r8, write_buffer
  mov byte [write_buffer_len], 0

format_all_loop:
  inc rbx
  
  cmp rbx, [result_len]
  je format_all_exit

  mov rax, [result + 8*rbx]
  call format_integer

  inc rcx
  inc rcx

  add [write_buffer_len], rcx
  add r8, rcx
  mov [r8 - 1], byte 32

  jmp format_all_loop

format_all_exit:
  add [write_buffer_len], rcx

  mov rbx, [write_buffer_len]
  mov [write_buffer - 1 + rbx], byte 10

  mov rax, 1
  mov rdi, 1
  mov rsi, write_buffer
  mov rdx, [write_buffer_len]
  syscall

  pop rbx
  ret

_start:
  mov rax, 0
  mov rdi, 0
  mov rsi, read_buffer
  mov rdx, READ_BUFFER_SIZE
  syscall
  mov [read_buffer_len], rax

  call parse
  call sort
  call format_all

  mov rax, 60
  mov rdi, 0
  syscall
  ret
