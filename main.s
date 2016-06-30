######################################################################
# 			     Snake Game                              #
######################################################################
# 	                    Programmed by 	                     #
#           Mikael Mello, Gabriel Lobao and Gabriel Nunes            #
######################################################################
# Tools used:                                                        #
# 	Bitmap Display                                               #
#	Keyboard and Display MMIO                                    #
#                                                                    #
# Bitmap Display Settings:                                           #
#	Unit Width:	1 or 2                                       #
#	Unit Height:	1 or 2                                       #
# 	Display WIdth:	320 or 640                                   #
# 	Display Height:	240 or 480                                   #
#	Base Address for Display: 0xFF000000 (Memory map)            #
######################################################################

.data
SSL:	.word 0, 5, 3			# Score, Size and Lives
HPTP:	.word  37, 24, 37, 25		# Head position (X, Y) and Tail position (X, Y) 0 <= X <= 75, 0 <= Y <= 49
CD: 	.word 1				# Current direction. WASD = 1234
GRID: 	.space 3800			# Number of bytes of a 304x200 pixels grid for the game (76x50 units)
CF: 	.word 5, 5			# Food position
NOTASNO: .word 12
NOTASINFO: .word 65, 500, 60, 500, 57, 500, 62, 300, 64, 300, 62, 300, 61, 300, 63, 300, 61, 300, 60, 200, 58, 200, 60, 600
NOTASNO2: .word 3
NOTASINFO2: .word 52, 500, 50, 500, 48, 700
CD1BIN: .asciiz "src/cd1.bin"
CD2BIN: .asciiz "src/cd2.bin"
CD3BIN: .asciiz "src/cd3.bin"
CDGOBIN:.asciiz "src/cdgo.bin"
GAMEBGBIN: .asciiz "src/gamebg.bin"
GETREADYBIN: .asciiz "src/getready.bin"
GAMEOVERBIN: .asciiz "src/gameover.bin"
LIFEBIN: .asciiz "src/life.bin"
NOLIFEBIN: .asciiz "src/nolife.bin"
LIVESBIN: .asciiz "src/lives.bin"
SCORESIZEBIN: .asciiz "src/scoresize.bin"
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
		
		la $t1, 0xFF100000
		lw $t2, 0($t1)
		lw $t3, 4($t1)
		  		
		beq $t2, $0, KEEPDIR
		
		# This whole KEEPDIR/CUSTOMDIR is to check whether the user is trying to walk on the opposite direction the snake is currently in.
		bne $t3, 119, NOTW1
		beq $s4, 3, KEEPDIR
		j CUSTOMDIR
		NOTW1:
		bne $t3,  97, NOTA1
		beq $s4, 4, KEEPDIR
		j CUSTOMDIR
		NOTA1:
		bne $t3, 115, NOTS1
		beq $s4, 1, KEEPDIR
		j CUSTOMDIR
		NOTS1:
		bne $t3, 100, KEEPDIR
		beq $s4, 2, KEEPDIR
		j CUSTOMDIR
		KEEPDIR:
			bne $s4, 1, NOTW
				li $t3, 119
				j CUSTOMDIR
			NOTW:
			bne $s4, 2, NOTA
				li $t3, 97
				j CUSTOMDIR
			NOTA:
			bne $s4, 3, NOTS
				li $t3, 115
				j CUSTOMDIR
			NOTS:
			bne $s4, 4, NOTD		  		
		  		li $t3, 100
				j CUSTOMDIR
		  	NOTD:
		  		j END
		CUSTOMDIR:
		add $v0, $t3, $zero
		
		addi $t1, $s6, 8
		mulu $t2, $s0, 4
		addu $t1, $t1, $t2
		mulu $t2, $s1, 1280
		addu $s7, $t1, $t2	# $s7 = address of head (to be updated to the new head)
		addu $t1, $s7, $zero	# $t3 = address of head (static so that the old head will be painted over)
	
	# Tests the current pressed key and acts according to it
	W:	bne $v0, 119, A
		addi $s1, $s1, -1	# Updates head's address and XY coordinates.
		addi $s7, $s7, -1280
		addi $s4, $zero, 1	# Updates current direction
		
	A: 	bne $v0,  97, S
		addi $s0, $s0, -1	# Updates head's address and XY coordinates.
		addi $s7, $s7, -4
		addi $s4, $zero, 2	# Updates current direction
		
	S: 	bne $v0, 115, D
		addi $s1, $s1, 1	# Updates head's address and XY coordinates.
		addi $s7, $s7, 1280
		addi $s4, $zero, 3	# Updates current direction
		
	D:	bne $v0, 100, CHECK
		addi $s0, $s0, 1	# Updates head's address and XY coordinates.
		addi $s7, $s7, 4
		addi $s4, $zero, 4	# Updates current direction
				
		CHECK:
		bgt $s0, 75, LESSLIFE
		bgt $s1, 49, LESSLIFE
		blt $s0,  0, LESSLIFE
		blt $s1,  0, LESSLIFE		# Checks if the snake is within the limits of the grid.
		
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
			li $s5, 1		# Turns the FOOD flag on.
			li $v0, 31
			li $a0, 72
			li $a1, 1000
			li $a2, 24
			li $a3, 60
			syscall			# Plays sound
		NOTFOOD:
		j NOTNOT
	
	LESSLIFE:
		la $t0, SSL
		lw $t2, 8($t0)
		bne $t2, $0, NOTGO	# If there's only one life left, game over.
			jal GAMEOVER
			j END
		NOTGO:
		
		la $t5,NOTASNO2
		lw $t6,0($t5)
		la $t5,NOTASINFO2
		li $t7,0
		li $a2,58	# instrumento
		li $a3,100	# volume
		LOOP45:
		beq $t7,$t6, FIM45
		lw $a0,0($t5)		# nota
		lw $a1,4($t5)		# duracao
		li $v0,31		# 33 da pausa a mais
		syscall
		move $a0,$a1		#pausa = duracao
		li $v0,32
		syscall
		addi $t5,$t5,8
		addi $t7,$t7,1
		j LOOP45
		FIM45:
		
		addi $t2, $t2, -1
		sw $t2, 8($t0)
		li $t2, 5
		sw $t2, 4($t0)
		li $t2, 37
		sw $t2, 12($t0)
		sw $t2, 20($t0)
		li $t2, 24
		sw $t2, 16($t0)
		li $t2, 25
		sw $t2, 24($t0)
		li $t2, 1
		sw $t2, 28($t0)		# Resetting all current info about the snake.
		jal FILLSCREEN
		jal FILLGAME
		jal RESETGRID
		jal INITSNAKE
		j GAMELOOP
	NOTNOT:
	
		li $t2, 0
		sw $t2, 0($t1)
		sw $t2, 320($t1)
		sw $t2, 640($t1)
		sw $t2, 960($t1)	# Transforms the head into a part of the body (changes the color)
		
		li $t0, 0x22222222
		sw $t0, 0($s7)
		sw $t0, 320($s7)
		sw $t0, 640($s7)
		sw $t0, 960($s7)	# filling head
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
	
		# If food flag is on, tail is not deleted.
		beq $s5, 1, FOOOOD	
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
			j NOTFOOD2
		FOOOOD:
		jal FILLINFO
		NOTFOOD2:
		
		add $a0, $s4, $zero	# Direction
		add $a1, $s5, $zero	# Is food on.
		jal UPDTSTACK
		
		
		
	NOT:
		la $t0, SSL
		lw $t0, 4($t0)
		divu $t0, $t0, 5
		li $a0, 50
		divu $a0, $a0, $t0
		li $v0, 32
		syscall
		j GAMELOOP
		j END

