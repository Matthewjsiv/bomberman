#Matthew Sivaprakasam
#mjs299

.data
gameover: .asciiz "You Died!"
gamewin:.asciiz "You Won!"

# LED colors (don't change)
.eqv	LED_OFF		0
.eqv	LED_RED		1
.eqv	LED_ORANGE	2
.eqv	LED_YELLOW	3
.eqv	LED_GREEN	4
.eqv	LED_BLUE	5
.eqv	LED_MAGENTA	6
.eqv	LED_WHITE	7

# Board size (don't change)
.eqv	LED_SIZE	2
.eqv	LED_WIDTH	32
.eqv	LED_HEIGHT	32

# System Calls
.eqv	SYS_PRINT_INTEGER	1
.eqv	SYS_PRINT_STRING	4
.eqv	SYS_PRINT_CHARACTER	11
.eqv	SYS_SYSTEM_TIME		30

# Key states
leftPressed:		.word	0
rightPressed:		.word	0
upPressed:		.word	0
downPressed:		.word	0
actionPressed:		.word	0

# Frame counting
lastTime:		.word	0
frameCounter:		.word	0

#Enemies
enemy1x:		.word 	30
enemy1y:		.word   0
enemy2x:		.word 	0
enemy2y:		.word   30
enemy3x:		.word 	30
enemy3y:		.word   30
allDead:		.word	0

.text
.globl main
main:	
	# Initialize the game state
	jal	initialize				# initialize()
	
	
	
	
	# Run our game!
	jal	gameLoop				# gameLoop()
	
	# The game is over.

	# Exit
	li	v0, 10
	syscall						# syscall(EXIT)

# void initialize()
#   Initializes the game state.
initialize:
	push	ra
	
	# Set lastTime to a reasonable number
	jal	getSystemTime
	sw	v0, lastTime
	
	# Clear the screen
	li	a0, 1
	jal	displayRedraw				# displayRedraw(1);
	
	# Initialize anything else
	jal buildstage
	
	move a0,s6
	move a1,s7
	li a2, LED_WHITE
	jal displaySetLED
	
	pop	ra
	jr	ra
				
# void gameLoop()
#   Infinite loop for the game logic
gameLoop:
	push	ra



gameLoopStart:						# loop {
	jal	getSystemTime				#
	move	s0, v0					# 	s0 = getSystemTime();
	
	move	a0, s0
	jal	handleInput				# 	v0 = handleInput(elapsed: a0);
	
	# Determine if a frame passed
	lw	t0, lastTime
	sub	t0, s0, t0
	blt	t0, 50, gameLoopStart			# 	if (s0 - lastTime >= 50) {
	
	# Update last time
	sw	s0, lastTime				# 		lastTime = s0;
	
	# Update our game state (if a frame elapsed)
	move	a0, s0
	jal	update					# 		v0 = update();
	
	# Exit the game when it tells us to
	beq	v0, 1, gameLoopExit			# 		if (v0 == 1) { break; }
	
	# Redraw (a0 = 0; do not clear the screen!)
	li	a0, 0
	jal	displayRedraw				# 		displayRedraw(0);
							#	}
	j	gameLoopStart				# }

gameLoopExit:
	pop	ra
	jr	ra					# return;
			
# int getSystemTime()
#   Returns the number of milliseconds since system booted.
getSystemTime:
	# Now, get the current time
	li	v0, SYS_SYSTEM_TIME
	syscall						# a0 = syscall(GET_SYSTEM_TIME);
	
	move	v0, a0
	
	jr	ra					# return v0;
	
# bool update(elapsed)
#   Updates the game for this frame.
# returns: v0: 1 when the game should end.
update:
	push	ra
	push	s0
	
	# Increment the frame counter
	lw	t0, frameCounter
	add	t0, t0, 1
	sw	t0, frameCounter			# frameCounter++;
	
	li	s0, 0					# s0 = 0;
	
	# Update all of the game state
	jal	updateStuff
	or	s0, s0, v0				# s0 = s0 | updateStuff();
	
