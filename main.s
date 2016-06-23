.data
SSL:	.word 0, 5, 3			# Score, Size and Lives
HPTP:	.word  37, 24, 37, 25		# Head position (X, Y) and Tail position (X, Y) 0 <= X <= 75, 0 <= Y <= 49
CD: 	.word 1				# Current direction. WASD = 1234
GRID: 	.space 3800			# Number of bytes of a 304x200 pixels grid for the game (76x50 units)
CF: 	.word 5, 5			# Food position
.text	
	jal FILLSCREEN
	jal FILLGAME
	jal INITSNAKE
			
	li $s6, 0xFF002800		# Grid starting address
	GAMELOOP:
		la $t0, HPTP
		lw $s0, 0($t0)		# Head X
		lw $s1, 4($t0)		# Head Y
		lw $s2, 8($t0)		# Tail X
		lw $s3, 12($t0)		# Tail Y
		li $s5, 0		# Food flag
		la $t0, CD		
		lw $s4, 0($t0)		# Current Direction
		
		li $v0, 12
		syscall
  		
		addi $t1, $s6, 8
		mulu $t2, $s0, 4
		addu $t1, $t1, $t2
		mulu $t2, $s1, 1280
		addu $t1, $t1, $t2	# $t1 = address of head
		addu $t3, $t1, $zero
	
	# Testa as teclas e atualiza dados de acordo com elas.
	W:	bne $v0, 119, A
		beq $s4, 3, NOT
		addi $s1, $s1, -1	# Atualiza (X,Y) e endereco da cabeca
		addi $t1, $t1, -1280
		addi $s4, $zero, 1	# Atualiza direcao atual
		
	A: 	bne $v0,  97, S
		beq $s4, 4, NOT
		addi $s0, $s0, -1	# Atualiza (X,Y) e endereco da cabeca
		addi $t1, $t1, -4
		addi $s4, $zero, 2	# Atualiza direcao atual
		
	S: 	bne $v0, 115, D
		beq $s4, 1, NOT
		addi $s1, $s1, 1	# Atualiza (X,Y) e endereco da cabeca
		addi $t1, $t1, 1280
		addi $s4, $zero, 3	# Atualiza direcao atual
		
	D:	bne $v0, 100, CHECK
		beq $s4, 2, NOT
		addi $s0, $s0, 1	# Atualiza (X,Y) e endereco da cabeca
		addi $t1, $t1, 4
		addi $s4, $zero, 4	# Atualiza direcao atual
				
	CHECK:
	bgt $s0, 75, LESSLIFE
	bgt $s1, 49, LESSLIFE
	blt $s0,  0, LESSLIFE
	blt $s1,  0, LESSLIFE
	
	mulu $t2, $s1, 76
	la $t6, GRID
	addu $t6, $s0, $t6
	addu $t6, $t6, $t2
	lb $t2, 0($t6)
	beq $t2, 1, LESSLIFE		# Checks if touches the body
	
	la $t6, CF
	lw $t4, 0($t6)
	lw $t5, 4($t6)
	
		addi $t7, $s6, 8
		mulu $t2, $t4, 4
		addu $t7, $t7, $t2
		mulu $t2, $t5, 1280
		addu $t7, $t7, $t2	# $t7 = address of apple
		li $t0, 0x03030303
		sw $t0, 0($t7)
		sw $t0, 320($t7)
		sw $t0, 640($t7)
		sw $t0, 960($t7)	# filling apple
	
	bne $s0, $t4, NOTFOOD
	bne $s1, $t5, NOTFOOD
	li $s5, 1			# Turns the FOOD flag on.
	NOTFOOD:
	j NOTNOT
	
	LESSLIFE:
		jal FILLSCREEN
		j END
	NOTNOT:
	
		li $t2, 0
		sw $t2, 0($t3)
		sw $t2, 320($t3)
		sw $t2, 640($t3)
		sw $t2, 960($t3)	# Transforms the head into a part of the body (changes the color)
		
		li $t0, 0x22222222
		sw $t0, 0($t1)
		sw $t0, 320($t1)
		sw $t0, 640($t1)
		sw $t0, 960($t1)	# filling head
		la $t0, HPTP
		sw $s0, 0($t0)
		sw $s1, 4($t0)		# Updating head coordinates
		la $t0, CD
		sw $s4, 0($t0)		# Updating current direction
		
		mulu $t3, $s1, 76
		la $t1, GRID
		addu $t1, $s0, $t1
		addu $t1, $t1, $t3
		li $t2, 1
		sb $t2, 0($t1)		# Setting 1 to grid.
	
		beq $s5, 1, FOOOOD	# If food flag is on, tail is not deleted.
			addi $t3, $s6, 8
			mulu $t2, $s2, 4
			addu $t3, $t3, $t2
			mulu $t2, $s3, 1280
			addu $t3, $t3, $t2	# $t1 = address of last piece of body
			
			li $t2, 0xEFEFEFEF
			sw $t2, 0($t3)
			sw $t2, 320($t3)
			sw $t2, 640($t3)
			sw $t2, 960($t3)	# Deletes the last piece of the body
		FOOOOD:
		
		
		add $a0, $s4, $zero	# Direction
		add $a1, $s5, $zero	# Is food on.
		jal UPDTSTACK
		
		
		
	NOT:
		
		j GAMELOOP
		j END
		
