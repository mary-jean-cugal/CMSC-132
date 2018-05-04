

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
	.asciiz "philip"
string2:
	.asciiz "philippines"
string_Test:
	.asciiz"\nmisud baya\n"

.text
.globl main


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


#------------------------------------------------------- 
string_for_each:

	addi	$sp, $sp, -12		# PUSH return address to caller ; -4 * 3 arguments, decreasing memory
	sw		$ra, 0($sp)         # the content of $ra is stored at the specified address
	sw 		$a1, 4($sp)         # the content of $a1 is stored at the specified address ; the address to a callback subroutine

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



#			 --------------------------------------------------------------------
# 3 input s
# input: $a0 - str1, $a1 = str2

check_length:
	add $t0, $s0, $zero		#substr len
	add $t1, $s1, $zero		#str len

	slt $t0, $t0,$t1		#|str1| < |str2|? no = 0, yes = 1
    add $v0, $zero, $t0

    beqz $t0, end5

    continue:
    	jalr $a2

    end5:
  #   	li $v0, 4
		# la $a0, IS_NOT_substr
		# syscall

		jr $ra

# --------------------------------------------------
# inputs: $a0 = str1
# 		  $a1 = str2
is_substring:
	# addi $t0 $zero, 0
	# beq $a2, $t0, end4

	add $t0, $a1, $zero #address of string2
	add $t1, $a0, $zero #address of string1
	addi $t2, $zero, 0 # i = 0
	addi $t3, $zero, 0 # j = 0
	addi $t8, $zero, 1 # flag = 0 if str1 substring of str2, else 0


	loop4:
		addi $t3 ,$zero, 0 # j = 0 RESET TO 0
		addi $t8, $zero, 1 # reset flag to 1

		add $t4, $t0, $t2 
		lb $t5, 0($t4)  #str1[i]

		add $t6, $t1, $t3
		lb $t7, 0($t6) #str2[j]

		beq $t5,$t7, loop5  # if equal, check if substr

		addi $t2, $t2, 1    # i++

		beqz $t5, check_result

		j loop4

	loop5:
		add $t8, $zero, 0 # set flag to 0, meaning a potential substr

		add $t4, $t0, $t2
		lb $t5, 0($t4)  #str1[i]

		# li $v0, 4
		# la $a0, string_Test
		# syscall

		add $t6, $t1, $t3
		lb $t7, 0($t6) #str2[j]

		addi $t3, $t3, 1 # j++
		addi $t2, $t2, 1 # i++

		beqz, $t7, check_result 	#end of str2?, then substr
		bne $t5, $t7, loop4 #not a substr go back to loop4 and continue looping through str1
		
		j loop5 

	check_result: 
		beqz $t8, yes

	no:
		li $v0, 4
		la $a0, IS_NOT_substr
		syscall
		j end4

	yes:
		li $v0, 4
		la $a0, IS_substr
		syscall

	end4:
		jr $ra

main:

	addi $sp, $sp, -4 # push return address
	sw $ra, 0($sp)


# 	is_substr(str1, str2)
	li $v0, 4	# 4 for printing ascii
	la $a0, STR_SUBSTR1 # la if dealing with ascii
	syscall

	li $v0, 4	# 4 for printing ascii
	la $a0, string1 # la if dealing with ascii
	syscall

	la  $a0, string1
	jal string_length

	add $s0, $v0, $zero			#str1 len

	# Print sum
	# add	$a0, $v0, $zero
	# li	$v0, 1
	# syscall

	li $v0, 4	# 4 for printing ascii
	la $a0, STR_SUBSTR2 # la if dealing with ascii
	syscall

	li $v0, 4	# 4 for printing ascii
	la $a0, string2 # la if dealing with ascii
	syscall

	la $a0, string2
	jal string_length	

	add $s1, $v0, $zero      #str2 len

	# Print sum
	# add	$a0, $v0, $zero
	# li	$v0, 1
	# syscall

	# convert str1 to upper
	la	$a0, string1
	la	$a1, to_upper
	jal	string_for_each

	# convert str2 to upper
	la	$a0, string2
	la	$a1, to_upper 
	jal	string_for_each

	#inputs(s0-str1 len, s1-str2 len, a0-str1, a1- str2, a2- is_substring)
	add $s0, $s0, $zero 
	add $s1, $s1, $zero
	la $a0, string1
	la $a1, string2 
	la $a2, is_substring
	jal check_length

	lw		$ra, 0($sp)	# POP return address
	addi	$sp, $sp, 4	

jr $ra



	