_updateExit:
	move	v0, s0
	
	pop	s0
	pop	ra
	jr	ra					# return s0;
	
# void updateStuff()
updateStuff:
	push	ra
	
	
	
	########################handle interaction with bomb
	move a0,s6
	move a1,s7
	jal displayGetLED
	beq v0,LED_RED,death
	lw t0,frameCounter
	sub t0,t0,s2
	
	blt t0,20,nodeath
	move a0,s6
	move a1,s7
	jal displayGetLED
	beq v0,LED_MAGENTA,death
	
	
	
	nodeath:
	
	
#############################enemy1
updateenemy1:

push s5 #used to store direction var for enemies
push s6 #used for location vars for enemies
push s7 #use for y location vars for enemies


lw s6,enemy1x
lw s7, enemy1y

beq s6,-1,inactive1
beq s7,-1,inactive1

	move a0,s6
	move a1,s7
	jal displayGetLED
	bne v0,LED_MAGENTA,nodeathenemy1
	
	move a0,s6
	move a1,s7
	li a2, LED_MAGENTA
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive1
	
	
	nodeathenemy1:


lw t0,frameCounter
and t0,t0,7 #how fast enemy moves
bne t0,0, nomoveenemy1

li a0,4
jal rand
move s5,v0

movee1left:
bne s5,0,movee1right

	move t1, s6
	move t2, s7
	sub t1,t1,1
	beq t1,-1,movee1right
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy1deathl
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive1
	
	noenemy1deathl:
	bne v0,LED_OFF,movee1right
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

sub s6,s6,1

movee1right:
bne s5,1,movee1up

move t1, s6
	move t2, s7
	add t1,t1,1
	beq t1,31,movee1up
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy1deathr
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive1
	
	noenemy1deathr:
	bne v0,LED_OFF,movee1up
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

add s6,s6,1


movee1up:
bne s5,2,movee1down

move t1, s6
	move t2, s7
	sub t2,t2,1
	beq t2,-1,movee1down
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy1deathu
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive1
	
	noenemy1deathu:
	bne v0,LED_OFF,movee1down
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

sub s7,s7,1

movee1down:
bne s5,3,nomoveenemy1
move t1, s6
	move t2, s7
	add t2,t2,1
	beq t2,31,nomoveenemy1
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy1deathd
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1  #deactivate enemy - won't display enemy if set to this location
	li s7,-1
	
	
	jal win	#increments death counter and quits if all enemies dead
	
	b inactive1
	
	noenemy1deathd:
	bne v0,LED_OFF,nomoveenemy1
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

add s7,s7,1

nomoveenemy1:

move a0, s6
move a1,s7
li a2, LED_RED
jal displaySetLED


inactive1:

sw s6,enemy1x
sw s7,enemy1y

pop s7
pop s6
pop s5

#############################enemy2
updateenemy2:

push s5 #same stuf for enemy 1
push s6
push s7


lw s6,enemy2x
lw s7, enemy2y

beq s6,-1,inactive2
beq s7,-1,inactive2

	move a0,s6
	move a1,s7
	jal displayGetLED
	bne v0,LED_MAGENTA,nodeathenemy2
	
	move a0,s6
	move a1,s7
	li a2, LED_MAGENTA
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive2
	
	nodeathenemy2:


lw t0,frameCounter
and t0,t0,7 #how fast enemy moves
bne t0,0, nomoveenemy2

li a0,4
jal rand
move s5,v0

movee2left:
bne s5,0,movee2right

	move t1, s6
	move t2, s7
	sub t1,t1,1
	beq t1,-1,movee2right
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy2deathl
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive2
	
	noenemy2deathl:
	bne v0,LED_OFF,movee2right
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

sub s6,s6,1

movee2right:
bne s5,1,movee2up

