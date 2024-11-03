READ_BUFFER_SIZE equ 256

section .bss
  result resq 100
  result_len resq 1

  read_buffer resb READ_BUFFER_SIZE
  buffer_len resq 1

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
  cmp qword [buffer_len], 2
  jl parse_end
parse_reset:
  mov r9, 0
parse_loop:
  inc r8
  mov rdx, [buffer_len]
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

_start:
  mov rax, 0
  mov rdi, 0
  mov rsi, read_buffer
  mov rdx, READ_BUFFER_SIZE
  syscall
  mov [buffer_len], rax

  call parse
  call sort

  mov rax, 60
  mov rdi, [result]
  syscall
  ret
