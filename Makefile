CC = gcc
AS = as
CFLAGS = -g -no-pie
LFLAGS = -lm

main: main.o memalloc.o
	$(CC) $(CFLAGS) -o main main.o memalloc.o $(LFLAGS)

memalloc.o: memalloc.s
	$(AS) $(CFLAGS) -c memalloc.s -o memalloc.o

main.o: main.c memalloc.h
	$(CC) $(CFLAGS) -c main.c -o main.o

clean:
	rm -f *.o main

purge: clean
	rm ./main

test: main
		./main