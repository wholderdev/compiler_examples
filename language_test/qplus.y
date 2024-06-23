%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex(void);
extern int yyparse();
extern FILE* yyin;

void yyerror(const char *s);
%}

%union {
	char *sval;
}

%token T_TASK
%token<sval> T_ID
%token T_NEWLINE

%type<sval> identifier_e

%start program

%%

program:	
		| program line				{ printf("\n"); }
;

line:		T_NEWLINE				{ printf("line#1 "); }
		| task T_NEWLINE			{ printf("line#2 "); }
;

task:		T_TASK identifier_e			{ printf("task "); }
;

identifier_e:	T_ID					{ $$ = $1; printf("identifier_e(%s) ", $$); }
		| T_TASK				{ $$ = "task";  printf("itentifier_e(%s) ", $$); }
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
