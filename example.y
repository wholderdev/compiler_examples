%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>;

int yylex(void);
void yyerror(const char *s);

%}

%union {
	int num;
}

%token <num> NUMBER

%type <num> expression

%%
expression:
	expression expression '+'  { $$ = $1 + $2; }
	| expression expression '-'  { $$ = $1 - $2; }
	| expression expression '*'  { $$ = $1 * $2; }
	| expression expression '/'  { $$ = $1 / $2; }
	| expression '\n'  { printf("%d\n", $1); }
	| NUMBER  { $$ = $1; }
	;
%%

int main(void) {
	return yyparse();
}

void yyerror(const char *s) {
	fprintf(stderr, "Error: %s\n", s);
}
