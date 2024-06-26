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
Task *cur_task;
%}

%define parse.error verbose

%union {
	char *sval;
	int ival;
	struct Node *nodeval;
}

%token T_BEGIN T_TASK T_START_BLOCK T_END_BLOCK T_END_OP T_START_PARAM T_END_PARAM T_PLUS_OP
%token<sval> T_STRING
%token<ival> T_INT

%left T_PLUS_OP

%type<sval> task
%type<sval> id
%type<nodeval> operation
%type<nodeval> expression
%type<nodeval> params

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
	}
;

task:
	T_BEGIN block
	{
		$$ = "BEGIN";
		printf("task#1(BEGIN)\n");
		
		Task *temp_task = create_task($$);
		if(prog->task_ll) {
			cur_task->next = temp_task;
			cur_task = temp_task;
		}
		else {
			cur_task = temp_task;
			prog->task_ll = cur_task;
		}
	}
	| T_TASK id block
	{
		$$ = $2;
		printf("task#2(%s)\n", $$);
		
		Task *temp_task = create_task($$);
		if(prog->task_ll) {
			cur_task->next = temp_task;
			cur_task = temp_task;
		}
		else {
			cur_task = temp_task;
			prog->task_ll = cur_task;
		}
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
	| operations operation
	{
		printf("operations#2\n");
	}
;

operation:
	expression T_END_OP
	{
		$$ = $1;
		print_node($$, output_file, 0);
		printf("operation\n");
	}
;

expression:
	T_INT
	{
		$$ = create_int_node($1);
		printf("expression#1(%i)\n", $1);
	}
	| id T_START_PARAM T_END_PARAM 
	{
		$$ = create_task_node($1, NULL);
		printf("expression#2\n");
	}
	| id T_START_PARAM params T_END_PARAM 
	{
		$$ = create_task_node($1, $3);
		printf("expression#3\n");
	}
	| expression T_PLUS_OP expression
	{
		$$ = create_op_node(OP_ADD, $1, $3);
		printf("expression#4\n");
	}
;

params:	
	expression
	{
		$$ = create_param_node($1, NULL);
		printf("params#1\n");
	}
	| params expression
	{
		$$ = create_param_node($2, $1);
		printf("params#2\n");
	}
;

id:
	T_STRING
	{
		$$ = $1;
		printf("id(%s)\n", $$);
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
