build:
	nasm -felf64 main.asm
	ld main.o
run:
	./a.out
