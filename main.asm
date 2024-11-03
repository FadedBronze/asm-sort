READ_BUFFER_SIZE equ 256

section .bss
  result resq 100
  result_len resq 1

  read_buffer resb READ_BUFFER_SIZE
  buffer_len resq 1

section .text
  global _start

; n: rax
ten_to_the_n:
  mov rbx, 10
  mov rcx, 0

ten_to_the_n_loop:
  cmp rax, rcx
  je ten_to_the_n_exit
  mul rbx
  jmp ten_to_the_n_loop

ten_to_the_n_exit:
  mov rbx, 0
  mov rcx, 0
  ret

parse:
  mov r8, -1
parse_reset:
  mov r9, 0
parse_loop:
  inc r8
  mov rax, [buffer_len]
  sub rax, 1
  sub rax, r8
  cmp byte [read_buffer + rax], 10
  je parse_reset
  cmp byte [read_buffer + rax], 32
  je parse_reset
  cmp r9, 0
  jne parse_skip_inc
  add qword [result_len], 1
parse_skip_inc:
  inc r9
  cmp rax, 0
  je parse_end
  jmp parse_loop
parse_end:
  ret

_start:
  mov rax, 0
  mov rdi, 0
  mov rsi, read_buffer
  mov rdx, READ_BUFFER_SIZE
  syscall
  mov [buffer_len], rax
  call parse
  mov rax, 60
  mov rdi, [result_len]
  syscall
  ret
