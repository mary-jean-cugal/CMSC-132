

.data
# 1
STR_check_DIGIT:
	.asciiz "\n<integer number> = "

STR_ODD:
	.asciiz "\nODD\n"
STR_EVEN:
	.asciiz "\nEVEN\n"
DIGIT:
	.word 49249671

# 2
STR_PAL:
	.asciiz "\n<string> = "
string:
	.asciiz "Bob"
STR_P:
	.asciiz "\nPalindrome"
STR_NP:
	.asciiz "\nNOT PALINDROME"

#3
STR_SUBSTR1:
	.asciiz "\n<string 1> = "
STR_SUBSTR2:
	.asciiz "\n<string 2> = "
IS_substr:
	.asciiz "\nsubtring "
IS_NOT_substr:
	.asciiz "\nnot substring "
string1:
	.asciiz "fruit"
string2:
	.asciiz "frution"

.text
.globl main

# --------------------------------------------
#  1. input: digit
# 	  output: print even or odd
# --------------------------------------------
check_digit:
	add $t1, $zero, $zero
	andi $t0, $a0, 1
	beq $t0, $t1, print_even

	print_odd:
		li $v0, 4
		la $a0, STR_ODD
		syscall
		j end1

	print_even:
		li $v0, 4
		la $a0, STR_EVEN
		syscall

	end1:
		jr $ra

##############################################################################
#
# DESCRIPTION: Gives the length of a string.
#
#       INPUT: $a0 - address to a NUL terminated string.
#
#      OUTPUT: $v0 - length of the string (NUL excluded).
#
#    EXAMPLE:  string_length("abcdef") == 6.
#
##############################################################################	
string_length:
	addi $v0, $zero, 0      #initialize count to zero

	loop:
		lb $s1, 0($a0)		#load the character[$a0] to s1
		beqz $s1, exit      #check if null character (branch if  equal to zero)
		addi $v0, $v0, 1    #increment length
		addi $a0, $a0, 1    #increment string pointer
		j loop
	
	exit:
		jr	$ra
##############################################################################
#
#  DESCRIPTION: For each of the characters in a string (from left to right),
#		call a callback subroutine.
#
#		The callback suboutine will be called with the address of
#	        the character as the input parameter ($a0).
#	
#        INPUT: $a0 - address to a NUL terminated string.
#
#		$a1 - address to a callback subroutine.
#
##############################################################################	
string_for_each:

	addi	$sp, $sp, -12			# PUSH return address to caller ; -4 * 3 arguments, decreasing memory
	sw		$ra, 0($sp)        		# the content of $ra is stored at the specified address
	sw 		$a1, 4($sp)         	# the content of $a1 is stored at the specified address ; the address to a callback subroutine

	#### Write your solution here ####
	for_each_char:
		sw  $a0, 8($sp)                 # Store $a0 as it will be used for argument; the content of $a0 is stored at the specified address.
    	
    	lb  $s0, 0($a0)                 # Get current character
    	beqz $s0, end_for_each    		# Done when reaching NULL character
    	
    	jalr $a1                        # Call callback subroutine ; jump and link register
    	
    	lw  $a0, 8($sp)                 # Reload $a0
    	lw  $a1, 4($sp)                 # $a1 could have changed (calling convention)

    	addi $a0, $a0, 1                # Increment to get next character in string
    	
    	j   for_each_char

	end_for_each:
		lw		$ra, 0($sp)				# Pop return address to caller
		addi	$sp, $sp, 12		    # add immediate (no overflow)

		jr	$ra

##############################################################################
#
#  DESCRIPTION: Transforms a lower case character [a-z] to upper case [A-Z].
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################		
to_upper:

	#### Write your solution here ####
 	lb 		$s0, 0($a0)					#load the character[$a0] to s0
	blt 	$s0, 97, not_lowercase		#branch if $s0 is less than 97
	bgt 	$s0, 122, not_lowercase		#branch if $s0 is greater than 122
	sub 	$s0, $s0, 32				#subtracts 32 to convert lowercase to uppercase
	sb 		$s0, 0($a0)					#store byte, to the address of the character
	
	not_lowercase:
		jr	$ra

# -------------------------------------------
# 	2. input: $a0 address of string, $a1 address of original string
#      output: 0 if palindrome, 1 if not
				# $a2 - callback subroutine
# -------------------------------------------
is_palindrome:
	
	add 	$t0, $a0,$zero   		#starting address
	add 	$t2, $zero,$zero     	#i = 0
	addi 	$t3, $a1,-1     		#j = length-1

	loop3:

    	add 	$t4, $t0,$t2			# address in index i starting the first char with
    	lb 		$t5, 0($t4)   			# get char string[i]

    	add 	$t6, $t0,$t3			# address in index j starting the last char 
    	lb		$t7, 0($t6)				# get char string[j]


    	addi 	$t2, $t2, 1     		# i++
    	addi 	$t3, $t3, -1     		# j--

    	bne $t5, $t7, not_pal

    	slt 	$t1, $t3,$t2
    	beqz 	$t1, loop3
    
    pal: 
    	addi $v0, $zero, 1
    	j end2

    not_pal:
    	addi $v0, $zero, 0
		
