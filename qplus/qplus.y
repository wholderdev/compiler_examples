%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "qplus_structs.h"

extern int yylex(void);
extern int yyparse();

extern FILE* yyin;

void yyerror(const char *s);

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

%token T_BEGIN T_TASK T_START_BLOCK T_END_BLOCK T_ASSIGN T_END_STMT T_START_PARAM T_END_PARAM T_PLUS_OP
%token<sval> T_STRING
%token<ival> T_INT

%left T_PLUS_OP

%type<taskval> task
%type<blockval> block
%type<opval> statements
%type<nodeval> assignment
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
	| T_TASK T_STRING block
	{
		printf("task#2(%s)\n", $2);
		$$ = create_task($2, $3);
	}
;

/*
	A flaws with this approach:
		A block might make more sense as an expression, since having
		nested blocks is possible in a lot of programming languages.

*/
block:
	T_START_BLOCK statements T_END_BLOCK
	{
		printf("block\n");
		$$ = create_block($2);
	}
;

statements:
	expression T_END_STMT
	{
		printf("statements#1\n");
		$$ = create_statement_node($1, NULL);
	}
	| assignment T_END_STMT
	{
		printf("statement#2\n");
		$$ = create_statement_node($1, NULL);
	}
	| statements expression T_END_STMT
	{
		printf("statements#3\n");
		$$ = create_statement_node($2, $1);
	}
	| statements assignment T_END_STMT
	{
		printf("statements#4\n");
		$$ = create_statement_node($2, $1);
	}
;

assignment:
	T_STRING T_ASSIGN expression
	{
		printf("assignment(%s)\n", $1);
		$$ = create_assign_node($1, $3);
	}
;

expression:
	T_INT
	{
		printf("expression#1(%i)\n", $1);
		$$ = create_int_node($1);
	}
	| T_STRING T_START_PARAM T_END_PARAM 
	{
		printf("expression#2\n");
		$$ = create_task_node($1, NULL);
	}
	| T_STRING T_START_PARAM params T_END_PARAM 
	{
		printf("expression#3\n");
		$$ = create_task_node($1, $3);
	}
	| T_STRING
	{
		printf("expression#4\n");
		$$ = create_var_node($1);
	}
	| expression T_PLUS_OP expression
	{
		printf("expression#5\n");
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

%%

int main(void) {
	yyin = stdin;
	
	do {
		yyparse();
	} while(!feof(yyin));

	// ----- OUTPUT TABLES -----
	FILE *output_tables;
	output_tables = fopen("output_files/tables", "w");
	if (output_tables == NULL) {
		perror("Failed to create output file: \"output_files/tables\"");
		return 1;
	}
	
	print_tables(output_tables);
	
	// ----- OUTPUT TREE -----
	FILE *output_tree;
	output_tree = fopen("output_files/tree", "w");
	if (output_tree == NULL) {
		perror("Failed to create output file: \"output_files/tree\"");
		return 1;
	}
	
	print_program(prog, output_tree, 0);
	
	
	// ----- OUTPUT REVERSE -----
	FILE *output_reverse;
	output_reverse = fopen("output_files/reverse", "w");
	if (output_reverse == NULL) {
		perror("Failed to create output file: \"output_files/reverse\"");
		return 1;
	}
	
	reverse_program(prog, output_reverse, 0);
	
	FILE *output_pseudoasm;
	output_pseudoasm = fopen("output_files/pseudoasm", "w");
	if (output_pseudoasm == NULL) {
		perror("Failed to create output file: \"output_files/pseudoasm\"");
		return 1;
	}
	pseudoasm_program(prog, output_pseudoasm, 0);
	
	free_program(prog);
	fclose(output_tables);
	fclose(output_tree);
	fclose(output_reverse);
	fclose(output_pseudoasm);
	
	return 0;
}

void yyerror(const char *s) {
	fprintf(stderr, "Parse Error: %s\n", s);
	exit(1);
}
