flex example.l; bison -d example.y; gcc -o calculator example.tab.c lex.yy.c -lfl; ./calculator