move t1, s6
	move t2, s7
	add t1,t1,1
	beq t1,31,movee2up
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy2deathr
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive2
	
	noenemy2deathr:
	bne v0,LED_OFF,movee2up
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

add s6,s6,1


movee2up:
bne s5,2,movee2down

move t1, s6
	move t2, s7
	sub t2,t2,1
	beq t2,-1,movee2down
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy2deathu
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive2
	
	noenemy2deathu:
	bne v0,LED_OFF,movee2down
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

sub s7,s7,1

movee2down:
bne s5,3,nomoveenemy2
move t1, s6
	move t2, s7
	add t2,t2,1
	beq t2,31,nomoveenemy2
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy2deathd
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive2
	
	noenemy2deathd:
	bne v0,LED_OFF,nomoveenemy2
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

add s7,s7,1

nomoveenemy2:

move a0, s6
move a1,s7
li a2, LED_RED
jal displaySetLED


inactive2:

sw s6,enemy2x
sw s7,enemy2y

pop s7
pop s6
pop s5

	

#############################enemy3
updateenemy3:

push s5
push s6
push s7


lw s6,enemy3x
lw s7, enemy3y

beq s6,-1,inactive3
beq s7,-1,inactive3

	move a0,s6
	move a1,s7
	jal displayGetLED
	bne v0,LED_MAGENTA,nodeathenemy3
	move a0,s6
	move a1,s7
	li a2, LED_MAGENTA
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	jal win
	b inactive3
	
	nodeathenemy3:


lw t0,frameCounter
and t0,t0,7 #how fast enemy moves
bne t0,0, nomoveenemy3

li a0,4
jal rand
move s5,v0

movee3left:
bne s5,0,movee3right

	move t1, s6
	move t2, s7
	sub t1,t1,1
	beq t1,-1,movee3right
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy3deathl
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	li s6,-1
	li s7,-1
	
	jal win
	
	b inactive3
	noenemy3deathl:
	bne v0,LED_OFF,movee3right
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

sub s6,s6,1

movee3right:
bne s5,1,movee3up

move t1, s6
	move t2, s7
	add t1,t1,1
	beq t1,31,movee3up
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy3deathr
	
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	li s6,-1
	li s7,-1
	
	jal win	
	
	b inactive3
	noenemy3deathr:
	bne v0,LED_OFF,movee3up
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

add s6,s6,1


movee3up:
bne s5,2,movee3down

move t1, s6
	move t2, s7
	sub t2,t2,1
	beq t2,-1,movee3down
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy3deathu
	
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	li s6,-1
	li s7,-1
	
	jal win
	
	b inactive3
	
	noenemy3deathu:
	bne v0,LED_OFF,movee3down
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

sub s7,s7,1

movee3down:
bne s5,3,nomoveenemy3
move t1, s6
	move t2, s7
	add t2,t2,1
	beq t2,31,nomoveenemy3
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	bne v0,LED_MAGENTA,noenemy3deathd
	
	move a0,s6
	move a1,s7
	li a2, LED_OFF
	jal displaySetLED 
	
	li s6,-1
	li s7,-1
	
	
	jal win	
	
	b inactive3
	
	noenemy3deathd:
	bne v0,LED_OFF,nomoveenemy3
	
	
move a0, s6
move a1,s7
li a2, LED_OFF
jal displaySetLED

add s7,s7,1

nomoveenemy3:

move a0, s6
move a1,s7
li a2, LED_RED
jal displaySetLED


inactive3:

sw s6,enemy3x
sw s7,enemy3y

