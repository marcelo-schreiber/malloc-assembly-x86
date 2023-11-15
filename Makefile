all:
	gcc -c brk.s -o brk.o
	gcc -c main.c -o main.o
	gcc -o main main.o brk.o
clean:
	rm -f *.o main a.out
