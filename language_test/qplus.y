%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex(void);
extern int yyparse();

extern FILE* yyin;

void yyerror(const char *s);

FILE *output_file;
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

%type<sval> task
%type<sval> task_call
%type<ival> expression

%start program

%%

program:
        /* empty */
	{
		printf("program#1\n");
		fprintf(output_file, "program#1\n");
	}
	| program task
	{
		printf("program#2\n");
		fprintf(output_file, "program#2\n");
	}
;

task:
	T_BEGIN block
	{
		$$ = "BEGIN";
		printf("task#1(BEGIN)\n");
		fprintf(output_file, "task#1\n");
	}
	| T_TASK T_ID block
	{
		$$ = $2;
		printf("task#2(%s)\n", $$);
		fprintf(output_file, "task#2(%s)\n", $$);
	}
;

block:
	T_START_BLOCK operations T_END_BLOCK
	{
		printf("block\n");
		fprintf(output_file, "block\n");
	}
;

operations:
	operation
	{
		printf("operations#1\n");
		fprintf(output_file, "operations#1\n");
	}
	| operations operation
	{
		printf("operations#2\n");
		fprintf(output_file, "operations#2\n");
	}
;

operation:
	expression T_END_OP
	{
		printf("operation#1\n");
		fprintf(output_file, "operation#1\n");
	}
	| task_call T_END_OP
	{
		printf("operation#2\n");
		fprintf(output_file, "operation#2\n");
	}
;

expression:
	T_INT
	{
		$$ = $1;
		printf("expression#1(%i)\n", $$);
		fprintf(output_file, "expression#1(%i)\n", $$);
	}
	| expression T_PLUS_OP expression
	{
		$$ = $1 + $3;
		printf("expression#2(%i + %i = %i)\n", $1, $3, $$);
		fprintf(output_file, "expression#2(%i + %i = %i)\n", $1, $3, $$);
	}
;

task_call:
	T_ID T_START_PARAM T_END_PARAM 
	{
		$$ = $1;
		printf("task_call(%s)\n", $$);
		fprintf(output_file, "task_call(%s)\n", $$);
	}
;

%%

int main(void) {
	yyin = stdin;
	
	output_file = fopen("output_qplus_test", "w");
	if (output_file == NULL) {
		perror("Failed to create output file: \"output_qplus_test\"");
		return 1;
	}
	
	do {
		yyparse();
	} while(!feof(yyin));
	
	fclose(output_file);
	
	return 0;
}

void yyerror(const char *s) {
	fprintf(stderr, "Parse Error: %s\n", s);
	exit(1);
}
