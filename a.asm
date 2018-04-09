	.data
	.align 0

strmenu: .asciiz "MENU INICIAL\n\n1- Inser��o\n2- Remo��o\n3- Busca\n4- Visualiza��o\n5- Fim\n\nEscolha uma op��o (1 a 5): "		
strchinv: .asciiz "Chave inv�lida, digite somente n�mero bin�rios (ou -1 para retornar ao menu)\n\n"
strchrep: .asciiz  "Chave repetida. Inser��o n�o permitida.\n\n"
strchins: .asciiz  "Chave inserida com sucesso.\n\n"
strchrem: .asciiz  "Chave removida com sucesso.\n\n"
strerrom: .asciiz "Digite um valor de 1 a 5\n\n"
strinsch: .asciiz "Digite o bin�rio para inser��o: "
strremch: .asciiz "Digite o bin�rio para remo��o: "
strbusch: .asciiz "Digite o bin�rio para busca: "
strbuserro: .asciiz "Chave n�o encontrada na �rvore: -1\n"
strbuscerto: .asciiz "Chave encontrada na �rvore: "
strbusccam: .asciiz "Caminho percorrido:" #mostra o caminho feito para uma busca validada
stresq: .asciiz " esq"
strdir: .asciiz " dir"
strraiz: .asciiz " raiz"
strvir: .asciiz ","
strn: .asciiz "\n"


	.align 2
	.text  
main:
	li $v0, 9 # aloca n� raiz da �rvore
	li $a0, 12
	syscall
	
	move $s7, $v0 # armazena a raiz em s7
	li $t0, 2 #define n� como raiz
	sw $zero, 0($s7)#zera os filhos e marca n� como raiz
	sw $zero, 4($s7)
	sw $t0, 8($s7)
	
		
### FIM DA MAIN ####
menu: 	
	li $v0, 4
	la $a0, strmenu #escreve string menu
	syscall	
	
	li $v0, 5 #l� um inteiro
	syscall
	
	bgt $v0, 5, erromenu #verifica se o numero � valido
	blt $v0, 1, erromenu 
	
	beq $v0, 1, insere
	beq $v0, 2, remove
	beq $v0, 3, busca
	#beq $v0, 4, vizualiza
	beq $v0, 5, fim
	
insere:
	li $v0, 4
	la $a0, strinsch #escreve a string inserir chaves
	syscall	
	jal verifica
	beq $v0, -1, insere
	#chave verificada em $v0 e raiz em $s7
	move $s6, $v0 	 # salva o caminho da chave em s6 para n�o perder
	move $t0, $s6    # registrador temporario 
	move $t1 ,$s7	 # armazena o s7 em t1 para manipular a arvore sem perder a referencia
		
loopins:
	lb $t2, 0($t0)	#recupera o primiro byte da chave
	addi $t0, $t0, 1 #ve o proximo byte
	beq $t2, '\0', fimloopins #se o caracter lido for \0, volta para a inser��o
	lb $t3, 0($t0) #le o proximo caracter para ver se � o elemento final e indicar chave
	li $t4, 0	#inicia como n� nao valido
	bne $t3, '\0', loopins2 #se o proximo n�o for \0 pula, se n�o indica como n� valido
	li $t4, 1
	 	
loopins2:
	
	#transforma t2 em int e usa o valor para saber em qual posi��o ser� adicionado o endere�o
	sub $t2, $t2, '0'
	mul  $t2, $t2, 4 #multiplica por 1 ou 0, para somar a quantidade certa de bytes
	add $t1, $t1, $t2 #move a quantidade
	lw $t5, 0($t1) #acessa a posi��o que deve ir e ve se ja existe um n�
	bne $t5, $zero, noexiste
	jal criano
	sw $v0, 0($t1) 
	sub $t1, $t1, $t2 #volta para a original
	move $t1, $v0	#atualiza qual n� ser� visitado
	j loopins
	
noexiste:
	lw $t6, 8($t5) #ve se o n� filho � chave
	and $t6, $t6, $t4#se o n� filho for chave e o n� que ser� adicionado � chave, retorna erro
	beq $t6, 1, errochrep
	#se o t4 for 1, atualiza o n� ja existente 
	bne $t4, 1, validano
	#move $t1, $t5#se n�o atualiza o n� atual
	#j loopins

	sw $t4, 8($t5)
validano:
	move $t1, $t5
	j loopins	
	
fimloopins:
	
	li $v0, 4
	la $a0, strchins
	syscall
	j insere # caso chege em \0 volta ao modo de inser��o

criano:
	li $v0, 9 #aloca o novo n� e zera seus parametros
	li $a0, 12
	syscall
	
	sw $zero, 0($v0)#v0 possui o endereco do vetor alocado
	sw $zero, 4($v0)
	sw $t4  , 8($v0)
	
	jr $ra 
	