pop s7
pop s6
pop s5

		
_updateStuffLeft:
	lw	t0, leftPressed
	beq	t0, 0, _updateStuffRight

	move t1, s6
	move t2, s7
	sub t1,t1,1
	beq t1,-1,_updateStuffRight
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	lw t0,frameCounter ########handles if they walk into bomb
	sub t0,t0,s2
	
	blt t0,20,nodeathleft
	
	jal displayGetLED
	beq v0,LED_MAGENTA,death
	
	nodeathleft:
	
	
	
	beq v0,LED_RED,death
	bne v0,LED_OFF,_updateStuffRight
	move a0,s6
	move a1,s7
	jal displayGetLED
	beq v0,LED_MAGENTA,ybombmoveleft
	move a0,s6
	move a1,s7
	li	a2, LED_OFF
	jal	displaySetLED
	
	ybombmoveleft:
	
	sub s6,s6,1
	move a0,s6
	move a1,s7
	li	a2, LED_WHITE
	jal	displaySetLED

_updateStuffRight:
	lw	t0, rightPressed
	beq	t0, 0, _updateStuffUp
	
	move t1, s6
	move t2,s7
	add t1,t1,1
	beq t1,31,_updateStuffUp
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	
	lw t0,frameCounter
	sub t0,t0,s2
	
	blt t0,20,nodeathright
	
	jal displayGetLED
	beq v0,LED_MAGENTA,death
	
	nodeathright:
	
	beq v0,LED_RED,death
	bne v0,LED_OFF,_updateStuffUp
	
	move a0,s6
	move a1,s7
	jal displayGetLED
	beq v0,LED_MAGENTA,ybombmoveright
	move a0,s6
	move a1,s7
	li	a2, LED_OFF
	jal	displaySetLED
	
	ybombmoveright:
	
	add s6,s6,1
	move a0,s6
	move a1,s7
	li	a2, LED_WHITE
	jal	displaySetLED

_updateStuffUp:
	lw	t0, upPressed
	beq	t0, 0, _updateStuffDown
	
	move t1,s6
	move t2, s7
	sub t2,t2,1
	beq t2,-1,_updateStuffDown
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	
	lw t0,frameCounter
	sub t0,t0,s2
	
	blt t0,20,nodeathup
	
	jal displayGetLED
	beq v0,LED_MAGENTA,death
	
	nodeathup:
	
	beq v0,LED_RED,death
	bne v0,LED_OFF,_updateStuffDown
	
	move a0,s6
	move a1,s7
	jal displayGetLED
	beq v0,LED_MAGENTA,ybombmoveup
	
	move a0,s6
	move a1,s7
	li	a2, LED_OFF
	jal	displaySetLED
	
	ybombmoveup:
	
	sub s7,s7,1
	move a0,s6
	move a1,s7
	li	a2, LED_WHITE
	jal	displaySetLED

_updateStuffDown:
	lw	t0, downPressed
	beq	t0, 0, _updateStuffAction
	
	move t1,s6
	move t2, s7
	add t2,t2,1
	beq t2,31,_updateStuffAction
	
	move a0,t1
	move a1,t2
	jal displayGetLED
	
	lw t0,frameCounter
	sub t0,t0,s2
	
	blt t0,20,nodeathdown
	
	jal displayGetLED
	beq v0,LED_MAGENTA,death
	
	nodeathdown:
	
	beq v0,LED_RED,death
	bne v0,LED_OFF,_updateStuffAction
	
	move a0,s6
	move a1,s7
	jal displayGetLED
	beq v0,LED_MAGENTA,ybombmovedown
	
	move a0,s6
	move a1,s7
	li	a2, LED_OFF
	jal	displaySetLED
	
	ybombmovedown:
	
	add s7,s7,1
	move a0,s6
	move a1,s7
	li	a2, LED_WHITE
	jal	displaySetLED

_updateStuffAction:
	lw	t0, actionPressed
	beq	t0, 0, _updateStuffExit
	
	beq s5, 1, bombinplace
	move	a0, s6
	move	a1, s7
	li	a2, LED_MAGENTA
	jal	displaySetLED
	add s5,s5,1
	move s4,s7
	move s3,s6
	
	lw	s2, frameCounter
	
	bombinplace:
	

_updateStuffExit:
beq s5,0,nodisappear
lw t0,frameCounter
sub t0,t0,s2

