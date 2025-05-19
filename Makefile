EX = main
ARQC = avalia
CC = gcc
AS = as
CFLAGS = -g -no-pie

main: $(ARQC).o meuAlocador.o
	$(CC) $(CFLAGS) -o $(EX) $(ARQC).o meuAlocador.o

meuAlocador.o: meuAlocador.s
	$(AS) $(CFLAGS) -c meuAlocador.s -o meuAlocador.o

main.o: $(ARQC).c meuAlocador.h
	$(CC) $(CFLAGS) -c $(ARQC).c -o $(ARQC).o

clean:
	@rm -f *~ *.o

purge:   clean
	@rm -f $(EX)
