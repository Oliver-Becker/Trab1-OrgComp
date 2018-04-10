# Clara Rosa Silveira                9021070            - Busca, visualização
# Gabriela Isabel Chavez Estevez     10295440           - Busca, visualização
# Rafael Farias Roque                10295412           - Inserção, visualização
# Óliver Savastano Becker            10284890           - Remoção, código em C

# Código desenvolvido e executado no Mars 4.5	
	
	.data
	.align 0

strmenu: .asciiz "MENU INICIAL\n\n1- Inserção\n2- Remoção\n3- Busca\n4- Visualização\n5- Fim\n\nEscolha uma opção (1 a 5): "
strvolta: .asciiz ">>Retornando ao menu.\n\n"		
strchinv: .asciiz ">>Chave inválida, digite somente número binários (ou -1 para retornar ao menu)\n\n"
strchrep: .asciiz  ">>Chave repetida. Inserção não permitida.\n\n"
strchrem: .asciiz  ">>Chave removida com sucesso.\n\n"
strchins: .asciiz  ">>Chave inserida com sucesso.\n\n"
strerrom: .asciiz ">>Digite um valor de 1 a 5\n\n"
strinsch: .asciiz ">>Digite o binário para inserção: "
strremch: .asciiz ">>Digite o binário para remoção: "
strbusch: .asciiz ">>Digite o binário para busca: "
strbuserro: .asciiz ">>Chave não encontrada na árvore: -1\n"
strbuscerto: .asciiz ">>Chave encontrada na árvore: "
strbusccam: .asciiz ">>Caminho percorrido:" 
stresq: .asciiz " esq"
strdir: .asciiz " dir"
strraiz: .asciiz "raiz"
strvir: .asciiz ","
strvir2: .asciiz ", "
strn: .asciiz "\n"
strpar: .asciiz " ("
strpar1: .asciiz ")"
strN: .asciiz ">>N"
strT: .asciiz "T"
strNT: .asciiz "NT"
strnull: .asciiz "null"
	
	.align 2
	.text
	
############################### INICIO DA MAIN ###############################	  

main:
	li $v0, 9				# aloca nó raiz da árvore
	li $a0, 12
	syscall
	
	move $s7, $v0 				# armazena a raiz em s7
	li $t0, 2 				# define nó como raiz, atribuindo a este o numero 2
	sw $zero, 0($s7)			# zera os filhos e marca nó como raiz
	sw $zero, 4($s7)
	sw $t0, 8($s7)
		
############################### FIM DA MAIN ###############################		

menu: 	
	li $v0, 4
	la $a0, strmenu				# escreve string menu
	syscall	
	
	li $v0, 5 				# lê um inteiro, que determinara a operacao que sera feita
	syscall
	
	bgt $v0, 5, erroMenu 			# verifica se o numero é valido
	blt $v0, 1, erroMenu 
	
	beq $v0, 1, insere			#chama as funções que realizarão a operação 
	beq $v0, 2, remove			#requisitada pelo usuário
	beq $v0, 3, busca
	beq $v0, 4, visualiza
	beq $v0, 5, fim

	
############################### INICIO DA INSERÇÃO ###############################	
	
insere:

	li $v0, 4
	la $a0, strinsch			# escreve a string inserir chaves
	syscall	
	jal verifica
	beq $v0, -1, insere
						# chave verificada em $v0 e raiz em $s7
	move $s6, $v0 	 			# salva o caminho da chave em $s6 para não perder a referencia
	move $t0, $s6    			# registrador temporario
	move $t1 ,$s7	 			# armazena o s7 em t1 para manipular a arvore sem perder a referencia
		
loopIns:

	lb $t2, 0($t0)				# recupera o primiro byte da chave
	addi $t0, $t0, 1 			# ve o proximo byte
	beq $t2, '\0', fimloopIns 		# se o caracter lido for \0, volta para a inserção
	lb $t3, 0($t0) 				# le o proximo caracter para ver se é o elemento final e indicar chave
	li $t4, 0				# inicia como nó nao valido
	bne $t3, '\0', loopIns2 		# se o proximo não for \0 pula, se não indica como nó valido
	li $t4, 1
	 	