verifica:
	sw $ra, 0($sp) #salva a posi��o de onde veio
	addi $sp, $sp, -4
		
	li $v0, 9  #aloca espa�o para ler o tamanho maximo da sting
	li $a0, 17
	syscall
	
	move $a0, $v0
	
	li $v0, 8#le 17 bits para que o \n n�o fique no buffer e atrapalhe a proxima leitura 
	li $a1, 17
	syscall	
	move $v0, $a0
	
	
	lb $t1, 0($v0) #le os 3 primeiros elementos para ver se � o valor de retorno ao menu
	lb $t2, 1($v0) 
	lb $t3, 2($v0)
		
	seq $t4, $t1, '-' #ve se os caracteres s�o na sequencia -1\n ou -1\0 
	seq $t5, $t2, '1'
	seq $t6, $t3, '\n'
	seq $t7, $t3, '\0'
	
	or $t6, $t7, $t6 
	and $t5, $t5, $t6
	and $t4, $t5, $t4
	beq $t4, 1, menu #se a sequencia for essa, volta ao menu principal 
	
	move $t0, $v0
	
loop:
	lb $t1, 0($t0)	#le o primeiro caracter
	
	seq $t2, $t1, '\0'# e verifica se o digito � \0 ou \n 
	seq $t3, $t1, '\n'
	
	or $t2, $t2, $t3
	
	beq $t2, 0, verloop #se n�o for nenhum verifica se � 0 ou 1
	li $t1, '\0' #substitui o \n por \0
	sb $t1, 0($t0) 
	
	addi $sp, $sp, 4 #recupera a linha de onde veio
	lw $ra, 0($sp)
	jr $ra  #se for \0 ou \n retorna
	
	
verloop:	
	seq $t2, $t1, '0' #se for 0 ou 1, continua lendo
	seq $t3, $t1, '1'
	or $t2, $t2, $t3
	
	beq $t2, 0, erroval#se n�o indica erro
	
	addi $t0, $t0, 1
	j loop

erromenu:
	li $v0, 4
	la $a0, strerrom #escreve string ja inserido
	syscall
	j menu	
	
erroval:	
	li $v0, 4
	la $a0, strchinv #escreve string invalido
	syscall
	li $v0, -1 #flag de erro
	addi $sp, $sp, 4 #recupera a linha de onde veio
	lw $ra, 0($sp)
	jr $ra
	
errochrep:
	li $v0, 4
	la $a0, strchrep #escreve string ja inserido
	syscall
	j insere
	
busca:
	li $v0, 4
	la $a0, strbusch #escreve a string buscar chaves
	syscall	
	li $t8, 0 #inicia o counter que vai auxiliar na impressao do caminho percorrido na busca
	li $t9, 0 #sera o contador para imprimir o caminho percorrido na busca
	jal verifica
	beq $v0, -1, busca
	move $s4, $v0 #salva a string em s4
	#chave verificada em $v0 e raiz em $s7
	move $s6, $v0 	 # salva o caminho da chave em s6 para n�o perder
	move $t0, $s6    # registrador temporario 
	move $t1 ,$s7	 # armazena o s7 em t1 para manipular a arvore sem perder a referencia

loopbusca:

	lb $t2, 0($t0)	#recupera o primiro byte da chave
	addi $t9, $t9, 1 #count
	beq $t2, '\0', verificabusca #se o caracter lido for \0, volta para a busca
	addi $t0, $t0, 1 #ve o proximo byte
	
	sub $t2, $t2, '0'
	mul  $t2, $t2, 4 #multiplica por 1 ou 0, para somar a quantidade certa de bytes
	add $t1, $t1, $t2 #move a quantidade
	lw $t2, 0($t1) #acessa a posi��o que deve ir e ve se ja existe um n�
	beq $t2, $zero, errobusca #verifica se o caminho para o proximo n� n�o � valido
	move $t1, $t2
	j loopbusca
	
verificabusca:
	
	lw $t2, 8($t1) 
	beq $t2, 1, imprimeNoEncontrado
	
errobusca:
	li $v0, 4
	la $a0, strbuserro #escreve string de erro na busca
	syscall
	
	la $ra, busca
	j caminhobusca

imprimeNoEncontrado:

	li $v0, 4
	la $a0, strbuscerto #imprime "chave encontrada na �rvore"
	syscall
	move $a0, $s4
	li $v0, 4 #impime a chave buscada
	syscall
	li $v0, 4
	la $a0, strn #imprime \n
	syscall
	
	la $ra, busca
	
caminhobusca:	
	move $t0, $s4
	li $v0, 4
	la $a0, strbusccam #imprime a string de caminho
	syscall
	
	li $v0, 4
	la $a0, strraiz #imprime a str de raiz
	syscall
	
caminhobusca2:
	lb $t2, 0($t0)
	beq $t2, '\0', fimcaminho
	sub $t2, $t2, '0'
	addi $t0, $t0, 1 #atualiza-se o ponteiro, pq nao precisa mais da string
	addi $t8, $t8, 1 #atualiza-se o counter
	beq $t9, $t8, fimcaminho #acaba a impressao, pois o count se igualou ao numero de digitos da busca
	beq $t2, $zero, imprimeesq
	beq $t2, 1, imprimedir	
	
