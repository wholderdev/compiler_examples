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

line:		T_NEWLINE				{ printf("T_NEWLINE\n"); }
		| int_expr T_NEWLINE			{ printf("int_expr(%i) T_NEWLINE\n", $1); }
		| T_QUIT T_NEWLINE			{ printf("quitting\n"); exit(0); }
;

int_expr:	T_INT					{ $$ = $1; printf("T_INT(%i) ", $1); }
		| int_expr T_PLUS int_expr		{ $$ = $1 + $3; printf("T_PLUS(%i) ", $$); }
		| int_expr T_MINUS int_expr		{ $$ = $1 - $3; printf("T_MINUS(%i) ", $$); }
		| int_expr T_MULTIPLY int_expr		{ $$ = $1 * $3; printf("T_MULTIPLY(%i) ", $$); }
		| int_expr T_DIVIDE int_expr		{ $$ = $1 / $3; printf("T_DIVIDE(%i) ", $$); }
		| T_LEFT int_expr T_RIGHT		{ $$ = $2; printf("PAREN(%i) ", $$); }
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