loopIns2:	
						# transforma t2 em int e usa o valor para saber em qual posição será adicionado o endereço
	sub $t2, $t2, '0'
	mul  $t2, $t2, 4 			# multiplica por 1 ou 0, para somar a quantidade certa de bytes
	add $t1, $t1, $t2 			# move a quantidade
	lw $t5, 0($t1) 				# acessa a posição que deve ir e ve se ja existe um nó
	bne $t5, $zero, noExiste
	jal criaNo
	sw $v0, 0($t1) 
	sub $t1, $t1, $t2 			# volta para a original
	move $t1, $v0				# atualiza qual nó será visitado
	j loopIns
	
noExiste:

	lw $t6, 8($t5) 				# ve se o nó filho é chave
	and $t6, $t6, $t4			# se o nó filho for chave e o nó que será adicionado é chave, retorna erro
	beq $t6, 1, erroChRep
						# se o t4 for 1, atualiza o nó ja existente 
	bne $t4, 1, validaNo

	sw $t4, 8($t5)
	
validaNo:

	move $t1, $t5
	j loopIns	
	
fimloopIns:
	
	li $v0, 4
	la $a0, strchins
	syscall
	j insere 				# caso chege em \0 volta ao modo de inserção

criaNo:

	li $v0, 9 				# aloca o novo nó e zera seus parametros
	li $a0, 12
	syscall
	
	sw $zero, 0($v0)			# v0 possui o endereco do vetor alocado
	sw $zero, 4($v0)
	sw $t4  , 8($v0)
	
	jr $ra
	
############################### FIM DA INSERÇÃO ###############################	

############################### INICIO DE REMOCAO ##############################

remove:

	li $v0, 4
	la $a0, strremch 			# escreve a string buscar chaves
	syscall	
	
	jal verifica
	beq $v0, -1, remove
	
	move $a1, $v0				# $a1 = string
	move $a0, $s7				# $a0 = no
	
	addi $sp, $sp, -12			# avanca 12 posicoes na stack
	sw $ra, 8($sp)				# armazena os registradores que serao usados
	sw $s0, 4($sp)				# para evitar a perda dos valores
	sw $s1, 0($sp)
	
	li $s0, 0				# flag = 0
	li $s1, 0				# count = 0
	jal removendo
	
	add $s1, $s1, 1				# count++;
	
	move $s4, $a1
	move $t9, $s1
	li $t8, 0
		
	bnez $s0, else_2			# if (flag == 0) {
	li $v0, 4
	la $a0, strbuserro			# printf("%s", strbuserro);
	syscall
	
	jal caminhoBusca
	
	j elseFim_2				# }
	
else_2:						# else {

	li $v0, 4
	la $a0, strbuscerto			# printf("%s", strbuscerto);
	syscall
	
	li $v0, 4
	move $a0, $a1				# printf("%s", string);
	syscall
	
	li $v0, 4
	la $a0, strn				# printf("\n");
	syscall

	jal caminhoBusca

	li $v0, 4
	la $a0, strchrem			# printf("%s", strchrm);
	syscall
		
elseFim_2:					# }
	
	lw $ra, 8($sp)				# pega o valor de $ra da pilha
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 12			# retorna as 12 posicoes da stack
	
	j remove				# return
	
removendo:	
						# a0 = no, a1 = string, s0 = flag, s1 = count
	addi $sp, $sp, -12			# -- avanca pilha --
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	sw $s2, 0($sp)
	
	bnez $a0, naoNulo_			# if (no == null) {
	addi $s1, $s1, -1			# count--;
	j retornaNulo_				# return 0;
						# }
