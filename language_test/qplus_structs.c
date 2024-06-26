#include "qplus_structs.h"

Program* create_program() {
	Program *cur_prog = (Program *)malloc(sizeof(Program));
	return cur_prog;
}

Task* create_task(const char *name) {
	Task *new_task = (Task *)malloc(sizeof(Task));
	new_task->name = strdup(name);

	return new_task;
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
	free_tasks(p_prog->task_ll);
	free_nodes(p_prog->node_tree);
	free(p_prog);

	return;
}

void free_tasks(Task *p_task) {
	Task *next;
	
	printf("Freeing Tasks:\n");
	while(p_task) {
		printf("\t%s\n", p_task->name);
		next = p_task->next;

		free(p_task->name);
		free_nodes(p_task->node_tree);

		free(p_task);
		p_task = next;
	}

	return;
}

void free_nodes(Node *p_node) {
	if(!p_node) {
		return;
	}
	switch(p_node->type) {
		case NODE_NUM:
			break;
		case NODE_OP:
			free_nodes(p_node->data.op_data.right);
			free_nodes(p_node->data.op_data.left);
			break;
		case NODE_TASK:
			free_nodes(p_node->data.task_data.params);
			break;
		case NODE_PARAM:
			free_nodes(p_node->data.param_data.next);
			free_nodes(p_node->data.param_data.self);
			break;
	}
	free(p_node);
	return;
}
