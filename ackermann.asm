
#Seth Giovanetti
#ackermann.asm

#Computes the ackermann function. 
#		n+1			if m = 0
#A(m,n) = 	A(m-1, 1)		if m > 0 and n = 0
#		A(m-1, A[m, n-1])	if m > 0 and n > 0

#This function is not primitive recursive and cannot be optimized to an iterative function. 
#It is, however, provably finite. This can be intuited by seeing how both arguments are continually decremented.

#The MIPS stack can hold 1,047,552 words, or 349,184 instances of the ackermann function. That is represented as 349k spaces. 

.text

li $s5, 0 #Skip logging, y/n
li $s6, 1 #Loop, y/n

.data
function_prefix: .asciiz "A("
function_postfix: .asciiz ")\n"

#Beware, ahead be recursion. 
.text
#Macro blocks, exclusively used for logging. 
.macro spaces
	beq $s5, 1, skip_spaces
addi $t9, $s0, 0
spaces_loop:
	li $v0, 11
	li $a0, ' ' #Spacer character. 
	syscall
subi $t9, $t9, 1
bgt $t9, 0, spaces_loop
skip_spaces:
.end_macro
.macro log
	addi $t7, $t7, 1
	beq $s5, 1, skip_log
	addi $s0, $s0, 1
	addi $t0, $v0, 0
	addi $t1, $a0, 0
	spaces
	li $v0, 4
	la $a0, function_prefix
	syscall
	li $v0, 1
	addi $a0, $t1, 0
	syscall
	li $v0, 11
	li $a0, ','
	syscall
	li $v0, 1
	addi $a0, $a1, 0
	syscall
	li $v0, 4
	la $a0, function_postfix
	syscall
	addi $v0, $t0, 0
	addi $a0, $t1, 0
	skip_log:
.end_macro
.macro equals
	beq $s5, 1, skip_equals
	addi $t0, $v0, 0
	addi $t1, $a0, 0
	spaces
	li $v0, 11
	li $a0, '='
	syscall
	li $v0, 1
	addi $a0, $t0, 0
	syscall
	li $v0, 11
	li $a0, '\n'
	syscall
	addi $v0, $t0, 0
	addi $a0, $t1, 0
	subi $s0, $s0, 1
	skip_equals:
.end_macro
start:
	li $v0, 11
	li $a0, '\n'
	syscall
#Input code
li $a0, 1
li $a1, 2


	li $v0, 11
	li $a0, 'm'
	syscall
	li $a0, '='
	syscall
	
li $v0, 5
syscall
addi $t0, $v0, 0


	li $v0, 11
	li $a0, 'n'
	syscall
	li $a0, '='
	syscall
li $v0, 5
syscall
addi $a1, $v0, 0
addi $a0, $t0, 0

#Call the function. 
li $s0, 0
jal ackermann
#Print the result. 
add $a0, $v0, $zero
    li $v0 1
    syscall
beq $s6, 1, start
#Exit. 
	li $v0 10
	syscall

ackermann:
#Takes in a0, a1
#Returns v0
	log
    addi $sp, $sp, -4     # adjust stack for 1 items
    sw   $ra, 0($sp)      # save return address
    
    #v0 is a1+1 if a0 = 0
    beq $a0, $zero, ackermann_lvl_0
    #can assume a0 > 0 now
    
    #v0 is ackermann(a0-1, 1) if a0 > 0 and a1 = 0
    beq $a1, $zero, ackermann_lvl_1
    #can assume a1 > 0 now
    
    #v0 is ackermann(a0-1, ackermann($a0, a1-1) if a0 > 0 and a1 > 0
    j ackermann_lvl_2
ackermann_lvl_0:
    #v0 is a1+1 if a0 = 0
	addi $v0, $a1, 1
	j return_ackermann
ackermann_lvl_1:
    #v0 is ackermann(a0-1, 1) if a0 > 0 and a1 = 0
	#save a0, a1 to stack
    addi $sp, $sp, -8     # adjust stack for 1 items
    sw   $a0, 4($sp)      # save a0 lvl1
    sw   $a1, 0($sp)      # save a1 lvl1
	#call ackerman function with correct arguments
	
	addi $a0, $a0, -1
	li $a1, 1
	jal ackermann
	
	#load a0, a1 from stack
    lw   $a0, 4($sp)      # load a0 lvl1
    lw   $a1, 0($sp)      # load a1 lvl1
    addi $sp, $sp, 8     # adjust stack for 1 items
	j return_ackermann
ackermann_lvl_2:
    #v0 is ackermann(a0-1, ackermann($a0, a1-1) if a0 > 0 and a1 > 0
    
    addi $sp, $sp, -8     # adjust stack for 2 items
    sw   $a0, 4($sp)      # save a0 lvl2
    sw   $a1, 0($sp)      # save a1 lvl2
	#call ackerman function with correct arguments
	
	addi $a1, $a1, -1
	jal ackermann #$a0, a1-1
	addi $a1, $v0, 0
	addi $a0, $a0, -1
	jal ackermann #$a0-1, v0
	
	#load a0, a1 from stack
    lw   $a0, 4($sp)      # load a0 lvl2
    lw   $a1, 0($sp)      # load a1 lvl2
    addi $sp, $sp, 8     # adjust stack for 2 items

	j return_ackermann
return_ackermann:
	equals
    lw   $ra, 0($sp)      # restore return address
    addi $sp, $sp, 4    # adjust stack for 1 items
    jr   $ra              #   and return   
