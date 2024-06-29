%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "qplus_structs.h"

extern int yylex(void);
extern int yyparse();

extern FILE* yyin;

void yyerror(const char *s);

FILE *output_file;

Program *prog;
%}

%define parse.error verbose

%union {
	char *sval;
	int ival;
	struct Task *taskval;
	struct Node *nodeval;
	struct Block *blockval;
	struct Statement *opval;
}

%token T_BEGIN T_TASK T_START_BLOCK T_END_BLOCK T_END_OP T_START_PARAM T_END_PARAM T_PLUS_OP
%token<sval> T_STRING
%token<ival> T_INT

%left T_PLUS_OP

%type<taskval> task
%type<blockval> block
%type<opval> statements
%type<nodeval> expression
%type<nodeval> params
%type<sval> id

%start program

%%

program:
        /* empty */
	{
		printf("program#1\n");
		prog = create_program();
	}
	| program task
	{
		printf("program#2\n");
		if(prog->task_ll) {
			$2->next = prog->task_ll;
		}
		prog->task_ll = $2;
	}
;

task:
	T_BEGIN block
	{
		printf("task#1(BEGIN)\n");
		$$ = create_task("BEGIN", $2);
	}
	| T_TASK id block
	{
		printf("task#2(%s)\n", $2);
		$$ = create_task($2, $3);
	}
;

/*
	A flaws with this approach:
		A block would make more sense as an expression, since having
		nested blocks is possible in a lot of programming languages.

*/
block:
	T_START_BLOCK statements T_END_BLOCK
	{
		printf("block\n");
		$$ = create_block($2);
		print_block($$, output_file, 0);
	}
;

statements:
	expression T_END_OP
	{
		printf("statements#1\n");
		$$ = create_statement_node($1, NULL);
	}
	| statements expression T_END_OP
	{
		printf("statements#2\n");
		$$ = create_statement_node($2, $1);
	}
;

expression:
	T_INT
	{
		printf("expression#1(%i)\n", $1);
		$$ = create_int_node($1);
	}
	| id T_START_PARAM T_END_PARAM 
	{
		printf("expression#2\n");
		$$ = create_task_node($1, NULL);
	}
	| id T_START_PARAM params T_END_PARAM 
	{
		printf("expression#3\n");
		$$ = create_task_node($1, $3);
	}
	| expression T_PLUS_OP expression
	{
		printf("expression#4\n");
		$$ = create_op_node(OP_ADD, $1, $3);
	}
;

params:	
	expression
	{
		printf("params#1\n");
		$$ = create_param_node($1, NULL);
	}
	| params expression
	{
		printf("params#2\n");
		$$ = create_param_node($2, $1);
	}
;

id:
	T_STRING
	{
		printf("id(%s)\n", $1);
		$$ = $1;
	}
;

%%

int main(void) {
	yyin = stdin;
	
	output_file = fopen("output_answer", "w");
	if (output_file == NULL) {
		perror("Failed to create output file: \"output_answer\"");
		return 1;
	}
	
	do {
		yyparse();
	} while(!feof(yyin));
	
	printf("\nTASK LIST:\n");
	fprintf(output_file, "\nTASK LIST\n");
	Task *task_topr = prog->task_ll;
	while(task_topr) {
		printf("\t%s\n", task_topr->name);
		fprintf(output_file, "\t%s\n", task_topr->name);
		task_topr = task_topr->next;
	}
	
	free_program(prog);
	fclose(output_file);
	
	return 0;
}

void yyerror(const char *s) {
	fprintf(stderr, "Parse Error: %s\n", s);
	exit(1);
}
