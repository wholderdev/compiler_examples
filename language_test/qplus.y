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
	struct Param *pstval;
}

%token T_BEGIN T_TASK T_START_BLOCK T_END_BLOCK T_END_OP T_START_PARAM T_END_PARAM T_PLUS_OP
%token<sval> T_STRING
%token<ival> T_INT

%left T_PLUS_OP

%type<sval> task
%type<ival> expression
%type<sval> id
%type<pstval> params

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
		printf("operation#1(%i)\n", $1);
		fprintf(output_file, "operation=(%i)\n\n", $1);
	}
;

expression:
	T_INT
	{
		$$ = $1;
		printf("expression#1(%i)\n", $$);
		fprintf(output_file, "(%i)\n", $$);
	}
	| id T_START_PARAM T_END_PARAM 
	{
		$$ = 0;
		printf("expression#2(%s, %i)\n", $1, $$);
	}
	| id T_START_PARAM params T_END_PARAM 
	{
		$$ = 0;
		printf("expression#3(%s, %i)\n", $1, $$);
	}
	| expression T_PLUS_OP expression
	{
		$$ = $1 + $3;
		printf("expression#4(%i)\n", $$);
		fprintf(output_file, "(%i + %i = %i)\n", $1, $3, $$);
	}
;

params:	
	expression
	{
		printf("params#1(%i)\n", $1);
		fprintf(output_file, "param=(%i)\n\n", $1);
		
		/*
		Param *temp_param = (Param *)malloc(sizeof(Param));
		temp_param->value = $1;
		$$ = temp_param;
		*/
	}
	| params expression
	{
		printf("params#2(%i)\n", $2);
		fprintf(output_file, "param=(%i)\n\n", $2);
		
		/*
		Param *temp_param = (Param *)malloc(sizeof(Param));
		temp_param->value = $2;
		temp_param->next = $1;
		$$ = temp_param;
		*/
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
	
	output_file = fopen("answer_output", "w");
	if (output_file == NULL) {
		perror("Failed to create output file: \"answer_output\"");
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
