.data

Buffer: 	.space 	0x80000		#512 wide x 256 high pixels
SpeedofX:	.word	0		# x velocity start 0
SpeedofY:	.word	0		# y velocity start 0
x:		.word	50		# x position
y:		.word	27		# y position
body:		.word	7624		
XcharacterEaten:.word	32		#  x position
YcharacterEaten:.word	16		#  y position
WUp :		.word	0x00000000	# Black color up
SDown :		.word	0x01000000	# Black color down
ALeft :		.word	0x02000000	# Black color left
DRight :	.word	0x03000000	# green color right
xCoordinate :	.word	64		# x location of the coordinate on the display
yCoordinate :	.word	4		# y location of the coordinate on the display


.text
main:

## Color of baground of the game

	la 	$a0, Buffer		# load  addres
	li 	$a1, 8192		
	li 	$a2, 0x00d3d3d3		# light gray 
l1:
	sw   	$a2, 0($a0)
	addi 	$a0, $a0, 4 	
	addi 	$a1, $a1, -1	# subtract the number of ixels
	bnez 	$a1, l1		# repeat != 0
	
### Game screen/Boarder
	
	# top wall section
	la	$a0, Buffer		# load  addres
	addi	$a1, $zero, 64		# row legth to 64
	li 	$a2, 0x00000000		#  black color
Topscreen:
	sw	$a2, 0($a0)		
	addi	$a0, $a0, 4		
	addi	$a1, $a1, -1		
	bnez	$a1, Topscreen	
	
	# Bottom wall section
	la	$a0, Buffer		# load  buffer addres
	addi	$a0, $a0, 7936		# set pixel to be near the bottom left
	addi	$a1, $zero, 64		# row lenght to 512

Bottomscreen:
	sw	$a2, 0($a0)		
	addi	$a0, $a0, 4		#Loop
	addi	$a1, $a1, -1		
	bnez	$a1, Bottomscreen	
	
	# left wall section
	la	$a0, Buffer		# load buffer address
	addi	$a1, $zero, 256		# coloumn lenght to 512

Leftscreen:
	sw	$a2, 0($a0)		
	addi	$a0, $a0, 256		
	addi	$a1, $a1, -1		
	bnez	$a1, Leftscreen		# Loop
	
	
	la	$a0, Buffer		# load buffer address
	addi	$a0, $a0, 508		
	addi	$a1, $zero, 255		# coloumn lenght to 512

Rightscreen:
	sw	$a2, 0($a0)		# color Pixel black
	addi	$a0, $a0, 256		# go to next pixel
	addi	$a1, $a1, -1		# decrease pixel count
	bnez	$a1, Rightscreen	# repeat unitl pixel count == 0
	
	
	la	$a0, Buffer		
	lw	$s2, body		# s2 = body of the player
	lw	$s3, WUp		# s3 = direction of the player
	
	add	$a1, $s2, $a0		# a1 is the starting position
	sw	$s3, 0($a1)		# draw pixel where Player is
	addi	$a1, $a1, -256		# set a1 to pixel above
	sw	$s3, 0($a1)		# draw pixel where Player is
	
	
	### draw initial Character
	jal 	drawCharacter

LoopUpdate:

	lw	$a3, 0xffff0004		# get the keyboard input
	
	
	addi	$v0, $zero, 32	# syscall sleep
	addi	$s0, $zero, 66	# 66 ms for loop buffer
	syscall
	
	beq	$a3, 100, moveRight	# if user presses 'd' branch to the moveright code
	beq	$a3, 97, moveLeft	# else if user presses 'a' branch to the moveLeft code
	beq	$a3, 119, moveUp	# if user presses 'w' branch to the moveUp code
	beq	$a3, 115, moveDown	# else if user presses 's' branch to the moveDown code
	beq	$a3, 0, moveUp		# start game by moving upwards
	
moveUp:
	lw	$s3, WUp		# s3 = direction of Player
	add	$s0, $s3, $zero		# a0 = direction of Player
	jal	updatePlayer
	
	# move the Player
	jal 	PositionUpdated
	
	j	exitMoving 	

moveDown:
	lw	$s3, SDown	# s3 = direction of Player
	add	$s0, $s3, $zero	# a0 = direction of Player
	jal	updatePlayer
	
	# move the Player
	jal 	PositionUpdated
	
	j	exitMoving
	
