%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex(void);
extern int yyparse();
extern FILE* yyin;

void yyerror(const char *s);
%}

%define parse.error verbose

%union {
	char *sval;
	int ival;
}

%token T_BEGIN T_TASK T_START_BLOCK T_END_BLOCK T_END_OP T_START_PARAM T_END_PARAM T_PLUS_OP
%token<sval> T_ID
%token<ival> T_INT

%left T_PLUS_OP

%type<sval> identifier
%type<sval> task_call
%type<ival> expression

%start program

%%

program:
        /* empty */
	{
		printf("program#1\n");
	}
	| program task
	{
		printf("program#2\n");
	}
;

task:
	T_TASK identifier block
	{
		printf("task#1\n");
	}
	| T_BEGIN block
	{
		printf("task#2\n");
	}
;

block:
	T_START_BLOCK operations T_END_BLOCK
	{
		printf("block\n");
	}
;

operations:
	operation
	{
		printf("operations#1\n");
	}
	| operation operations
	{
		printf("operations#2\n");
	}
;

operation:
	expression T_END_OP
	{
		printf("operation#1\n");
	}
	| task_call T_END_OP
	{
		printf("operation#2\n");
	}
;

expression:
	T_INT
	{
		$$ = $1;
		printf("expression#1(%i)\n", $$);
	}
	| expression T_PLUS_OP expression
	{
		$$ = $1 + $3;
		printf("expression#2(%i + %i = %i)\n", $1, $3, $$);
	}
;

task_call:
	identifier T_START_PARAM T_END_PARAM 
	{
		$$ = $1;
		printf("task_call(%s)\n", $$);
	}
;

identifier:
	T_ID
	{
		$$ = $1;
		printf("identifier(%s)\n", $$);
	}
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
