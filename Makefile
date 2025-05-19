EX = main
C = avalia
CC = gcc
AS = as
CFLAGS = -g -no-pie

main: $(C).o meuAlocador.o
	$(CC) $(CFLAGS) -o $(EX) $(C).o meuAlocador.o

meuAlocador.o: meuAlocador.s
	$(AS) $(CFLAGS) -c meuAlocador.s -o meuAlocador.o

main.o: $(C).c meuAlocador.h
	$(CC) $(CFLAGS) -c $(C).c -o $(C).o

clean:
	rm *.o

purge:
	make clean
	rm $(EX)