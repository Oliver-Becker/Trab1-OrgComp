	.data
	.align 0

strmenu: .asciiz "MENU INICIAL\n\n1- Inserção\n2- Remoção\n3- Busca\n4- Visualização\n5- Fim\n\nEscolha uma opção (1 a 5): "		
strvalinv: .asciiz "Valor inválido\n\n"
strinsch: .asciiz "Digite o binário para inserção: "
strremch: .asciiz "Digite o binário para remoção: "
strbusch: .asciiz "Digite o binário para busca: "

	.align 2
	.text  
main:
	li $v0, 9 # aloca nó raiz da árvore
	li $a0, 12
	syscall
	
	move $s7, $v0 # armazena a raiz em s7
	li $t0, 2 #define nó como raiz
	sw $zero, 0($s7)#zera os filhos e marca nó como raiz
	sw $zero, 4($s7)
	sw $t0, 8($s7)
	
		
### FIM DA MAIN ####
menu: 	
	li $v0, 4
	la $a0, strmenu #escreve string menu
	syscall	
	
	li $v0, 5 #lê um inteiro
	syscall
	
	bgt $v0, 5, erro #verifica se o numero é valido
	blt $v0, 1, erro 
	
	beq $v0, 1, insere

	#beq $v0, 2, remove
#	move $a0, $s7	#a0 = s7 (raíz da arvore)
#	move $a1, $s6	#a1 = s6 (string)
#	jal remove

	#beq $v0, 3, busca
	#beq $v0, 4, vizualiza
	beq $v0, 5, fim
	
insere:
	li $v0, 4
	la $a0, strinsch #escreve a string inserir chaves
	syscall	
	jal verifica
	#chave verificada em $v0 e raiz em $s7
	move $s6, $v0 	 # salva o caminho da chave em s6 para não perder
	move $t0, $s6    # registrador temporario 
	move $t1 ,$s7	 # armazena o s7 em t1 para manipular a arvore sem perder a referencia
		
loopins:
	lb $t2, 0($t0)	#recupera o primiro byte da chave
	beq $t2, '\0', fimloopins #se o caracter lido for \0, volta para a inserção
	lb $t3, 1($t0) #le o proximo caracter para ver se é o elemento final e indicar chave
	li $t4, 0	#inicia como nó nao valido
	bne $t3, '\0', loopins2 #se o proximo não for \0 pula, se não indica como nó valido
	li $t4, 1
	 	
loopins2:
	jal criano
	#transforma t2 em int e usa o valor para saber em qual posição será adicionado o endereço
	sub $t2, $t2, '0'
	mul  $t2, $t2, 4 #multiplica por 1 ou 0, para somar a quantidade certa de bytes
	add $t1, $t1, $t2 #move a quantidade
	sw $a0, 0($t1) 
	sub $t1, $t1, $t2 #volta para a original
	move $t1, $a0	#atualiza qual nó será visitado
	
fimloopins:
	
	j insere # caso chege em \0 volta ao modo de inserção

criano:
	li $v0, 9 #aloca o novo nó e zera seus parametros
	li $a0, 12
	syscall
	
	sw $zero, 0($v0)
	sw $zero, 4($v0)
	sw $t4  , 8($v0)
	
	jr $ra 
	

verifica:
	sw $ra, 0($sp)#salva a posição de onde veio
	addi $sp, $sp, -4
		
	li $v0, 9 #aloca espaço para ler o tamanho maximo da sting
	li $a0, 17
	syscall
	
	move $a0, $v0
	
	li $v0, 8#le 17 bits para que o \n não fique no buffer e atrapalhe a proxima leitura 
	li $a1, 17
	syscall	
	move $v0, $a0
	
	
	lb $t1, 0($v0) #le os 3 primeiros elementos para ver se é o valor de retorno ao menu
	lb $t2, 1($v0) 
	lb $t3, 2($v0)
		
	seq $t4, $t1, '-' #ve se os caracteres são na sequencia -1\n ou -1\0 
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
	
	seq $t2, $t1, '\0'# e verifica se o digito é \0 ou \n 
	seq $t3, $t1, '\n'
	
	or $t2, $t2, $t3
	
	beq $t2, 0, verloop #se não for nenhum verifica se é 0 ou 1
	li $t1, '\0' #substitui o \n por \0
	sb $t1, 0($t0) 
	
	addi $sp, $sp, 4 #recupera a linha de onde veio
	lw $ra, 0($sp)
	jr $ra  #se for \0 ou \n retorna
	
	
verloop:	
	seq $t2, $t1, '0' #se for 0 ou 1, continua lendo
	seq $t3, $t1, '1'
	or $t2, $t2, $t3
	
	beq $t2, 0, erro#se não indica erro
	
	addi $t0, $t0, 1
	j loop

########################## Função de remoção de nós ############################
remove:
	addi $sp, $sp, -4	#avança 4 posições na stack
	sw $ra, 0($sp)		#armazena o $ra na pilha
	
	li $s0, 0		#flag = 0
	li $s1, 0		#count = 0
	
	jal removing
	move $a0, $v0		#raiz = removing()
	
	bne $s0, $zero, seflag1	#if (flag != 0)
	li $t0, -1		#aux = -1
	mult $s1, $t0		#lo = count * -1
	move $s1, lo		#count = lo
seflag1:
	move $v0, $s1		#retorno = count
	
	lw $ra, 0($sp)		#pega o valor de $ra da pilha
	addi $sp, $sp, -4	#retorna as 4 posições da stack
	
	jr $ra			#return
	
##############

removing:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
############################ Fim da função de remover ##########################

erro:	
	li $v0, 4
	la $a0, strvalinv #escreve string invalido
	syscall
	
fim:	li $v0, 10
	syscall
	
		