move t1,s3
move t2,s4

firstprop:
bne t0,20,secprop



add t1,t1,1
beq t1,31,nopropright1
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropright1
move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropright1:

sub t1,t1,2
beq t1,-1,nopropleft1
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropleft1
move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropleft1:

add t1,t1,1
add t2,t2,1
beq t2,31,nopropdown1
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropdown1
move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropdown1:

sub t2,t2,2
beq t2,-1,nopropup1
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropup1
move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropup1:
################################second propogation
secprop:
bne t0,40,thirdprop

add t1,t1,1
beq t1,31,nopropright2
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropright2
add t1,t1,1
beq t1,31,nopropright2
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropright2
move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropright2:

sub t1,s3,1
beq t1,-1,nopropleft2
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropleft2
sub t1,t1,1
beq t1,-1,nopropleft2
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropleft2
move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropleft2:

move t1,s3
add t2,s4,1
beq t2,31,nopropdown2
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropdown2
add t2,t2,1
beq t2,31,nopropdown2
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropdown2

move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropdown2:

move t1,s3
sub t2,s4,1
beq t2,-1,nopropup2
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropup2
sub t2,t2,1
beq t2,-1,nopropup2
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropup2

move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropup2:

#################################3rd propagation
thirdprop:    
bne t0,60,disappear

add t1,t1,1
beq t1,31,nopropright3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropright3
add t1,t1,1
beq t1,31,nopropright3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropright3
add t1,t1,1
beq t1,31,nopropright3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropright3
move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropright3:

sub t1,s3,1
beq t1,-1,nopropleft3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropleft3
sub t1,t1,1
beq t1,-1,nopropleft3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropleft3
sub t1,t1,1
beq t1,-1,nopropleft3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropleft3
move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropleft3:

move t1,s3
add t2,s4,1
beq t2,31,nopropdown3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropdown3
add t2,t2,1
beq t2,31,nopropdown3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropdown3
add t2,t2,1
beq t2,31,nopropdown3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropdown3

move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropdown3:

move t1,s3
sub t2,s4,1
beq t2,-1,nopropup3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropup3
sub t2,t2,1
beq t2,-1,nopropup3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropup3
sub t2,t2,1
beq t2,-1,nopropup3
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nopropup3

move a0,t1
move a1,t2
li a2,LED_MAGENTA
jal displaySetLED

nopropup3:
##############################disappear
disappear:
bne t0,80,nodisappear

move a0,t1
move a1,t2
li a2,LED_OFF
jal displaySetLED

add t1,t1,1
beq t1,31,nodisright
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisright
li a2,LED_OFF
jal displaySetLED
add t1,t1,1
beq t1,31,nodisright
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisright
li a2,LED_OFF
jal displaySetLED
add t1,t1,1
beq t1,31,nodisright
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisright
move a0,t1
move a1,t2
li a2,LED_OFF
jal displaySetLED

nodisright:

sub t1,s3,1
beq t1,-1,nodisleft
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisleft
li a2,LED_OFF
jal displaySetLED
sub t1,t1,1
beq t1,-1,nodisleft
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisleft
li a2,LED_OFF
jal displaySetLED
sub t1,t1,1
beq t1,-1,nodisleft
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisleft
move a0,t1
move a1,t2
li a2,LED_OFF
jal displaySetLED

nodisleft:

move t1,s3
add t2,s4,1
beq t2,31,nodisdown
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisdown
li a2,LED_OFF
jal displaySetLED
add t2,t2,1
beq t2,31,nodisdown
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisdown
li a2,LED_OFF
jal displaySetLED
add t2,t2,1
beq t2,31,nodisdown
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisdown

move a0,t1
move a1,t2
li a2,LED_OFF
jal displaySetLED

nodisdown:

