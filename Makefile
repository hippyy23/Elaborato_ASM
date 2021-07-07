DEBUG = -gstabs
FLAG = -m32
FILENAME = postfix
INPUT = istanze/in_1.txt
OUTPUT = istanze/out.txt

all: bin/$(FILENAME)
	@echo Done!

bin/$(FILENAME): obj/$(FILENAME).o
	gcc $(DEBUG) $(FLAG) obj/postfix.o obj/main.o -o bin/$(FILENAME)

obj/$(FILENAME).o: obj/main.o
	gcc $(DEBUG) $(FLAG) -c src/postfix.s -o obj/postfix.o

obj/main.o:
	gcc $(DEBUG) $(FLAG) -c src/main.c -o obj/main.o

cl:
	rm -f obj/* bin/*

ddd:
	ddd bin/$(FILENAME)

gdb:
	gdb bin/$(FILENAME)

run:
	bin/$(FILENAME) $(INPUT) $(OUTPUT)
