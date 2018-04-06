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

TRIE* deleting(TRIE* t, char* key, int* d, int* flag) {
	if (t == NULL) {
		(*d)--;
		return NULL;
	}

	if (key[*d] == '\0') {
		if (t->val == 1)
			*flag = 1;
		t->val = 0;
	}
	else {
		int number = key[(*d)++] - '0';
		t->next[number] = deleting(t->next[number], key, d, flag);
	}

	if (t->val != 0) return t;
	for (int i = 0; i < 2; ++i)
		if (t->next[i] != NULL)
			return t;

	return NULL;
}

int delete_key(TRIE* t, char* key) {
	int flag = 0, d = 0;
	t = deleting(t, key, &d, &flag);
	if (flag == 0)
		return -d;
	return d;
}

int searching(TRIE* t, char* key, int* d) {
	if (t == NULL) {
		(*d)--;
		return 0;
	}
		
	if (key[*d] == '\0')
		return t->val;

	int number = key[(*d)++] - '0';
	return searching(t->next[number], key, d);
}

int search_key(TRIE* t, char* key) {
	int d = 0;
	int flag = searching(t, key, &d);
	if (flag == 0)
		return -d;
	return d;
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
	int aux;

	do {
		printf("1- Inserção\n2- Remoção\n3- Busca\n4- Visualização\n5- Fim\n");
		printf("\nEscolha uma opção (1 a 5):");

		scanf("%d", &op);
		switch (op) {
			case 1:
				printf("Digite o binário para inserção: ");
				scanf("%s", key);
				while (strcmp(key, "-1") != 0) {
					if (validade_input(key)) {
						aux = insert_key(t, key);
						if (aux == 0)
							printf("Chave repetida. Inserção não permitida.\n\n");
						else
							printf("Chave inserida com sucesso.\n\n");
					} else {
						printf("Chave inválida. Insira somente números bi");
						printf("nários (ou -1 retorna ao menu).\n\n");
					}
					printf("Digite o binário para inserção: ");
					scanf("%s", key);
				}
				printf("Retornando ao menu.\n\n");
				break;
			case 2:
				printf("Digite o binário para remoção: ");
				scanf("%s", key);
				while (strcmp(key, "-1") != 0) {
					if (validade_input(key)) {
						aux = delete_key(t, key);
						if (aux <= 0) {
							printf("Chave não encontrada na árvore: -1\n");
							aux = -aux;
						} else
							printf("Chave encontrada na árvore: %s\n", key);

						printf("Caminho percorrido: raiz");
						for (int i = 0; i < aux; ++i) {
							(key[i] == '0') ? printf(", esq") : printf(", dir");
						}
						printf("\n\n");
					} else {
						printf("Chave inválida. Insira somente números bi");
						printf("nários (ou -1 retorna ao menu).\n\n");
					}
					printf("Digite o binário para remoção: ");
					scanf("%s", key);
				}
				printf("Retornando ao menu.\n\n");
				break;
			case 3:
				printf("Digite o binário para busca: ");
				scanf("%s", key);
				while (strcmp(key, "-1") != 0) {
					if (validade_input(key)) {
						aux = search_key(t, key);
						if (aux <= 0) {
							printf("Chave não encontrada na árvore: -1\n");
							aux = -aux;
						} else
							printf("Chave encontrada na árvore: %s\n", key);

						printf("Caminho percorrido: raiz");
						for (int i = 0; i < aux; ++i) {
							(key[i] == '0') ? printf(", esq") : printf(", dir");
						}
						printf("\n\n");
					} else {
						printf("Chave inválida. Insira somente números bi");
						printf("nários (ou -1 retorna ao menu).\n\n");
					}
					printf("Digite o binário para busca: ");
					scanf("%s", key);
				}
				printf("Retornando ao menu.\n\n");
				break;
			case 4:
				printf("Visualização? Ops...\n\n");
				break;
			case 5:
				break;
			default:
				printf("operação inválida, insira um número entre 1 e 5\n");
		}
	} while (op != 5);

	return 0;
}
