#!/usr/bin/zsh

if [ $1 = "d" ]; then  
	nasm -g -F dwarf -felf64 ./src/start.asm -o ./bin/obj/start.o 
	ld ./bin/obj/start.o -o ./bin/out/start
	gdb ./bin/out/start 
else if [ $1 = "r" ]; then  
	nasm -felf64 ./src/start.asm -o ./bin/obj/start.o 
	ld ./bin/obj/start.o -o ./bin/out/start
	./bin/out/start
else
	./bin/out/start
fi
fi
