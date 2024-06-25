%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern int yyparse();

extern FILE* yyin;

void yyerror(const char *s);

FILE *output_file;

// TODO: Add to separate .c .h files
typedef struct Program {
	struct Task *top_task;
} Program;

typedef struct Task {
	char *name;
	struct Task *next;
} Task;

Program *cur_prog;
Task *cur_task;

%}

%define parse.error verbose

%union {
	char *sval;
	int ival;
}

%token T_BEGIN T_TASK T_START_BLOCK T_END_BLOCK T_END_OP T_START_PARAM T_END_PARAM T_PLUS_OP
%token<sval> T_STRING
%token<ival> T_INT

%left T_PLUS_OP

%type<sval> task
%type<sval> task_call
%type<ival> expression
%type<sval> id

%start program

%%

program:
        /* empty */
	{
		printf("program#1\n");
		cur_prog = (Program *)malloc(sizeof(Program));
	}
	| program task
	{
		printf("program#2\n");
	}
;

task:
	T_BEGIN block
	{
		if(cur_prog->top_task) {
			Task *temp_task = (Task *)malloc(sizeof(Task));
			cur_task->next = temp_task;
			cur_task = temp_task;
		}
		else {
			cur_task = (Task *)malloc(sizeof(Task));
			cur_prog->top_task = cur_task;
		}
		
		$$ = "BEGIN";
		cur_task->name = strdup($$);
		
		printf("task#1(BEGIN)\n");
	}
	| T_TASK id block
	{
		// TODO: Redundant, needs a function
		if(cur_prog->top_task) {
			Task *temp_task = (Task *)malloc(sizeof(Task));
			cur_task->next = temp_task;
			cur_task = temp_task;
		}
		else {
			cur_task = (Task *)malloc(sizeof(Task));
			cur_prog->top_task = cur_task;
		}
		
		$$ = $2;
		cur_task->name = strdup($$);
		
		printf("task#2(%s)\n", $$);
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
		fprintf(output_file, "(%i)\n", $$);
	}
	| expression T_PLUS_OP expression
	{
		$$ = $1 + $3;
		printf("expression#1(%i)\n", $$);
		fprintf(output_file, "(%i + %i = %i)\n", $1, $3, $$);
	}
;

task_call:
	id T_START_PARAM T_END_PARAM 
	{
		$$ = $1;
		printf("task_call#1(%s)\n", $$);
	}
	| id T_START_PARAM params T_END_PARAM 
	{
		$$ = $1;
		printf("task_call#2(%s)\n", $$);
	}
;

params:	
	expression
	{
		printf("params#1(%i)\n", $1);
		fprintf(output_file, "param=(%i)\n\n", $1);
	}
	| params expression
	{
		printf("params#2(%i)\n", $2);
		fprintf(output_file, "param=(%i)\n\n", $2);
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
	Task *task_topr = cur_prog->top_task;
	while(task_topr) {
		printf("\t%s\n", task_topr->name);
		fprintf(output_file, "\t%s\n", task_topr->name);
		task_topr = task_topr->next;
	}
	
	fclose(output_file);
	
	return 0;
}

void yyerror(const char *s) {
	fprintf(stderr, "Parse Error: %s\n", s);
	exit(1);
}