end2: 
	jalr $a2
	jr $ra


#			 --------------------------------------------------------------------
# 3 input s
# input: $a0 - str1, $a1 = str2

check_length:
	# string length accepts $a0 string address and output is in $v0
	addi $a0, $a0, 0
	jalr $a2 #subroutine to get string length
	add $t1, $zero, $v0 #store |str1| to $t1

	addi $a0, $a1, 0 #store another string to $a0
	jalr $a2
	add $t2, $zero, $v0 #store |str2| to $t2

	slt $t1, $t1,$t2 #|str1| < |str2|? no = 0, yes = 1
    add $v0, $zero, $t1 

	jr $ra
# --------------------------------------------------
# inputs: $a0 = str1
# 		  $a1 = str2
# 		  $a2 = flag for str1 and str2 length
is_substring:
	beqz $a2, end4
	# addi $t0 $zero, 0
	# beq $a2, $t0, end4

	add $t0, $a0, $zero #address of string1 
	add $t1, $a1, $zero #address of string2
	addi $t2 ,$zero, 0 # i = 0
	addi $t3 ,$zero, 0 # j = 0
	addi $t8, $zero, 1 # flag = 0 if str1 substring of str2, else 0


	loop4:
		addi $t3 ,$zero, 0 # j = 0 RESET TO 0
		addi $t8, $zero, 1 # reset flag to 1

		add $t4, $t0, $t2 
		lb $t5, 0($t4)  #str1[i]

		add $t6, $t1, $t3
		lb $t7, 0($t6) #str2[j]

		beq $t5,$t7, loop5 #if equal, check if substr
		addi $t2, $t2, 1

		j loop4
	
	loop5:
		addi $t8, $t8, 0 # set flag to 0, meaning a potential substr
		add $t4, $t0, $t2
		lb $t5, 0($t4)  #str1[i]

		add $t6, $t1, $t3
		lb $t7, 0($t6) #str2[j]

		addi $t3, $t3, 1

		beqz, $t7, end4 	#end of str2?, then substr
		bne $t5, $t7, loop4 #not a substr go back to loop4 and continue looping through str1
		
		j loop5 

end4: 
	jr $ra


main:

	addi $sp, $sp, -4 # push return address
	sw $ra, 0($sp)

# 	check_digit(integer)
	li $v0, 4	# 4 for printing ascii
	la $a0, STR_check_DIGIT # la if dealing with ascii
	syscall

	li $v0, 1	# 1 for printing word from mem 
	lw $a0, DIGIT # lw instead of la
	syscall

	lw  $a0, DIGIT
	jal check_digit

#   is_palindrome(string)

	### get string_length 
	la	$a0, string
	jal string_length

	add $v1, $v0, $zero 	# length stored to $v1
	# add	$a0, $v0, $zero
	# li	$v0, 1
	# syscall

	### convert all to uppercase
	la	$a0, string
	la	$a1, to_upper
	jal	string_for_each

	li $v0, 4
	la $a0, string
	syscall


	add $a0, $v1, $zero
	add $a1, $a0, $zero #string len
	la $a0, string
	la $a2, display_pal
	jal is_palindrome

	lw		$ra, 0($sp)	# POP return address
	addi	$sp, $sp, 4	

# 	is substr(str1, str2)
	li $v0, 4	# 4 for printing ascii
	la $a0, STR_SUBSTR1 # la if dealing with ascii
	syscall

	li $v0, 4	# 4 for printing ascii
	la $a0, STR_SUBSTR2 # la if dealing with ascii
	syscall
	
	# la  $a0, string1
	# la  $a1, string2
	# la  $a2, string_length
	# jal check_length

	# add $v1, $zero, $v0  #result from check lenght. val is 0 if not |str1| > |str2|

	# # convert str1 to upper
	# la	$a0, string
	# la	$a1, to_upper
	# jal	string_for_each

	# li $v0, 4
	# la $a0, string
	# syscall
	# # convert str2 to upper
	# la	$a0, string2
	# la	$a1, to_upper 
	# jal	string_for_each

	# li $v0, 4
	# la $a0, string2
	# syscall
	# add $a2, $zero, $v1 

	# li $v0, 4
	# la $a0, string
	# syscall

	# add $v1, $v0, $zero 
	


jr $ra


#input: $v0 - either 0 or 1
display_pal:

	add $t0, $zero, $v0
	beqz $t0, STR_not_pal
	STR_is_pal:
		li $v0, 4
		la $a0, STR_P
		syscall
		j end3

	STR_not_pal:
		li $v0, 4
		la $a0, STR_NP
		syscall

	end3:
		lw		$ra, 0($sp)	# POP return address
	addi	$sp, $sp, 4	
		jr $ra


	

	

