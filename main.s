.data
SS:	.word 0, 5			# Score and Size
HPTP:	.word  100, 100, 100, 95	# Head position (X, Y) and Tail position (X, Y)
CD: 	.word 1				# Current direction. NSEW = 1234
GRID: 	.space 60800			# Number of bytes of a 304x200 pixels grid for the game
.text
# Fills the screen with the border color
	li $t1,0xFF012C00
	li $s2,0xFF000000
	li $s1,0x10011342
LOOP: 	beq $s2,$t1,FORA
	sw $s1,0($s2)
	addi $s2,$s2,4
	j LOOP
FORA:	
# Fills the screen with the space where the snake will be allowed to be on.
	li $t1,0xFF012200	# End of the grid
	li $s2,0xFF002800	# Start of the grid
	li $s1,0xEFEFEFEF	# Color of the grid
	li $t4,0xFF000000	# Number to subtract so a remainder can be found easier.
	li $t6, 8		# Border offset
	li $t7, 311		# Border offset
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
FORA2:
	