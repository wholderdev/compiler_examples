all: example

example.tab.c example.tab.h:	example.y
	bison -t -v -d example.y

lex.yy.c: example.l example.tab.h
	flex example.l


example: lex.yy.c example.tab.c example.tab.h
	gcc -o example example.tab.c lex.yy.c

clean:
	rm example example.tab.c lex.yy.c example.tab.h example.output
