CC = gcc
AS = as
CFLAGS = -g -no-pie

main: main.o meuAlocador.o
	$(CC) $(CFLAGS) -o main main.o meuAlocador.o

meuAlocador.o: meuAlocador.s
	$(AS) $(CFLAGS) -c meuAlocador.s -o meuAlocador.o

main.o: main.c meuAlocador.h
	$(CC) $(CFLAGS) -c main.c -o main.o

clean:
	rm -rf ./*.o

purge:
	make clean
	rm -rf main