#include "qplus_structs.h"

int last_addr = 0;
struct LazyTable *task_table = NULL;
struct LazyTable *var_table = NULL;

Program* create_program() {
	printf("create_program\n");
	Program *cur_prog = (Program *)malloc(sizeof(Program));
	printf("create_program: ret\n");
	return cur_prog;
}

Task* create_task(const char *name, Block *p_block) {
	printf("create_task\n");
	Task *new_task = (Task *)malloc(sizeof(Task));
	new_task->name = strdup(name);
	new_task->block = p_block;

	LazyTable *new_table = (LazyTable *)malloc(sizeof(LazyTable));
	new_table->name = strdup(name);
	new_table->addr = 0;
	new_table->next = task_table;
	task_table = new_table;
	
	return new_task;
}

Block* create_block(Statement *p_op) {
	printf("create_block\n");
	Block *new_block = (Block *)malloc(sizeof(Block));
	new_block->statement_ll = p_op;
	
	return new_block;
}

Statement* create_statement_node(Node *ast, Statement *next) {
	printf("create_statement\n");
	Statement *new_statement = (Statement *)malloc(sizeof(Statement));
	new_statement->ast = ast;
	new_statement->next = next;
	
	return new_statement;
}

Node* create_int_node(int value) {
	printf("create_int\n");
	Node* new_node = (Node *)malloc(sizeof(Node));
	new_node->type = NODE_INT;
	new_node->data.num = value;
	
	return new_node;
}

