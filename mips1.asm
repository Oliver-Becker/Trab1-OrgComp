	.data

	
	.text
main:

	move $a0, $s7	#a0 = s7 (raíz da arvore)
	move $a1, $s6	#a1 = s6 (string)
	jal remove
	
	li $v0, 10	#encerra o programa
	syscall

############################### FIM DA MAIN ##########################

remove:
	addi $sp, $sp, -12	#avança 12 posições na stack
	sw $ra, 8($sp)		#armazena os registradores que serão usados
	sw $s0, 4($sp)		#para evitar a perda dos valores
	sw $s1, 0($sp)
	
	li $s0, 0		#flag = 0
	li $s1, 0		#count = 0
	
	jal removing
	move $a0, $v0		#raiz = removing()
	
	bne $s0, $zero, seflag1	#if (flag != 0)
	li $t0, -1		#aux = -1
	mult $s1, $t0		#lo = count * -1
	move $s1, mflo		#count = lo
seflag1:
	move $v0, $s1		#retorno = count
	
	lw $ra, 0($sp)		#pega o valor de $ra da pilha
	addi $sp, $sp, 12	#retorna as 12 posições da stack
	
	jr $ra			#return
	
#########################

removing:			#a0 = no, a1 = string, s0 = flag, s1 = count
	addi $sp, $sp, -12	#-- avança pilha --
	sw $ra, 8($sp)
	sw $a0, 4($sp)
	sw $a1, 0($sp)
	
	bnez $a0, naoNulo_	#if (no == null) {
	addi $s0, $s0, -1	#count--;
	j renotaNulo_		#return 0;
				#}
naoNulo_:
	li $t4, 4 			#int($t4) aux = 4;
	mult $s1, $t4			#lo = count * aux;
	add $t0, $a1, mflo		#char*($t0) p_char = string+aux;
	lw $t1, ($t0)			#char($t1) caracter = *p_char;
	
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
	addi $s1, $s1, 1		#d++;
	add $t0, $t0, 4			#p_char = p_char+1;
	lw $t1, ($t0)			#caracter = *p_char;
	subi $t3, $t1, '0'		#int($t3) numero = caracter - '0';
	li $t4, 4			#int($t4) aux = 4;
	mult $t3, $t4			#lo = numero * aux;
	add $a0, $a0, mflo		#no = &(no->prox[numero]);
	jal removing			#removing (($a0) no, ($a1) string, ($s0) count, ($s1) flag);
	sw $v0, ($a0)			#no->prox[numero] = retorno (removing ());
	lw $a0, 4($sp)			#-- volta o valor de $a0 para no --
					#}
elseFim_:
	lw $t2, 8($a0)			#int($t2) terminal = no->val;
	beqz $t2, noNaoTerminal_2	#if (terminal != 0)
	j retornaNo_			#return no;

noNaoTerminal_2:
	li $t5, 0			#int($t5) i = 0;
loop_:
	bge $t5, 2, fim_loop_		#while (i < 2) {
	lw $t6, ($a0)			#NO($t6) no_filho = *no;
	beqz $t6, noNulo_		#if (no_filho != null)
	j retornaNo_			#return no;
noNulo_:
	addi $a0, $a0, 4		#no = no + 1;
	addi $t5, $t5, 1		#i++;
					#}
fimLoop_:
	
retornaNulo_:
	lw $ra, 8($sp)
	addi $sp, $sp, 12	#-- volta pilha --
	li $v0, 0		#retorno = 0;
	jr $ra
	
retornaNo_:
	lw $ra, 8($sp)
	addi $sp, $sp, 12	#-- volta pilha --
	move $v0, $a0		#retorno = no;
	jr $ra
	
	