moveLeft:
	lw	$s3, ALeft	
	add	$s0, $s3, $zero	
	jal	updatePlayer
	
	# move the Player
	jal 	PositionUpdated
	
	j	exitMoving
	
moveRight:
	lw	$s3, DRight	
	add	$s0, $s3, $zero	
	jal	updatePlayer
	
	# move the Player
	jal 	PositionUpdated

	j	exitMoving

exitMoving:
	j 	LoopUpdate		# loop back to beginning

updatePlayer:

	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updatePlayer frame pointer
	
	### DRAW HEAD
	lw	$a0, x		# a0 = x of Player
	lw	$a1, y		# a1 = y of Player
	lw	$a2, xCoordinate	
	mult	$a1, $a2		
	mflo	$a3			
	add	$a3, $a3, $a0		
	lw	$a2, yCoordinate	
	mult	$a3, $a2		
	mflo	$a0			
	
	la 	$a1, Buffer		# load buffer address
	add	$a0, $a1, $a0		
	lw	$a1, 0($a0)		
	sw	$s0, 0($a0)		# stores direction and the color on the display
	
	
	### Movement of Player/Velocity
	lw	$a2, WUp			# load up = 0x0000ff00
	beq	$s0, $a2, setVelocityUp	# if direction and color is equal to player going up branch to setVelocityUp
	
	lw	$a2, SDown			# load word Player down = 0x0100ff00
	beq	$s0, $a2, setVelocityDown	# if direction and color is equal to player going down branch to setVelocityDown
	
	lw	$a2, ALeft			# load word Player left = 0x0200ff00
	beq	$s0, $a2, setVelocityLeft	# if direction and color is equal to player going left branch to setVelocityleft
	
	lw	$a2, DRight			# load word Player right = 0x0300ff00
	beq	$s0, $a2, setVelocityRight	# if direction and color is equal to player going right branch to setVelocityright
	
setVelocityUp:
	addi	$a2, $zero, 0		# set velocity to 0 in x direction
	addi	$t3, $zero, -1	 	# set velocity to -1 in y direction
	sw	$a2, SpeedofX		# update SpeedofX 
	sw	$t3, SpeedofY		# update SpeedofY
	j exitVelocitySet
	
setVelocityDown:
	addi	$a2, $zero, 0		# set velocity to 0 in x direction
	addi	$t3, $zero, 1 		# set velocity to 1 in y direction
	sw	$a2, SpeedofX		
	sw	$t3, SpeedofY		
	j exitVelocitySet
	
setVelocityLeft:
	addi	$a2, $zero, -1		# set velocity to -1 in x direction
	addi	$t3, $zero, 0 		# set velocity to 0 in y direction
	sw	$a2, SpeedofX		# update SpeedofX in memory
	sw	$t3, SpeedofY		# update SpeedofY in memory
	j exitVelocitySet
	
setVelocityRight:
	addi	$a2, $zero, 1		# set velocity to 1 in x direction
	addi	$t3, $zero, 0 		# set velocity to 0 in y direction
	sw	$a2, SpeedofX		
	sw	$t3, SpeedofY		
	j exitVelocitySet
	
exitVelocitySet:
	
	li 	$a2, 0x00ff0000		
	bne	$a2, $a1, head	
	
	jal 	newCharactereLocation
	jal	drawCharacter
	j	exitUpate
	
head:

	li	$a2, 0x00d3d3d3			# light gray
	beq	$a2, $a1, validHeadSquare	# if head is in background branch
	
	addi 	$v0, $zero, 10			# exit the program
	syscall
	
validHeadSquare:

	
	lw	$a0, body		# a0 = body
	la 	$a1, Buffer		
	add	$a2, $a0, $a1		# a2 is location on the display
	li 	$a3, 0x00d3d3d3		
	lw	$a1, 0($a2)		# t1 is direction and color
	sw	$a3, 0($a2)		
	
	### update 
	lw	$a2, WUp			# 0x0000ff00
	beq	$a2, $a1, NextpositionUp	# if direction and color is equal to Player going up branch to NextpositionUp
	
	lw	$a2, SDown			# 0x0100ff00
	beq	$a2, $a1, NextpositionDown	# if direction and color is equal to Player going down branch to NextpositionDown
	
	lw	$a2, ALeft			# 0x0200ff00
	beq	$a2, $a1, NextpositionLeft	# if direction and color is equal to Player going left branch to NextpositionLeft
	
	lw	$a2, DRight			# 0x0300ff00
	beq	$a2, $a1, NextpositionRight	# if direction and color is equal to Player going right branch to NextpositionRight
	
