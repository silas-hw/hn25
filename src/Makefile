make game.sfc: main.asm init.asm regs.inc.asm macros.inc.asm variables.asm header.asm lorom256.cfg assets/*
	ca65 main.asm -o main.o -g
	ld65 -C lorom256.cfg main.o -o game.sfc -Ln labels.txt  