FILLINFO:
	la $t0, SSL
	lw $t1, 4($t0)		# Size integer
	lw $t0, 0($t0)		# Current score
	
	la $a0, SCORESIZEBIN
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	# Transfer all the file to the VGA memory
	move $a0,$v0
	la $a1,0xFF000005
	li $a2,200
	li $v0,14
	li $t6, 0
	li $t7, 32
	LOOPHEADER:
	beq $t6, $t7, OUTLOOPHEADER
		syscall
		addi $a1, $a1, 320
		addi $t6, $t6, 1
		li $v0, 14
		j LOOPHEADER
	OUTLOOPHEADER:
	# Closes the file
	li $v0,16
	syscall
	
	move $a0, $t0
	li $a1, 115
	li $a2, 5
	li $a3, 0xFF00
	li $v0, 101
	syscall
	move $a0, $t1
	li $a1, 98
	li $a2, 18
	li $a3, 0xFF00
	li $v0, 101
	syscall

	jr $ra
	
GAMEOVER:

	# Game over "song"
	la $t1,NOTASNO
	lw $t2,0($t1)
	la $t1,NOTASINFO
	li $t0,0
	li $a2,58	
	li $a3,100	
	LOOP23:
		beq $t0,$t2, FIM23
		lw $a0,0($t1)		
		lw $a1,4($t1)		
		li $v0,31		
		syscall
		move $a0,$a1		
		li $v0,32
		syscall
		addi $t1,$t1,8
		addi $t0,$t0,1
		j LOOP23
	FIM23:
	
	# Opening gameover.bin
	la $a0,GAMEOVERBIN
	li $a1,0
	li $a2,0
	li $v0,13
	syscall

	blt $v0, 0, NOTOPENED
	
	# Transfer all the file to the VGA memory
	move $a0,$v0
	la $a1,0xFF000000
	li $a2,76800
	li $v0,14
	syscall

	# Closes the file
	li $v0,16
	syscall
	j ENDFILE
	
	# If the file could not be opened, a standard screen is used instead.
	NOTOPENED:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal FILLSCREEN
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	ENDFILE:
	li $v0,10
	syscall
	
	jr $ra
		