UPDTSTACK:	
	lw $t0, 0($sp)
	la $t1, HPTP
	lw $t2, 8($t1)
	lw $t3, 12($t1)
	
	beq $a1, 1, FOODON		# If food is on, tail not muted.
		bne $t0, 1, A2
		addi $t3, $t3, -1
		A2:
		bne $t0, 2, S2
		addi $t2, $t2, -1
		S2:
		bne $t0, 3, D2
		addi $t3, $t3, +1
		D2:
		bne $t0, 4, NOTD2
		addi $t2, $t2, +1
		NOTD2:
		sw $t2, 8($t1)
		sw $t3,12($t1)		# Updating new tail's position
		
		mulu $t0, $t3, 76
		la $t1, GRID
		addu $t1, $t2, $t1
		addu $t1, $t1, $t0
		sb $0, 0($t1)		# Setting 0 to tail's grid position.		
		
	FOODON:
	add $a2, $zero, $a0
	la $t2, SSL
	lw $t3, 4($t2)
	addi $t3, $t3, -1
	li $t1, 0
	add $t4, $sp, $zero
	
	beq $a1, 0, LOOP11		# If food is on, allocates one more word in the stack and puts the first direction there.
		addi $sp, $sp, -4
		lw $t5, 0($t4)
		sw $t5, 0($sp)		# Allocates and puts the direction
		addi $t5, $t3, 2
		sw $t5, 4($t2)		# Increases the size of the snake
		li $a0, 30
		li $a1, 75
		li $v0, 42
		syscall
		add $t5, $zero, $a0
		li $a1, 49
		syscall			# Both syscalls generate a random coordinate for the new apple.
		add $t6, $zero, $a0
		la $t2, CF
		sw $t5, 0($t2)		# Storing new apple's coordinates.
		sw $t6, 4($t2)		
	LOOP11:
		beq $t1, $t3, OUTLOOP11	# Loop to move the stack
		lw $t5, 4($t4)
		sw $t5, 0($t4)
		addi $t4, $t4, 4	
		addi $t1, $t1, 1
		j LOOP11
	OUTLOOP11:
	sw $a2, 0($t4)			# Storing new direction on the stack.
	jr $ra
		
# Fills the screen with the border color
FILLSCREEN:
	li $t1,0xFF012C00
	li $t3,0xFF000000
	li $t2,0x10011342
	LOOP: 	beq $t3,$t1,FORA
		sw $t2,0($t3)
		addi $t3,$t3,4
		j LOOP
	FORA:	
	li $t3, 0xFF000000
	li $t2, 0
	sb $t2, 0($t3)
	jr $ra

# Draws the initial snake (size 6)
# There is no problem in using s registers because this function is called in the very beginning of the program
INITSNAKE:
	la $t0, HPTP
	lw $s0, 0($t0)
	lw $s1, 4($t0)
	lw $s2, 8($t0)
	lw $s3, 12($t0)
	li $s4, 0x00000000
	li $s5, 0x22222222
	li $s6, 0xFF002800
	
	addiu $t1, $s6, 8
	mulu $t2, $s0, 4
	addu $t1, $t1, $t2
	mulu $t2, $s1, 1280
	addu $t1, $t1, $t2		# $t1 = address of head
	
	sw $s5, 0($t1)
	sw $s5, 320($t1)
	sw $s5, 640($t1)
	sw $s5, 960($t1)		# filling head
	
	mulu $t2, $s1, 76
	la $t1, GRID
	addu $t1, $s0, $t1
	addu $t1, $t1, $t2
	li $t2, 1
	sb $t2, 0($t1)			# Setting 1 to grid.
	
	addiu $t1, $s6, 8
	mulu $t2, $s2, 4
	addu $t1, $t1, $t2
	mulu $t2, $s3, 1280
	addu $t1, $t1, $t2		# $t1 = address of aftertail
	li $t3, 0
	la $t4, SSL
	lw $t4, 4($t4)
	LOOP3:	beq $t3, $t4, OUTLOOP
		sw $s4, 0($t1)
		sw $s4, 320($t1)
		sw $s4, 640($t1)
		sw $s4, 960($t1)	# filling tail
		addi $sp, $sp, -4
		li $t7, 1
		sw $t7, 0($sp)
		
		mulu $t6, $s3, 76
		la $t7, GRID
		addu $t7, $s0, $t7
		addu $t7, $t7, $t6
		li $t6, 1
		sb $t6, 0($t1)
		addi $s3, $s3, 1
		
		addiu $t1, $t1, 1280
		addi $t3, $t3, 1
		j LOOP3
	OUTLOOP:
	addi $s3, $s3, -1
	sw $s3, 12($t0)		# Current Y index of tail
	jr $ra
	
# Fills the screen with the space where the snake will be allowed to be on.
# There is no problem in using s registers because this function is called in the very beginning of the program
FILLGAME: 
	li $t1,0xFF012200		# End of the grid
	li $s2,0xFF002800		# Start of the grid
	li $s1,0xEFEFEFEF		# Color of the grid
	li $t4,0xFF000000		# Number to subtract so a remainder can be found easier.
	li $t6, 8			# Border offset
	li $t7, 311			# Border offset
	LOOP2: 	beq $s2,$t1,FORA2	# Checks if the end is 
		subu $t0, $s2, $t4
		div $t3, $t0, 320	
		mfhi $t3		# Gets X index on the grid.
		slt $t5, $t3, $t6	
		beq $t5, 1, T
		sgt $t5, $t3, $t7
		beq $t5, 1, T		# Checks if the current index is on the border limits.
		sw $s1,0($s2)
	T:	addi $s2,$s2,4
	j LOOP2
FORA2:	jr $ra

END:
