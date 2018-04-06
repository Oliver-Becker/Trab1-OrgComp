#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct trie TRIE;

struct trie {
	int val;	// nó terminal (1) ou não-terminal(0)
	TRIE** next;	// vet de nós de 2 posições
};

TRIE* create() {
	TRIE* t = (TRIE*) calloc(1, sizeof(TRIE));
	t->next = (TRIE**) calloc(2, sizeof(TRIE*));
	return t;
}

TRIE* inserting(TRIE* t, char* key, int d, int* flag) {
	if (t == NULL)
		t = create();

	if (key[d] == '\0') {
		if (t->val == 1)
			*flag = 0;
		else
			t->val = 1;
		return t;
	}
	int number = key[d] - '0';
	t->next[number] = inserting(t->next[number], key, d+1, flag);
	return t;
}

int insert_key(TRIE* t, char* key) {
	int flag = 1;
	t = inserting(t, key, 0, &flag);
	return flag;
}

TRIE* deleting(TRIE* t, char* key, int d, int* flag) {
	if (t == NULL) return NULL;

	if (key[d] == '\0') {
		if (t->val == 1)
			*flag = 1;
		t->val = 0;
	}
	else {
		int number = key[d] - '0';
		t->next[number] = deleting(t->next[number], key, d+1, flag);
	}

	if (t->val != 0) return t;
	for (int i = 0; i < 2; ++i)
		if (t->next[i] != NULL)
			return t;

	return NULL;
}

int delete_key(TRIE* t, char* key) {
	int flag = 0;
	t = deleting(t, key, 0, &flag);
	return flag;
}

int searching(TRIE* t, char* key, int d) {
	if (t == NULL) return 0;
		
	if (key[d] == '\0')
		return t->val;

	int number = key[d] - '0';
	return searching(t->next[number], key, d+1);
}

int search_key(TRIE* t, char* key) {
	return searching(t, key, 0);
}

int validade_input(char* key) {
	int d = -1;
	while (key[++d] != '\0')
		if (key[d] != '0' && key[d] != '1')
			return 0;

	return 1;
}

int main() {

	TRIE* t = create();

	int op;
	char key[16];

	do {
		printf("1- Inserção,\n2- Remoção,\n3- Busca\n4- Visualização\n5- Fim\n");
		printf("\nEscolha uma opção (1 a 5):");

		scanf("%d", &op);
		switch (op) {
			case 1:
				scanf("%s", key);
				while (strcmp(key, "-1") != 0) {
					if (validade_input(key))
						printf("inserindo %d\n", insert_key(t, key));
					else {
						printf("Chave inválida. Insira somente números bi");
						printf("nários (ou -1 retorna ao menu).\n");
					}
					scanf("%s", key);
				}
				break;
			case 2:
				scanf("%s", key);
				while (strcmp(key, "-1") != 0) {
					if (validade_input(key))
						printf("deletando %d\n", delete_key(t, key));
					else {
						printf("Chave inválida. Insira somente números bi");
						printf("nários (ou -1 retorna ao menu).\n");
					}
					scanf("%s", key);
				}
				break;
			case 3:
				scanf("%s", key);
				while (strcmp(key, "-1") != 0) {
					if (validade_input(key))
						printf("buscando %d\n", search_key(t, key));
					else {
						printf("Chave inválida. Insira somente números bi");
						printf("nários (ou -1 retorna ao menu).\n");
					}
					scanf("%s", key);
				}
				break;
			case 4:
				printf("Visualização? Ops...\n");
				break;
			case 5:
				break;
			default:
				printf("operação inválida, insira um número entre 1 e 5\n");
		}
	} while (op != 5);

	return 0;
}
