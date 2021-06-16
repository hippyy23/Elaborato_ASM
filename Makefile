DEBUG = -gstabs
FILENAME = postfix

all: bin/$(FILENAME)
	@echo Done!

bin/$(FILENAME):
	gcc $(DEBUG) -m32 src/main.c src/postfix.s -o bin/$(FILENAME)

# obj/$(FILENAME).o:
#	gcc $(DEBUG) -m32 -c src/postfix.s -o obj/postfix.o

#obj/main.o:
#	gcc $(DEBUG) -m32 -c src/main.c -o obj/main.o


cl:
	rm -f obj/* bin/*

ddd:
	ddd bin/$(FILENAME)

gdb:
	gdb bin/$(FILENAME)

run:
	bin/$(FILENAME) istanze/in_1.txt istanze/test.txt
