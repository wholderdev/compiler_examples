#ifndef QPLUS_STRUCTS_H
#define QPLUS_STRUCTS_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {
	NODE_NUM,
	NODE_OP,
	NODE_TASK,
	NODE_PARAM
} NodeType;

typedef enum {
	OP_ADD
} OpType;

typedef struct Program {
	struct Task *task_ll;
	struct Node *node_tree;
} Program;

typedef struct Task {
	char *name;
	// TODO: Signature with params and return
	struct Node *node_tree;
	struct Task *next;
} Task;

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
		} task_data; 
		struct {
			struct Node *self;
			struct Node *next;
		} param_data;
	} data;
} Node;


Program* create_program();
Task* create_task(const char *name);

Task* lookup_task(Program *param_prog, const char *name);
void free_program(Program *p_prog);
void free_tasks(Task *p_task);
void free_nodes(Node *p_node);

#endif // QPLUS_STRUCTS_H