naoNulo_:

	add $t0, $a1, $s1			# char*($t0) p_char = string + count;
	lb $t1, ($t0)				# char($t1) caracter = *p_char;
	
	bne $t1, '\0', else_			# if (caracter == '\0') {
	lw $t2, 8($a0)				# int($t2) terminal = no->val;
	bne $t2, 1, nonaoTerminal_		# if (terminal == 1) {
	li $s0, 1				# flag = 1;
						# }
nonaoTerminal_:

	li $t2, 0				# terminal = 0;
	sw $t2, 8($a0)				# no->val = terminal;
	j elseFim_				# }
	
else_:						# else {
	addi $s1, $s1, 1			# count++;
	subi $t3, $t1, '0'			# int($t3) numero = caracter - '0';
	mul $t4, $t3, 4				# int($t4) aux = numero * 4;
	add $s2, $a0, $t4			# no_aux = &(no->prox[numero]);
	lw $a0, ($s2)				# no = *no_aux;
	jal removendo				# removing (($a0) no, ($a1) string, ($s0) count, ($s1) flag);
	sw $v0, ($s2)				# no->prox[numero] = retorno (removing ());
	lw $a0, 4($sp)				# -- volta o valor de $a0 para no --
						# }
elseFim_:

	lw $t2, 8($a0)				# int($t2) terminal = no->val;
	beqz $t2, nonaoTerminal_2		# if (terminal != 0)
	j retornaNo_				# return no;

nonaoTerminal_2:

	li $t5, 0				# int($t5) i = 0;
loop_: 

	bge $t5, 2, fimLoop_			# while (i < 2) {
	lw $t6, ($a0)				# NO($t6) no_filho = *no;
	beqz $t6, noNulo_			# if (no_filho != null)
	j retornaNo_	
						# return no;
noNulo_:

	addi $a0, $a0, 4			# no = no + 1;
	addi $t5, $t5, 1			# i++;
	j loop_					# }
	
fimLoop_:
	