move t1,s3
sub t2,s4,1
beq t2,-1,nodisup
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisup
li a2,LED_OFF
jal displaySetLED
sub t2,t2,1
beq t2,-1,nodisup
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisup
li a2,LED_OFF
jal displaySetLED
sub t2,t2,1
beq t2,-1,nodisup
move a0,t1
move a1,t2
jal displayGetLED
beq v0,LED_GREEN,nodisup

move a0,t1
move a1,t2
li a2,LED_OFF
jal displaySetLED

nodisup:



li s5,0

nodisappear:



	# Return 0 so the game loop doesn't exit
	li	v0, 0
	
	pop	ra
	jr	ra					# return 0;
	
# LED Input Handling Function
# -----------------------------------------------------
	
# bool handleInput(elapsed)
#   Handles any button input.
# returns: v0: 1 when the game should end.
handleInput:
	push	ra
	
	# Get the key state memory
	li	t0, 0xffff0004
	lw	t1, (t0)
	
	# Check for key states
	and	t2, t1, 0x1
	sw	t2, upPressed
	
	srl	t1, t1, 1
	and	t2, t1, 0x1
	sw	t2, downPressed
	
	srl	t1, t1, 1
	and	t2, t1, 0x1
	sw	t2, leftPressed
	
	srl	t1, t1, 1
	and	t2, t1, 0x1
	sw	t2, rightPressed
	
	srl	t1, t1, 1
	and	t2, t1, 0x1
	sw	t2, actionPressed
	
	move	v0, t2
	
	pop	ra
	jr	ra
	
# LED Display Functions
# -----------------------------------------------------
	
# void displayRedraw()
#   Tells the LED screen to refresh.
#
# arguments: $a0: when non-zero, clear the screen
# trashes:   $t0-$t1
# returns:   none


displayRedraw:
	li	t0, 0xffff0000
	sw	a0, (t0)
	jr	ra

# void displaySetLED(int x, int y, int color)
#   sets the LED at (x,y) to color
#   color: 0=off, 1=red, 2=yellow, 3=green
#
# arguments: $a0 is x, $a1 is y, $a2 is color
# returns:   none
#
displaySetLED:
	push	s0
	push	s1
	push	s2
	
	# I am trying not to use t registers to avoid
	#   the common mistakes students make by mistaking them
	#   as saved.
	
	#   :)

	# Byte offset into display = y * 16 bytes + (x / 4)
	sll	s0, a1, 6      # y * 64 bytes
	
	# Take LED size into account
	mul	s0, s0, LED_SIZE
	mul	s1, a0, LED_SIZE
		
	# Add the requested X to the position
	add	s0, s0, s1
	
	li	s1, 0xffff0008 # base address of LED display
	add	s0, s1, s0    # address of byte with the LED
	
	# s0 is the memory address of the first pixel
	# s1 is the memory address of the last pixel in a row
	# s2 is the current Y position	
	
	li	s2, 0	
_displaySetLEDYLoop:
	# Get last address
	add	s1, s0, LED_SIZE
	
_displaySetLEDXLoop:
	# Set the pixel at this position
	sb	a2, (s0)
	
	# Go to next pixel
	add	s0, s0, 1
	
	beq	s0, s1, _displaySetLEDXLoopExit
	j	_displaySetLEDXLoop
	
_displaySetLEDXLoopExit:
	# Reset to the beginning of this block
	sub	s0, s0, LED_SIZE
	
	# Move to next row
	add	s0, s0, 64
	
	add	s2, s2, 1
	beq	s2, LED_SIZE, _displaySetLEDYLoopExit
	
	j _displaySetLEDYLoop
	
_displaySetLEDYLoopExit:
	
	pop	s2
	pop	s1
	pop	s0
	jr	ra
	
