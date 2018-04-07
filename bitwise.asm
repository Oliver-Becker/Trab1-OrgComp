	.data
	.align 0

strmenu: .asciiz "MENU INICIAL\n\n1- Inser��o\n2- Remo��o\n3- Busca\n4- Visualiza��o\n5- Fim\n\nEscolha uma op��o (1 a 5): "		
strvalinv: .asciiz "Valor inv�lido\n\n"
strinsch: .asciiz "Digite o bin�rio para inser��o: "
strremch: .asciiz "Digite o bin�rio para remo��o: "
strbusch: .asciiz "Digite o bin�rio para busca: "

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
	
	bgt $v0, 5, erro #verifica se o numero � valido
	blt $v0, 1, erro 
	
	beq $v0, 1, insere

	#beq $v0, 2, remove
#	move $a0, $s7	#a0 = s7 (ra�z da arvore)
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
	move $s6, $v0 	 # salva o caminho da chave em s6 para n�o perder
	move $t0, $s6    # registrador temporario 
	move $t1 ,$s7	 # armazena o s7 em t1 para manipular a arvore sem perder a referencia
		
loopins:
	lb $t2, 0($t0)	#recupera o primiro byte da chave
	beq $t2, '\0', fimloopins #se o caracter lido for \0, volta para a inser��o
	lb $t3, 1($t0) #le o proximo caracter para ver se � o elemento final e indicar chave
	li $t4, 0	#inicia como n� nao valido
	bne $t3, '\0', loopins2 #se o proximo n�o for \0 pula, se n�o indica como n� valido
	li $t4, 1
	 	
loopins2:
	jal criano
	#transforma t2 em int e usa o valor para saber em qual posi��o ser� adicionado o endere�o
	sub $t2, $t2, '0'
	mul  $t2, $t2, 4 #multiplica por 1 ou 0, para somar a quantidade certa de bytes
	add $t1, $t1, $t2 #move a quantidade
	sw $a0, 0($t1) 
	sub $t1, $t1, $t2 #volta para a original
	move $t1, $a0	#atualiza qual n� ser� visitado
	
fimloopins:
	
	j insere # caso chege em \0 volta ao modo de inser��o

criano:
	li $v0, 9 #aloca o novo n� e zera seus parametros
	li $a0, 12
	syscall
	
	sw $zero, 0($v0)
	sw $zero, 4($v0)
	sw $t4  , 8($v0)
	
	jr $ra 
	

verifica:
	sw $ra, 0($sp)#salva a posi��o de onde veio
	addi $sp, $sp, -4
		
	li $v0, 9 #aloca espa�o para ler o tamanho maximo da sting
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
	
	beq $t2, 0, erro#se n�o indica erro
	
	addi $t0, $t0, 1
	j loop

########################## Fun��o de remo��o de n�s ############################
remove:
	addi $sp, $sp, -4	#avan�a 4 posi��es na stack
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
	addi $sp, $sp, -4	#retorna as 4 posi��es da stack
	
	jr $ra			#return
	
##############

removing:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
############################ Fim da fun��o de remover ##########################

erro:	
	li $v0, 4
	la $a0, strvalinv #escreve string invalido
	syscall
	
fim:	li $v0, 10
	syscall
	
		
