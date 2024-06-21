%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex(void);
extern int yyparse();
extern FILE* yyin;

void yyerror(const char *s);
%}

%union {
	int ival;
}

%token<ival> T_INT
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT
%token T_NEWLINE T_QUIT
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE

%type<ival> int_expr

%start calculation

%%

calculation:
		| calculation line
;

line:		T_NEWLINE				{ printf("line\n\n"); }
		| int_expr T_NEWLINE			{ printf("line %i\n\n", $1); }
		| T_QUIT T_NEWLINE			{ printf("quitting\n\n"); exit(0); }
;

int_expr:	T_INT					{ $$ = $1; printf("T_INT\t%i\n", $1); }
		| int_expr T_PLUS int_expr		{ $$ = $1 + $3; printf("T_PLUS\t%i + %i = %i\n", $1, $3, $$); }
		| int_expr T_MINUS int_expr		{ $$ = $1 - $3; printf("T_MINUS\t%i + %i = %i\n", $1, $3, $$); }
		| int_expr T_MULTIPLY int_expr		{ $$ = $1 * $3; printf("T_MULTIPLY\t%i + %i = %i\n", $1, $3, $$); }
		| int_expr T_DIVIDE int_expr		{ $$ = $1 / $3; printf("T_DIVIDE\t%i + %i = %i\n", $1, $3, $$); }
		| T_LEFT int_expr T_RIGHT		{ $$ = $2; printf("PAREN\t(%i) = %i\n", $2, $$); }
;

%%

int main(void) {
	yyin = stdin;
	
	do {
		yyparse();
	} while(!feof(yyin));
	
	return 0;
}

void yyerror(const char *s) {
	fprintf(stderr, "Parse Error: %s\n", s);
	exit(1);
}