# int displayGetLED(int x, int y)
#   returns the color value of the LED at position (x,y)
#
#  arguments: $a0 holds x, $a1 holds y
#  returns:   $v0 holds the color value of the LED (0 through 7)
#
displayGetLED:
	push	s0
	push	s1

	# Byte offset into display = y * 16 bytes + (x / 4)
	sll	s0, a1, 6      # y * 64 bytes
	
	# Take LED size into account
	mul	s0, s0, LED_SIZE
	mul	s1, a0, LED_SIZE
		
	# Add the requested X to the position
	add	s0, s0, s1
	
	li	s1, 0xffff0008 # base address of LED display
	add	s0, s1, s0    # address of byte with the LED
	lbu	v0, (s0)
	
	pop	s1
	pop	s0
	jr	ra
	

buildstage:
	
	push ra
	push a0
	push a1
	push a2
	push s0
	
	li s0,0
	builddestruct:
	li a0,31
	jal rand
	move a1,v0
	
	li a0,31
	jal rand
	move a0,v0

	li	a2, LED_YELLOW
	jal	displaySetLED
	add s0,s0,1
	bne s0,300,builddestruct
	donebuilddestruct:
	
	li s0,0
	bordery:
	li a0,31
	move a1,s0
	li a2,LED_BLUE
	jal displaySetLED
	add s0,s0,1
	bne s0,32,bordery
	
	li s0,0
	borderx:
	move a0,s0
	li a1,31
	li a2,LED_BLUE
	jal displaySetLED
	add s0,s0,1
	bne s0,32,borderx
	
	li s1,0
	clearx1:
		li s0,0
		clearx1in:
		move a0,s0
		move a1,s1
		li a2, LED_OFF
		jal displaySetLED
		add s0,s0,1
		bne s0,3,clearx1in
		add s1,s1,1
		bne s1,3,clearx1
		
	li s1,0
	clearx2:
		li s0,28
		clearx2in:
		move a0,s0
		move a1,s1
		li a2, LED_OFF
		jal displaySetLED
		add s0,s0,1
		bne s0,31,clearx2in
		add s1,s1,1
		bne s1,3,clearx2
		
	li s1,28
	clearx3:
		li s0,0
		clearx3in:
		move a0,s0
		move a1,s1
		li a2, LED_OFF
		jal displaySetLED
		add s0,s0,1
		bne s0,3,clearx3in
		add s1,s1,1
		bne s1,31,clearx3
		
	li s1,28
	clearx4:
		li s0,28
		clearx4in:
		move a0,s0
		move a1,s1
		li a2, LED_OFF
		jal displaySetLED
		add s0,s0,1
		bne s0,31,clearx4in
		add s1,s1,1
		bne s1,31,clearx4
	
	li s1,1
	blocks:
		li s0,1
		and t1,s1,1
		blocks2:
		and t0,s0,1
		bne t0,1,nodraw
		bne t1,1,nodraw
		
		move a0,s0
		move a1,s1
		li a2,LED_GREEN
		jal displaySetLED
		
		nodraw:
		add s0,s0,1
		bne s0,31, blocks2
		add s1,s1,1
		bne s1,31, blocks
	
	pop s0
	pop a2
	pop a1
	pop a0
	pop ra
	
jr ra
# rand(a0: The upper bound)
#
# Get a random integer between 0 and the given max.
#
# Returns: integer in v0
rand:
	push	ra
	push a0
	push a1
	# We need a1 to be the max number (which is in a0)
	# This is the definition of the syscall
	move	a1, a0
	li	a0, 1	
	li	v0, 42			# syscall(RAND_INTEGER, our upper bound argument)
	syscall
	
	move	v0, a0		# set up return value from rand
	
	pop a1
	pop a0
	pop	ra
	jr	ra

death:


	li v0, 4
	la a0, gameover
	syscall
	
	li	v0, 10
	syscall		

win:
	push ra
	
	lw t0,allDead
	add t0,t0,1
	sw t0,allDead
	bne t0,3, nowin
	
	li v0, 4
	la a0, gamewin
	syscall
	
	li	v0, 10
	syscall	
	
	nowin:	
	
	pop ra
	jr ra
	
	