imprimeesq:
	li $v0, 4
	la $a0, strvir #imprime a virgula
	syscall

	li $v0, 4
	la $a0, stresq #escreve string esquerda
	syscall

	j caminhobusca2
	
imprimedir:
	li $v0, 4
	la $a0, strvir #imprime a virgula
	syscall
	
	li $v0, 4
	la $a0, strdir #escreve string direita
	syscall 
	
	j caminhobusca2
	
fimcaminho: #finaliza a impressao do caminho que a busca fez
	li $v0, 4
	la $a0, strn #imprime '\n'
	syscall

	jr $ra

############################### FUNCAO DE REMOCAO ##############################

remove:
	li $v0, 4
	la $a0, strremch #escreve a string buscar chaves
	syscall	
	
	jal verifica
	beq $v0, -1, remove
	
	move $a1, $v0		#$a1 = string
	move $a0, $s7		#$a0 = no
	
	addi $sp, $sp, -12	#avan�a 12 posi��es na stack
	sw $ra, 8($sp)		#armazena os registradores que ser�o usados
	sw $s0, 4($sp)		#para evitar a perda dos valores
	sw $s1, 0($sp)
	
	li $s0, 0		#flag = 0
	li $s1, 0		#count = 0
	jal removendo
	
	move $s4, $a1
	move $t9, $s1
	li $t8, 0
		
	bnez $s0, else_2	#if (flag == 0) {
	li $v0, 4
	la $a0, strbuserro	#printf("%s", strbuserro);
	syscall
	
	jal caminhobusca
	
	j elseFim_2		#}
	
else_2:				# else {
	li $v0, 4
	la $a0, strbuscerto	#printf("%s", strbuscerto);
	syscall
	
	li $v0, 4
	move $a0, $a1		#printf("%s", string);
	syscall
	
	li $v0, 4
	la $a0, strn		#printf("\n");
	syscall

	jal caminhobusca

	li $v0, 4
	la $a0, strchrem	#printf("%s", strchrm);
	syscall
		
elseFim_2:			#}
	
	lw $ra, 8($sp)		#pega o valor de $ra da pilha
	lw $s0, 4($sp)
	lw $s1, 0($sp)
	addi $sp, $sp, 12	#retorna as 12 posi��es da stack
	
	j remove			#return
	
#########################

removendo:			#a0 = no, a1 = string, s0 = flag, s1 = count
	addi $sp, $sp, -12	#-- avan�a pilha --
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	sw $s2, 0($sp)
	
	bnez $a0, naoNulo_		#if (no == null) {
	addi $s1, $s1, -1		#count--;
	j retornaNulo_			#return 0;
					#}
naoNulo_:
	add $t0, $a1, $s1		#char*($t0) p_char = string + count;
	lb $t1, ($t0)			#char($t1) caracter = *p_char;
	
	bne $t1, '\0', else_		#if (caracter == '\0') {
	lw $t2, 8($a0)			#int($t2) terminal = no->val;
	bne $t2, 1, noNaoTerminal_	#if (terminal == 1) {
	li $s0, 1			#flag = 1;
					#}
noNaoTerminal_:
	li $t2, 0			#terminal = 0;
	sw $t2, 8($a0)			#no->val = terminal;
	j elseFim_			#}
	
else_:					#else {
	addi $s1, $s1, 1		#count++;
	subi $t3, $t1, '0'		#int($t3) numero = caracter - '0';
	mul $t4, $t3, 4			#int($t4) aux = numero * 4;
	add $s2, $a0, $t4		#no_aux = &(no->prox[numero]);
	lw $a0, ($s2)			#no = *no_aux;
	jal removendo			#removing (($a0) no, ($a1) string, ($s0) count, ($s1) flag);
	sw $v0, ($s2)			#no->prox[numero] = retorno (removing ());
	lw $a0, 4($sp)			#-- volta o valor de $a0 para no --
					#}
elseFim_:
	lw $t2, 8($a0)			#int($t2) terminal = no->val;
	beqz $t2, noNaoTerminal_2	#if (terminal != 0)
	j retornaNo_			#return no;

noNaoTerminal_2:
	li $t5, 0			#int($t5) i = 0;
loop_:
	bge $t5, 2, fimLoop_		#while (i < 2) {
	lw $t6, ($a0)			#NO($t6) no_filho = *no;
	beqz $t6, noNulo_		#if (no_filho != null)
	j retornaNo_			#return no;
noNulo_:
	addi $a0, $a0, 4		#no = no + 1;
	addi $t5, $t5, 1		#i++;
					#}
fimLoop_:
	
retornaNulo_:
	lw $s2, 0($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12		#-- volta pilha --
	li $v0, 0			#retorno = 0;
	jr $ra
	
retornaNo_:
	lw $s2, 0($sp)
	lw $ra, 8($sp)
	lw $v0, 4($sp)			#retorno = no;
	addi $sp, $sp, 12		#-- volta pilha --
	jr $ra
	
########################################### FIM DA REMOCAO #############################################
	


fim:	li $v0, 10
	syscall
