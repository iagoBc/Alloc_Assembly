all:
	as meuAlocador.s -o meuAlocador.o -g
	ld meuAlocador.o -o meuAlocador -dynamic-linker /lib64/ld-linux-x86-64.so.2 \
	/usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o \
	/usr/lib/x86_64-linux-gnu/crtn.o -lc

purge:
	rm *.o meuAlocador
