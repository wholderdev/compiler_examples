#ifndef QPLUS_STRUCTS_H
#define QPLUS_STRUCTS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
	NODE_INT,
	NODE_OP,
	NODE_TASK,
	NODE_PARAM,
	NODE_STMT
} NodeType;

typedef enum {
	OP_ADD
} OpType;

typedef struct Program {
	struct Task *task_ll;
} Program;

typedef struct Task {
	char *name;
	// TODO: Signature with params and return
	struct Block *block;
	struct Task *next;
} Task;

typedef struct Block {
	struct Statement *statement_ll;
} Block;

typedef struct Statement {
	struct Node *ast;
	struct Statement *next;
} Statement;

// TODO: Variable

typedef struct Node {
	NodeType type;
	union {
		int num;
		// TODO: Variables
		struct {
			OpType op;
			struct Node *left;
			struct Node *right;
		}  op_data;
		struct {
			Task *task;
			struct Node *params;
			const char *name;
		} task_data; 
		struct {
			struct Node *self;
			struct Node *next;
		} param_data;
	} data;
} Node;


Program* create_program();
Task* create_task(const char *name, Block *p_block);
Block* create_block(Statement *p_op);
Statement* create_statement_node(Node *ast, Statement *next);
Node* create_int_node(int value);
Node* create_op_node(OpType type, Node *left, Node *right);
Node* create_task_node(const char *name, Node *params);
Node* create_param_node(Node *self, Node *next);

void dry_compile(Program *p_prog);

//void print_block
void print_block(Block *p_block, FILE *output_file, int level);
void print_stmt_ll(Statement *p_stmt, FILE *output_file, int level);
void print_node(Node *p_node, FILE *output_file, int level);
void lazy_tab(FILE *output_file, int level);	

Task* lookup_task(Program *param_prog, const char *name);
void free_program(Program *p_prog);
void free_tasks(Task *p_task);
void free_block(Block *p_block);
void free_stmt_ll(Statement *p_stmt);
void free_nodes(Node *p_node);

#endif // QPLUS_STRUCTS_H