retornaNulo_:

	lw $s2, 0($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12			# -- volta pilha --
	li $v0, 0				# retorno = 0;
	jr $ra
	
retornaNo_:

	lw $s2, 0($sp)
	lw $ra, 8($sp)
	lw $v0, 4($sp)				# retorno = no;
	addi $sp, $sp, 12			# -- volta pilha --
	jr $ra
	
	
############################### FIM DA REMOÇÃO ###############################	

############################### INICIO DA VALIDAÇÃO ###############################	

verifica:

	sw $ra, 0($sp) 				# salva a posição de onde veio
	addi $sp, $sp, -4
		
	li $v0, 9  				# aloca espaço para ler o tamanho maximo da sting
	li $a0, 17
	syscall
	
	move $a0, $v0
	
	li $v0, 8				# le 17 bits para que o \n não fique no buffer e atrapalhe a proxima leitura 
	li $a1, 17
	syscall	
	move $v0, $a0
	
	
	lb $t1, 0($v0) 				# le os 3 primeiros elementos para ver se é o valor de retorno ao menu
	lb $t2, 1($v0) 
	lb $t3, 2($v0)
		
	seq $t4, $t1, '-' 			# ve se os caracteres são na sequencia -1\n ou -1\0 
	seq $t5, $t2, '1'
	seq $t6, $t3, '\n'
	seq $t7, $t3, '\0'
	
	or $t6, $t7, $t6 
	and $t5, $t5, $t6
	and $t4, $t5, $t4
	beq $t4, 1, retornaMenu 		# se a sequencia for essa, volta ao menu principal 
	
	move $t0, $v0
	
loop:

	lb $t1, 0($t0)				# le o primeiro caracter
	
	seq $t2, $t1, '\0'			# e verifica se o digito é \0 ou \n 
	seq $t3, $t1, '\n'
	
	or $t2, $t2, $t3
	
	beq $t2, 0, verLoop 			# se não for nenhum verifica se é 0 ou 1
	li $t1, '\0' 				# substitui o \n por \0
	sb $t1, 0($t0) 
	
	addi $sp, $sp, 4 			# recupera a linha de onde veio
	lw $ra, 0($sp)
	jr $ra  				# se for \0 ou \n retorna
	
verLoop:
	
	seq $t2, $t1, '0' 			# se for 0 ou 1, continua lendo
	seq $t3, $t1, '1'
	or $t2, $t2, $t3
	
	beq $t2, 0, erroVal			#se não indica erro
	
	addi $t0, $t0, 1
	j loop
	
erroMenu:

	li $v0, 4
	la $a0, strerrom 			# escreve string int errado
	syscall
	j menu	
	
erroVal:	

	li $v0, 4
	la $a0, strchinv 			# escreve string invalido
	syscall
	li $v0, -1 				# flag de erro
	addi $sp, $sp, 4 			# recupera a linha de onde veio
	lw $ra, 0($sp)
	jr $ra
	
erroChRep:					#erro de chave repetida

	li $v0, 4
	la $a0, strchrep 			# escreve string ja inserido
	syscall
	j insere
	
############################### FIM DA VALIDAÇÃO ###############################	

############################### INICIO DA BUSCA ###############################	

busca:
	li $v0, 4
	la $a0, strbusch 			# escreve a string buscar chaves
	syscall	
	li $t8, 0 				# inicia o counter que vai auxiliar na impressao do caminho percorrido na busca
	li $t9, 0 				# sera o contador para imprimir o caminho percorrido na busca
	jal verifica
	beq $v0, -1, busca
	move $s4, $v0 				# salva a string em s4
						# chave verificada em $v0 e raiz em $s7
	move $s6, $v0 	 			# salva o caminho da chave em s6 para não perder
	move $t0, $s6    			# registrador temporario 
	move $t1 ,$s7	 			# armazena o s7 em t1 para manipular a arvore sem perder a referencia

loopBusca:

	lb $t2, 0($t0)				# recupera o primiro byte da chave
	addi $t9, $t9, 1 			# count
	beq $t2, '\0', verificaBusca 		# se o caracter lido for \0, volta para a busca
	addi $t0, $t0, 1 			# ve o proximo byte
	
	sub $t2, $t2, '0'
	mul  $t2, $t2, 4 			# multiplica por 1 ou 0, para somar a quantidade certa de bytes
	add $t1, $t1, $t2 			# move a quantidade
	lw $t2, 0($t1) 				# acessa a posição que deve ir e ve se ja existe um nó
	beq $t2, $zero, erroBusca 		# verifica se o caminho para o proximo nó não é valido
	move $t1, $t2
	j loopBusca
	
verificaBusca:
	
	lw $t2, 8($t1) 
	beq $t2, 1, imprimeNoEncontrado
	
erroBusca:

	li $v0, 4
	la $a0, strbuserro 			# escreve string de erro na busca
	syscall
	
	la $ra, busca
	j caminhoBusca

imprimeNoEncontrado:

	li $v0, 4
	la $a0, strbuscerto 			# imprime "chave encontrada na árvore"
	syscall
	move $a0, $s4
	li $v0, 4 				# impime a chave buscada
	syscall
	li $v0, 4
	la $a0, strn 				# imprime \n
	syscall
	
	la $ra, busca

caminhoBusca:	

	move $t0, $s4 				# recebe a string do 
	li $v0, 4
	la $a0, strbusccam 			# imprime a string de caminho
	syscall
	
	li $v0, 4
	la $a0, strraiz 			# imprime a str de raiz
	syscall
	
caminhoBusca2:

	lb $t2, 0($t0)
	beq $t2, '\0', fimCaminho
	sub $t2, $t2, '0'
	addi $t0, $t0, 1 			# atualiza-se o ponteiro, pq nao precisa mais da string
	addi $t8, $t8, 1 			# atualiza-se o counter
	bge $t8, $t9, fimCaminho 		# acaba a impressao, pois o count se igualou ao numero de digitos da busca
	beq $t2, $zero, imprimeEsq
	beq $t2, 1, imprimeDir	
	
imprimeEsq:

	li $v0, 4
	la $a0, strvir 				# imprime a virgula
	syscall

	li $v0, 4
	la $a0, stresq 				# escreve string esquerda
	syscall

	j caminhoBusca2
	
imprimeDir:

	li $v0, 4
	la $a0, strvir 				# imprime a virgula
	syscall
	
	li $v0, 4
	la $a0, strdir 				# escreve string direita
	syscall 
	
	j caminhoBusca2
	
fimCaminho: 					# finaliza a impressao do caminho que a busca fez

	li $v0, 4
	la $a0, strn 				# imprime '\n'
	syscall

	jr $ra

############################### FIM DA BUSCA ###############################	

############################### INICIO DA VISUALIZAÇÃO ###############################	

visualiza:	

	move $t0, $s7
	move $t1, $sp
	move $t2, $sp
	li $t3, 0
	addi $sp, $sp, -20 			# salva as infos na ordem: 0 ou 1 ,tipo de nó, endereço esq e endereço dir
	
	lw $t4, 0($t0) 				# filho esq
	lw $t5, 4($t0) 				# filho dir
	lw $t6, 8($t0) 				# raiz
	
	sw $t3, 16($sp)	 			# nivel da arvore
	sw $t6, 12($sp) 			# tipo de nó(filho esq, dir ou raiz)
	sw $t3, 8($sp)  			# terminal ou não terminal
	sw $t4, 4($sp)  			# filho da esq
	sw $t5, 0($sp)				# filho da dir
	
	
loopVisualizaEsq: 				# analisa o filho da esquerda

	beq $t1, $sp, imprime
	addi $t1, $t1, -16 
	lw $t3, 0($t1)
	beq $t3, $zero, loopVisualizaDir
	addi $sp, $sp, -20
	
	lw $t4, 0($t3)	 			# filho esq
	lw $t5, 4($t3) 				# filho dir
	lw $t6, 8($t3) 				# T ou NT
	lw $t7, 12($t1) 			# nivel do "pai"
	
	addi $t7, $t7, 1
	
	sw $t7, 16($sp) 			# nivel da arvore
	sw $zero, 12($sp) 			# tipo de nó(filho esq, dir ou raiz)
	sw $t6, 8($sp)  			# terminal ou não terminal
	sw $t4, 4($sp)  			# filho da esq
	sw $t5, 0($sp)				# filho da dir
	

loopVisualizaDir: 				# analisa o filho da direita

	addi $t1, $t1, -4 
	lw $t3, 0($t1)
	beq $t3, $zero, loopVisualizaEsq
	addi $sp, $sp, -20
	
	lw $t4, 0($t3) 				# filho esq
	lw $t5, 4($t3) 				# filho dir
	lw $t6, 8($t3) 				# T ou NT
	lw $t7, 16($t1) 			# nivel do "pai"
	
	addi $t7, $t7, 1
	li $t8, 1
	
	sw $t7, 16($sp)	 			# nivel da arvore
	sw $t8, 12($sp) 			# tipo de nó(filho esq, dir ou raiz)
	sw $t6, 8($sp)  			# terminal ou não terminal
	sw $t4, 4($sp)  			# filho da esq
	sw $t5, 0($sp)				# filho da dir
	
	j loopVisualizaEsq
	
imprime:

	move $t1, $t2				# imprime o nivel da raiz
						
	li $v0, 4
	la $a0, strN 				# imprime 'N'
	syscall
	
	li $v0, 1
	li $a0, 0				# imprime '0'
	syscall 
	
imprime2:

	lw $t3, 16($t1)	 			# atualiza-se o nivel
	move $t9, $t3 				# salva-se o nivel anterior, para saber quando se imprime '\n'
	addi $t1, $t1, -20			# ou seja, para saber quanto se passa para o próximo nivel
	
	lw $t3, 16($t1) 			# atualiza-se o nivel
	bne $t9, $t3, imprimeEnter 		# caso o nivel atual, seja diferente do anterior, imprime-se '\n'
	move $t7, $3
 	
 imprime3: 
	
	li $v0, 4
	la $a0, strpar 				# imprime ' ('
	syscall
	
	jal tipoNo 				# imprime o tipo de no
	
	jal dTerminal				# imprime se é ou não terminal 
	
	lw $a2, 4($t1) 				# imprime o endereco do filho esquerdo
	jal dEnd
	
	li $v0, 4
	la $a0, strvir2				# imprime ", "
	syscall
	
	lw $a2, 0($t1) 				# imprime o endereco do filho direito
	jal dEnd
	
	li $v0, 4
	la $a0, strpar1				# imprime ")"
	syscall
	
	beq $t1, $sp, fimVisualiza		# se $t1==$sp, entao acabou a impressão
	j imprime2
	
imprimeEnter: 					 

	li $v0, 4				# imprime a quebra de linha
	la $a0, strn
	syscall
	
	li $v0, 4				# imprime 'N'
	la $a0, strN
	syscall
	
	li $v0, 1				# imprime o nivel
	move $a0, $t3 				
	syscall
	
	j imprime3
	
tipoNo: 

	lw $t3, 12($t1) 			# tipo de no (raiz, filho da esquerda ou da direita)
	li $t4, 2
	beq $t4, $t3, imprimeraiz 		# se for 2, imprime raiz
	bne $t4, $t3, imprimeFilho 		# caso contrario, eh um filho da esquerda ou da direita
	
imprimeraiz:

	li $v0, 4
	la $a0, strraiz 			# imprime o tipo de no (raiz, filho da esquerda ou da direita)
	syscall

	li $v0, 4
	la $a0, strvir2 			# imprime virgula
	syscall
	jr $ra
	
imprimeFilho:

	li $v0, 1
	move $a0, $t3				# imprime o tipo do no
	syscall
	
	li $v0, 4
	la $a0, strvir2 			# imprime virgula
	syscall
	jr $ra

dTerminal: 					# determina se eh ou nao terminal

	lw $t3, 8($t1) 				# agora ve-se se eh no terminal ou nao terminal
	li $t4, 1
	
	beq $t3, $zero, naoTerminal
	beq $t3, $t4, terminal

naoTerminal: 					

	li $v0, 4
	la $a0, strNT				# imprime 'NT'
	syscall
	
	li $v0, 4
	la $a0, strvir2 			# imprime virgula
	syscall
	
	jr $ra 					# volta para dps de 'dettermial'

terminal: 					

	li $v0, 4
	la $a0, strT				# imprime 'T'
	syscall
	
	li $v0, 4
	la $a0, strvir2 			# imprime virgula
	syscall
	
	jr $ra

dEnd:						# determina o endereço que será impresso

	move $t3, $a2 
	beq $t3,  $zero, imprimeNulo		# caso seja nulo, imprime 'null'

	li $v0, 1				
	move $a0, $t3				# se não, imprime o endereço do nó
	syscall
	
	jr $ra

imprimeNulo:					#imprime 'null'

	li $v0, 4
	la $a0, strnull
	syscall
	
	jr $ra
	
fimVisualiza:

	move $sp, $t2 				# $sp volta para onde estava antes do começo da operação
	
	li $v0, 4
	la $a0, strn				# imprime '\n'
	syscall
	
	j menu
	

############################### FIM DA VISUALIZAÇÃO ###############################	

retornaMenu:

	li $v0, 4
	la $a0, strvolta			# imprime que está voltando ao menu
	syscall
	j menu
	
fim:	li $v0, 10
	syscall

############################### FIM DO PROGRAMA ###############################