Node* create_var_node(const char *name) {
	printf("create_var\n");
	Node* new_node = (Node *)malloc(sizeof(Node));
	new_node->type = NODE_VAR;
	new_node->data.var_name = strdup(name);
	
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
	//	Note: Yes keep this variable
	//		We are making a tree, not linking it
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

Node* create_assign_node(const char *name, Node *expr) {
	Node* new_node = (Node *)malloc(sizeof(Node));
	new_node->type = NODE_ASSIGN;
	new_node->data.assign_data.var_name = strdup(name);
	new_node->data.assign_data.expr = expr;

	LazyTable *new_table = (LazyTable *)malloc(sizeof(LazyTable));
	new_table->name = strdup(name);
	new_table->addr = 0;
	new_table->next = var_table;
	var_table = new_table;

	return new_node;
}

void reverse_program(Program *p_prog, FILE *output_file, int level) {
	if(p_prog) {
		Task *cur_task = p_prog->task_ll;
		while(cur_task) {
			reverse_task(cur_task, output_file, level + 1);
			cur_task = cur_task->next;
		}
	}
	return;	
}
void reverse_task(Task *p_task, FILE *output_file, int level) {
	if(p_task) {
		fprintf(output_file, "task %s {\n", p_task->name);
		reverse_block(p_task->block, output_file, level + 1);
		fprintf(output_file, "}");
	}
	fprintf(output_file, "\n\n");
	return;	
}
void reverse_block(Block *p_block, FILE *output_file, int level) {
	if(p_block) {
		reverse_stmt_ll(p_block->statement_ll, output_file, level);
	}
	return;	
}
void reverse_stmt_ll(Statement *p_stmt, FILE *output_file, int level) {
	if(p_stmt) {
		reverse_stmt_ll(p_stmt->next, output_file, level);
		fprintf(output_file, "\t");
		reverse_node(p_stmt->ast, output_file, level + 1);
		fprintf(output_file, ";\n");
	}
	return;	
}
void reverse_node(Node *p_node, FILE *output_file, int level) {
	if(p_node) {
		switch(p_node->type) {
			case NODE_INT:
				fprintf(output_file, "%i", p_node->data.num);
				
				break;
			case NODE_VAR:
				fprintf(output_file, "%s", p_node->data.var_name);

				break;
			case NODE_OP:
				reverse_node(p_node->data.op_data.left, output_file, level + 1);

				switch(p_node->data.op_data.op) {
					case OP_ADD:
						fprintf(output_file, " + ");	
						break;
				}
				
				reverse_node(p_node->data.op_data.right, output_file, level + 1);
				
				break;
			case NODE_TASK:
				fprintf(output_file, "%s( ", p_node->data.task_data.name);
				
				reverse_node(p_node->data.task_data.params, output_file, level + 1);

				fprintf(output_file, ")");
				
				break;
			case NODE_PARAM:
				reverse_node(p_node->data.param_data.self, output_file, level + 1);
				
				fprintf(output_file, ", ");
				
				reverse_node(p_node->data.param_data.next, output_file, level + 1);
				
				break;
			case NODE_ASSIGN:
				fprintf(output_file, "%s = ", p_node->data.assign_data.var_name);
				
				reverse_node(p_node->data.assign_data.expr, output_file, level + 1);
				
				break;
		}
	}
	return;
}

void pseudoasm_program(Program *p_prog, FILE *output_file, int level) {
	if(p_prog) {
		Task *cur_task = p_prog->task_ll;	
		while(cur_task) {
			pseudoasm_task(cur_task, output_file, level + 1);
			cur_task = cur_task->next;
		}
	}	
	return;
}

void pseudoasm_task(Task *p_task, FILE *output_file, int level) {
	if(p_task) {
		fprintf(output_file, "Label %s:\n", p_task->name);
		pseudoasm_block(p_task->block, output_file, level + 1);
		fprintf(output_file, "\tret\n");
		fprintf(output_file, "\n");
	}
	return;
}

void pseudoasm_block(Block *p_block, FILE *output_file, int level) {
	if(p_block) {
		pseudoasm_stmt_ll(p_block->statement_ll, output_file, level);
	}
	return;
}

void pseudoasm_stmt_ll(Statement *p_stmt, FILE *output_file, int level) {
	if(p_stmt) {
		pseudoasm_stmt_ll(p_stmt->next, output_file, level);
		pseudoasm_node(p_stmt->ast, output_file, level + 1);
	}
	return;
}

void pseudoasm_node(Node *p_node, FILE *output_file, int level) {
	if(p_node) {
		switch(p_node->type) {
			case NODE_INT:
				fprintf(output_file, "\tload_int %%r1, %i\n", p_node->data.num);
				
				break;
			case NODE_VAR:
				fprintf(output_file, "\tload_var %%r1, addr(%s)\n", p_node->data.var_name);

				break;
			case NODE_OP:
				pseudoasm_node(p_node->data.op_data.left, output_file, level + 1);
				fprintf(output_file, "\tpush %%r1\n");	
				pseudoasm_node(p_node->data.op_data.right, output_file, level + 1);
				fprintf(output_file, "\tpop %%r2\n");	
				switch(p_node->data.op_data.op) {
					case OP_ADD:
						fprintf(output_file, "\tadd %%r1, %%r2\n");
						break;
				}
				
				break;
			case NODE_TASK:
				pseudoasm_parampush(p_node->data.task_data.params, output_file, level + 1);
				fprintf(output_file, "\tjump label:%s\n", p_node->data.task_data.name);
				pseudoasm_parampop(p_node->data.task_data.params, output_file, level + 1);

				break;
			case NODE_PARAM:
				fprintf(output_file, "\tpush %%r1\n");
				pseudoasm_node(p_node->data.param_data.self, output_file, level + 1);
				
				pseudoasm_node(p_node->data.param_data.next, output_file, level + 1);
				
				break;
			case NODE_ASSIGN:
				pseudoasm_node(p_node->data.assign_data.expr, output_file, level + 1);
				fprintf(output_file, "\tsave_var addr(%s), %%r1\n", p_node->data.assign_data.var_name);

				break;
		}
	}
	return;
}

void pseudoasm_parampush(Node *p_node, FILE *output_file, int level) {
	Node *curp_node = p_node;
	while(curp_node) {
		pseudoasm_node(curp_node->data.param_data.self, output_file, level + 1);
		fprintf(output_file, "\tpush_param %%r1\n");
		curp_node = curp_node->data.param_data.next;
	}
	return;
}

void pseudoasm_parampop(Node *p_node, FILE *output_file, int level) {
	Node *curp_node = p_node;
	while(curp_node) {
		fprintf(output_file, "\tpop_param\n");
		curp_node = curp_node->data.param_data.next;
	}
	return;
}

void print_tables(FILE *output_file) {
	LazyTable *cur_task = task_table;	
	fprintf(output_file, "Tasks:\n");
	while(cur_task) {
		fprintf(output_file, "\t%s: %i\n", cur_task->name, cur_task->addr);
		cur_task = cur_task->next;
	}
	LazyTable *cur_var = var_table;	
	fprintf(output_file, "Vars:\n");
	while(cur_var) {
		fprintf(output_file, "\t%s: %i\n", cur_var->name, cur_var->addr);
		cur_var = cur_var->next;
	}
}

void print_program(Program *p_prog, FILE *output_file, int level) {
	lazy_tab(output_file, level);
	fprintf(output_file, "PROGRAM\n");

	if(!p_prog) {
		lazy_tab(output_file, level);
		fprintf(output_file, "\tNULL\n");
	}
	else {
		Task *cur_task = p_prog->task_ll;
		while(cur_task) {
			print_task(cur_task, output_file, level + 1);
			cur_task = cur_task->next;
		}
	}
	return;
}

void print_task(Task *p_task, FILE *output_file, int level) {
	lazy_tab(output_file, level);
	fprintf(output_file, "TASK\n");

	if(!p_task) {
		lazy_tab(output_file, level);
		fprintf(output_file, "\tNULL\n");
	}
	else {
		lazy_tab(output_file, level);
		fprintf(output_file, "\tName: %s\n", p_task->name);
		print_block(p_task->block, output_file, level + 1);
	}
	return;
}

void print_block(Block *p_block, FILE *output_file, int level) {
	lazy_tab(output_file, level);
	fprintf(output_file, "BLOCK\n");

	if(!p_block) {
		lazy_tab(output_file, level);
		fprintf(output_file, "\tNULL\n");
	}
	else {
		print_stmt_ll(p_block->statement_ll, output_file, level + 1);
	}
	return;
}

void print_stmt_ll(Statement *p_stmt, FILE *output_file, int level) {
	if(!p_stmt) {
		return;
	}

	print_stmt_ll(p_stmt->next, output_file, level);

	lazy_tab(output_file, level);
	fprintf(output_file, "STATEMENT\n");
	print_node(p_stmt->ast, output_file, level + 1);

	return;
}

void print_node(Node *p_node, FILE *output_file, int level) {
	if(!p_node) {
		lazy_tab(output_file, level);
		fprintf(output_file, "\tNULL\n");
		return;
	}
	switch(p_node->type) {
		case NODE_INT:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_INT\n");
			
			lazy_tab(output_file, level);
			fprintf(output_file, "\tvalue(%i)\n", p_node->data.num);
			
			break;
		case NODE_VAR:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_VAR\n");
			
			lazy_tab(output_file, level);
			fprintf(output_file, "\tname(%s)\n", p_node->data.var_name);
			
			break;
		case NODE_OP:
			lazy_tab(output_file, level);
			switch(p_node->data.op_data.op) {
				case OP_ADD:
					fprintf(output_file, "NODE_OP(OP_ADD)\n");
					break;
			}
			
			lazy_tab(output_file, level);
			fprintf(output_file, "\tleft\n");
			print_node(p_node->data.op_data.left, output_file, level + 1);
			
			lazy_tab(output_file, level);
			fprintf(output_file, "\tright\n");
			print_node(p_node->data.op_data.right, output_file, level + 1);
			
			break;
		case NODE_TASK:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_TASK\n");
			
			lazy_tab(output_file, level);
			fprintf(output_file, "\tname(%s)\n", p_node->data.task_data.name);
			
			lazy_tab(output_file, level);
			fprintf(output_file, "\tparams\n");
			print_node(p_node->data.task_data.params, output_file, level + 1);
			
			break;
		case NODE_PARAM:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_PARAM\n");
			
			lazy_tab(output_file, level);
			fprintf(output_file, "\tself\n");
			print_node(p_node->data.param_data.self, output_file, level + 1);
			
			lazy_tab(output_file, level);
			fprintf(output_file, "\tnext\n");
			print_node(p_node->data.param_data.next, output_file, level + 1);
			
			break;
		case NODE_ASSIGN:
			lazy_tab(output_file, level);
			fprintf(output_file, "NODE_ASSIGN\n");

			lazy_tab(output_file, level);
			fprintf(output_file, "\tname(%s)\n");
			print_node(p_node->data.assign_data.expr, output_file, level + 1);

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

void free_tables() {
	printf("Freeing Task Table:\n");
	free_task_table(task_table);
	printf("Freeing Var Table:\n");
	free_var_table(var_table);

	return;
}

void free_task_table(LazyTable *p_task_t) {
	if(p_task_t) {
		free_task_table(p_task_t);
		free((char *)p_task_t->name);
		free(p_task_t);
	}
	return;
}

void free_var_table(LazyTable *p_var_t) {
	if(p_var_t) {
		free_var_table(p_var_t);
		free((char *)p_var_t->name);
		free(p_var_t);
	}
	return;
}

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

		free((char *)cur->name);
		free_block(cur->block);

		free(cur);
		cur = next;
	}

	return;
}

void free_block(Block *p_block) {
	printf("\t\t\tFreeing Block:\n");
	free_stmt_ll(p_block->statement_ll);
	
	return;
}

void free_stmt_ll(Statement *p_stmt) {
	Statement *cur = p_stmt;
	Statement *next = NULL;
	if(cur == NULL) {
		printf("CUR IS NULL\n");
	}
	
	printf("\t\t\t\tFreeing Statements:\n");
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

	//	The node itself is freed after the switch here
	switch(p_node->type) {
		case NODE_INT:
			printf("\t\t\t\t\tNODE_INT\n");
			printf("\t\t\t\t\t\t%i\n", p_node->data.num);
			break;
		case NODE_VAR:
			printf("\t\t\t\t\tNODE_VAR\n");
			printf("\t\t\t\t\t\t%s\n", p_node->data.var_name);
			free((char *)p_node->data.var_name);
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
			free((char *)p_node->data.task_data.name);
			free_nodes(p_node->data.task_data.params);
			break;
		case NODE_PARAM:
			printf("\t\t\t\t\tNODE_PARAM\n");
			free_nodes(p_node->data.param_data.next);
			free_nodes(p_node->data.param_data.self);
			break;
		case NODE_ASSIGN:
			printf("\t\t\t\t\tNODE_ASSIGN\n");
			free((char *)p_node->data.assign_data.var_name);
			free_nodes(p_node->data.assign_data.expr);
			break;
	}

	free(p_node);
	return;
}
