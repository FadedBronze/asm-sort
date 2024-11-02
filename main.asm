READ_BUFFER_SIZE equ 256

section .bss
  result resq 100
  result_len resq 1

  parse_start resq 1
  read_buffer resb READ_BUFFER_SIZE
  buffer_len resq 1

section .text
  global _start

; rax = rax * 10^rcx
; muts: rax rbx r8
log:
  mov rbx, 10
  mov r8, 0

log_loop:
  cmp r8, rcx
  jge log_end

  inc r8

  mul rbx ; *= number stored in rax

  jmp log_loop

log_end:
  ret

; can overflow rn

; parses from 'read_buffer' starting at 'parse_start'
; puts parsed number into 'result' + 'result_len' slot
; outputs stopped character as 'rcx'
; stops at newline or space
; muts: rax rbx rcx r8 r9
parse:
  mov rcx, 0

parse_loop: 
  mov r9, [parse_start]
  sub r9, rcx 

  movzx rax, byte [read_buffer + r9]
  
  cmp rax, 32
  je parse_exit

  cmp rax, 10
  je parse_exit

  cmp rax, '0'
  jl parse_error
  
  cmp rax, '9'
  jg parse_error
  
  sub rax, '0'

  call log

  mov r9, [result_len]
  add [result + 8*r9], rax
  
  inc rcx
  
  jmp parse_loop

parse_error:
  mov rax, -1
  ret

parse_exit:
  mov rax, 0
  ret

; fully populates result with numbers from buffer
; muts: rax rbx rcx r8 r9 r10
parse_all:
  mov qword [parse_start], 0
  
parse_all_loop:
  call parse
  inc rcx
  mov [parse_start], rcx

  add qword [result_len], 1

  mov rax, [parse_start]
  cmp rax, [buffer_len]
  jge parse_all_exit

  jmp parse_all_loop
  
parse_all_exit:
  ret

_start:
  mov rax, 0
  mov rdi, 0
  mov rsi, read_buffer
  mov rdx, READ_BUFFER_SIZE
  syscall
  mov [buffer_len], rax

  mov rax, 0
  mov [result_len], rax

  mov rax, [buffer_len]
  sub rax, 2
  mov [parse_start], rax

  call parse 

  mov rax, 60
  mov rdi, [result]
  syscall

  ret
