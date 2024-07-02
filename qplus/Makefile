all: qplus

qplus.tab.c qplus.tab.h:	qplus.y
	bison -t -v -d qplus.y

lex.yy.c: qplus.l qplus.tab.h
	flex qplus.l


qplus: lex.yy.c qplus.tab.c qplus.tab.h
	gcc -o qplus qplus.tab.c lex.yy.c qplus_structs.c

clean:
	rm qplus qplus.tab.c lex.yy.c qplus.tab.h qplus.output