NextpositionUp:
	addi	$a0, $a0, -256		# body - 256
	sw	$a0, body		
	j exitUpate
	
NextpositionDown:
	addi	$a0, $a0, 256		# body + 256
	sw	$a0, body		
	j exitUpate
	
NextpositionLeft:
	addi	$a0, $a0, -4		# body - 4
	sw	$a0, body		
	j exitUpate
	
NextpositionRight:
	addi	$a0, $a0, 4		# body + 4
	sw	$a0, body		
	j exitUpate
	
exitUpate:
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
	
PositionUpdated:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updatePlayer frame pointer	
	
	lw	$a3, SpeedofX	# load SpeedofX from memory
	lw	$a1, SpeedofY	# load SpeedofY from memory
	lw	$a2, x		# load x from memory
	lw	$t3, y		# load y from memory
	add	$a2, $a2, $a3	# update x pos
	add	$t3, $t3, $a1	# update y pos
	sw	$a2, x		# store updated xpos back to memory
	sw	$t3, y		# store updated ypos back to memory
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code

###############################

drawCharacter:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer
	
	lw	$a0, XcharacterEaten		# t0 = xPos of apple
	lw	$a1, YcharacterEaten		# t1 = yPos of apple
	lw	$a2, xCoordinate	# t2 = 64
	mult	$a1, $a2		# YcharacterEaten * 64
	mflo	$t3			# t3 = YcharacterEaten * 64
	add	$t3, $t3, $a0		# t3 = YcharacterEaten * 64 + XcharacterEaten
	lw	$a2, yCoordinate	# t2 = 4
	mult	$t3, $a2		# (yPos * 64 + XcharacterEaten) * 4
	mflo	$a0			# t0 = (YcharacterEaten * 64 + XcharacterEaten) * 4
	
	la 	$a1, Buffer	# load frame buffer address
	add	$a0, $a1, $a0		# t0 = (YcharacterEaten * 64 + XcharacterEaten) * 4 + frame address
	li	$a1, 0x00ff0000
	sw	$a1, 0($a0)		# store direction plus color on the bitmap display
	
	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code	


newCharactereLocation:
	addiu 	$sp, $sp, -24	# allocate 24 bytes for stack
	sw 	$fp, 0($sp)	# store caller's frame pointer
	sw 	$ra, 4($sp)	# store caller's return address
	addiu 	$fp, $sp, 20	# setup updateSnake frame pointer

LoopRandom:		
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 63	# upper bound
	syscall
	add	$a1, $zero, $a0	# random XcharacterEaten
	
	addi	$v0, $zero, 42	# random int 
	addi	$a1, $zero, 31	# upper bound
	syscall
	add	$a2, $zero, $a0	# random YcharacterEaten
	
	lw	$t3, xCoordinate	# t3 = 64
	mult	$a2, $t3		# random YcharacterEaten * 64
	mflo	$a1			# t4 = random YcharacterEaten * 64
	add	$a1, $a1, $a1		# t4 = random YcharacterEaten * 64 + random XcharacterEaten
	lw	$t3, yCoordinate	# t3 = 4
	mult	$t3, $a1		# (random YcharacterEaten * 64 + random XcharacterEaten) * 4
	mflo	$a1			# t1 = (random YcharacterEaten * 64 + random XcharacterEaten) * 4
	
	la 	$a0, Buffer	# load frame buffer address
	add	$a0, $a1, $a0		# t0 = (YcharacterEaten * 64 + XcharacterEaten) * 4 + frame address
	lw	$a2, 0($a0)		# t5 = value of pixel at t0
	
	li	$t3, 0x00d3d3d3		# load light gray color
	beq	$a2, $t3, goodCharacter	# if loction is a good sqaure branch to goodApple
	j LoopRandom


goodCharacter:
	sw	$a1, XcharacterEaten
	sw	$a2, YcharacterEaten	

	lw 	$ra, 4($sp)	# load caller's return address
	lw 	$fp, 0($sp)	# restores caller's frame pointer
	addiu 	$sp, $sp, 24	# restores caller's stack pointer
	jr 	$ra		# return to caller's code
