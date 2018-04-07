	.data
	.asciiz
	
	.text
main:

	move $a0, $s7	#a0 = s7 (raíz da arvore)
	move $a1, $s6	#a1 = s6 (string)
	jal remove
	
	li $v0, 10	#encerra o programa
	syscall

############################### FIM DA MAIN ##########################

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
	
#########################

removing:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	
	