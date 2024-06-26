#include "qplus_structs.h"

Program* create_program() {
	Program *cur_prog = (Program *)malloc(sizeof(Program));
	return cur_prog;
}

Task* create_task(const char *name, Block *p_block) {
	Task *new_task = (Task *)malloc(sizeof(Task));
	new_task->name = strdup(name);
	new_task->block = p_block;
	
	return new_task;
}

Block* create_block(Operation *p_op) {
	Block *new_block = (Block *)malloc(sizeof(Block));
	new_block->operation_ll = p_op;
	
	return new_block;
}

Operation* create_operation(Node *ast, Operation *next) {
	Operation *new_operation = (Operation *)malloc(sizeof(Operation));
	new_operation->ast = ast;
	new_operation->next = next;
	
	return new_operation;
}

Node* create_int_node(int value) {
	Node* new_node = (Node *)malloc(sizeof(Node));
	new_node->type = NODE_INT;
	new_node->data.num = value;
	printf("\t\tINT(%i)\n", value);
	printf("\t\tINTCONV(%i)\n", new_node->data.num);
	
	return new_node;
}

Node* create_op_node(OpType type, Node *left, Node *right) {
	Node* new_node = (Node *)malloc(sizeof(Node));
	new_node->type = NODE_OP;
	switch(type) {
		case OP_ADD:
			new_node->data.op_data.op = type;
			new_node->data.op_data.left = left;
			new_node->data.op_data.right = right;
			break;
	}
	
	return new_node;
}

Node* create_task_node(const char *name, Node *params) {
	Node* new_node = (Node *)malloc(sizeof(Node));
	new_node->type = NODE_TASK;
	new_node->data.task_data.name = name;
	new_node->data.task_data.params = params;
	
	return new_node;
}

Node* create_param_node(Node *self, Node *next) {
	Node* new_node = (Node *)malloc(sizeof(Node));
	new_node->type = NODE_PARAM;
	new_node->data.param_data.self = self;
	new_node->data.param_data.next = next;
	
	return new_node;
}

void print_oper_ll(Operation *p_oper, FILE *output_file, int level) {
	lazy_tab(output_file, level);
	fprintf(output_file, "OPERATIONS\n");
	while(p_oper) {
		print_node(p_oper->ast, output_file, level + 1);
		p_oper = p_oper->next;
	}	
}

void print_node(Node *p_node, FILE *output_file, int level) {
	switch(p_node->type) {
		case NODE_INT:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_INT\n");
			lazy_tab(output_file, level);
			fprintf(output_file, "\tvalue(%i)\n", p_node->data.num);
			break;
		case NODE_OP:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_OP\n");
			lazy_tab(output_file, level);
			switch(p_node->data.op_data.op) {
				case OP_ADD:
				fprintf(output_file, "\toptype(OP_ADD)\n");
					break;
			}

			lazy_tab(output_file, level);
			fprintf(output_file, "\tleft\n");
			if(p_node->data.op_data.left) {
				print_node(p_node->data.op_data.left, output_file,
					level + 1);
			}
			else {
				fprintf(output_file, "\tNULL\n");
			}

			lazy_tab(output_file, level);
			fprintf(output_file, "\tright\n");
			if(p_node->data.op_data.right) {
				print_node(p_node->data.op_data.right, output_file,
					level + 1);
			}
			else {
				fprintf(output_file, "\tNULL\n");
			}
			break;
		case NODE_TASK:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_TASK\n");
			lazy_tab(output_file, level);
			fprintf(output_file, "\tname(%s)\n", p_node->data.task_data.name);
			if(p_node->data.task_data.params) {
				print_node(p_node->data.task_data.params, output_file,
					level + 1);
			}
			break;
		case NODE_PARAM:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_PARAM\n");
			if(p_node->data.param_data.self) {
				print_node(p_node->data.param_data.self, output_file,
					level + 1);
			}
			if(p_node->data.param_data.next) {
				print_node(p_node->data.param_data.next, output_file,
					level + 1);
			}
			break;
	}
	return;
}

void lazy_tab(FILE *output_file, int level) {	
	for(int i = 0; i < level; i++) {
		fprintf(output_file, "\t");
	}
}

Task* lookup_task(Program *param_prog, const char *name) {
	Task *temp_task = param_prog->task_ll;

	while(temp_task) {
		if(strcmp(temp_task->name, name)) {
			return temp_task;
		}
		temp_task = temp_task->next;
	}
	return NULL;
}

// TODO: Probably a more graceful way to do this
void free_program(Program *p_prog) {
	printf("Freeing Program:\n");
	free_tasks(p_prog->task_ll);
	free(p_prog);

	return;
}

void free_tasks(Task *p_task) {
	Task *cur = p_task;
	Task *next = NULL;
	
	printf("\tFreeing Tasks:\n");
	while(cur) {
		printf("\t\t%s\n", cur->name);
		next = cur->next;

		free(cur->name);
		free_block(cur->block);

		free(cur);
		cur = next;
	}

	return;
}

void free_block(Block *p_block) {
	printf("\t\t\tFreeing Block:\n");
	free_oper_ll(p_block->operation_ll);
	
	return;
}

void free_oper_ll(Operation *p_oper) {
	Operation *cur = p_oper;
	Operation *next = NULL;
	if(cur == NULL) {
		printf("CUR IS NULL\n");
	}
	
	printf("\t\t\t\tFreeing Operations:\n");
	while(cur) {
		next = cur->next;
		
		free_nodes(cur->ast);
		free(cur);
		
		cur = next;
	}
	
	return;
}

void free_nodes(Node *p_node) {
	if(!p_node) {
		return;
	}
	switch(p_node->type) {
		case NODE_INT:
			printf("\t\t\t\t\tNODE_INT\n");
			printf("\t\t\t\t\t\t%i\n", p_node->data.num);
			break;
		case NODE_OP:
			printf("\t\t\t\t\tNODE_OP\n");
			switch(p_node->data.op_data.op) {
				case OP_ADD:
					printf("\t\t\t\t\t\tOP_ADD\n");
					break;
			}			
			free_nodes(p_node->data.op_data.right);
			free_nodes(p_node->data.op_data.left);
			break;
		case NODE_TASK:
			printf("\t\t\t\t\tNODE_TASK\n");
			printf("\t\t\t\t\t\t%s\n", p_node->data.task_data.name);
			free_nodes(p_node->data.task_data.params);
			break;
		case NODE_PARAM:
			printf("\t\t\t\t\tNODE_PARAM\n");
			free_nodes(p_node->data.param_data.next);
			free_nodes(p_node->data.param_data.self);
			break;
	}
	free(p_node);
	return;
}