# Sets all positions in the grid to 0, so it can be reinitiated by INITSNAKE.
RESETGRID:
	la $t0, GRID
	li $t2, 0
	li $t1, 950
	LOOP12:
	beq $t1, $t2, OUTLOOP12
		sw $0, 0($t0)
		addi $t0, $t0, 4
		addi $t2, $t2, 1
		j LOOP12
	OUTLOOP12:
	jr $ra
		
# Updates lots of info, such as:
# Stack (directions from the tail to the head), apple's position, snake's size and score.
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
	
	beq $a1, 0, LOOP11		# Stuff to do if food flag is activated.
		addi $sp, $sp, -4
		lw $t5, 0($t4)
		sw $t5, 0($sp)		# Allocates and puts the direction
		addi $t5, $t3, 2
		sw $t5, 4($t2)		# Increases the size of the snake
		
		lw $t5, 0($t2)
		lw $t6, 4($t2)
		add $t5, $t5, $t6
		sw $t5, 0($t2)		# Increasing score by the snake's current size.
		
		OTHERAPPLE:
		li $v0, 30
		syscall			# Getting system time as seed.
		li $a1, 75
		li $v0, 42
		syscall
		add $t5, $zero, $a0
		li $a1, 49
		syscall			# Both syscalls generate a random coordinate for the new apple.
		add $t6, $zero, $a0
		
		mulu $t2, $t6, 76
		la $t7, GRID
		addu $t7, $t5, $t7
		addu $t7, $t7, $t2
		lb $t2, 0($t7)
		beq $t2, 1, OTHERAPPLE	# Checks if new apple touches the body, if yes, generates another one.

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
	sb $t2, 0($t3)		# Storing byte 0 to control key input.
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
	la $t0, SSL
	lw $t3, 8($t0)
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal FILLINFO
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	# Loading the Heart equivalent of 3rd life.
	blt $t3, 3, LT3Lives
	la $a0,LIFEBIN
	j Lives3
	LT3Lives:
	la $a0, NOLIFEBIN
	Lives3:
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	li $t1, 0
	li $t2, 20
	
	move $a0,$v0
	la $a1,0xFF0008A4
	li $a2,20
	li $v0,14
	loop3:				# Loop to load 20 lines.
	beq $t1, $t2, outloop3
		syscall
		addi $a1, $a1, 320
		addi $t1, $t1, 1
		li $v0, 14
		j loop3
	outloop3:
	
	# Closes the file
	li $v0,16
	syscall
	
	# Loading the Heart equivalent of 2nd life.
	blt $t3, 2, LT2Lives
	la $a0,LIFEBIN
	j Lives2
	LT2Lives:
	la $a0, NOLIFEBIN
	Lives2:
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	li $t1, 0
	li $t2, 20
	
	move $a0,$v0
	la $a1,0xFF00088C
	li $a2,20
	li $v0,14
	loop32:				# Same loop as before.
	beq $t1, $t2, outloop32
		syscall
		addi $a1, $a1, 320
		addi $t1, $t1, 1
		li $v0, 14
		j loop32
	outloop32:
	
	# Closes the file
	li $v0,16
	syscall
	
	# Loading the Heart equivalent of 1st and last life.
	blt $t3, 1, NoLives
	la $a0,LIFEBIN
	j Lives1
	NoLives:
	la $a0, NOLIFEBIN
	Lives1:
	li $a1,0
	li $a2,0
	li $v0,13
	syscall

	li $t1, 0
	li $t2, 20
	
	move $a0,$v0
	la $a1,0xFF000874
	li $a2,20
	li $v0,14
	loop321:
	beq $t1, $t2, outloop321
		syscall
		addi $a1, $a1, 320
		addi $t1, $t1, 1
		li $v0, 14
		j loop321
	outloop321:
	
	# Closes the file
	li $v0,16
	syscall
	
	# Opening gameover.bin
	la $a0,GETREADYBIN
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	# Transfer all the file to the VGA memory
	move $a0,$v0
	la $a1,0xFF002800
	li $a2,66560
	li $v0,14
	syscall

	# Closes the file
	li $v0,16
	syscall
	
	li $a0, 1000
	li $v0, 32
	syscall
	
	# Opening gameover.bin
	la $a0,CD3BIN
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	# Transfer all the file to the VGA memory
	move $a0,$v0
	la $a1,0xFF002800
	li $a2,66560
	li $v0,14
	syscall

	# Closes the file
	li $v0,16
	syscall
	
	li $a0, 1000
	li $v0, 32
	syscall
	
	# Opening gameover.bin
	la $a0,CD2BIN
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	# Transfer all the file to the VGA memory
	move $a0,$v0
	la $a1,0xFF002800
	li $a2,66560
	li $v0,14
	syscall

	# Closes the file
	li $v0,16
	syscall
	
	li $a0, 1000
	li $v0, 32
	syscall
	
	# Opening gameover.bin
	la $a0,CD1BIN
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	# Transfer all the file to the VGA memory
	move $a0,$v0
	la $a1,0xFF002800
	li $a2,66560
	li $v0,14
	syscall

	# Closes the file
	li $v0,16
	syscall
	
	li $a0, 1000
	li $v0, 32
	syscall
	
	# Opening gameover.bin
	la $a0,CDGOBIN
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	# Transfer all the file to the VGA memory
	move $a0,$v0
	la $a1,0xFF002800
	li $a2,66560
	li $v0,14
	syscall

	# Closes the file
	li $v0,16
	syscall
	
	li $a0, 1000
	li $v0, 32
	syscall
	
	# Opening gameover.bin
	la $a0,GAMEBGBIN
	li $a1,0
	li $a2,0
	li $v0,13
	syscall
	
	# Transfer all the file to the VGA memory
	move $a0,$v0
	la $a1,0xFF002800
	li $a2,66560
	li $v0,14
	syscall

	# Closes the file
	li $v0,16
	syscall
	
FORA2:	jr $ra

END:
