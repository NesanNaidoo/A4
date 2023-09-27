.data 
filename: .asciiz "C:/Users/User/Desktop/A4/house_64_in_ascii_crlf.ppm"
outputfile: .asciiz "C:/Users/User/Desktop/A4/greyscale.ppm"
header_text:   .asciiz "P2\n# GRY\n64 64\n255\n"
str:   .space 128
filewords: .space 100000
newline: .asciiz "\n"
double64: .double 4096.0

.text
main:

    # Open the file for reading
    li $v0, 13
    la $a0, filename
    li $a1, 0
    syscall
    move $s0, $v0

    # Read the file into memory
    li $v0, 14
    move $a0, $s0
    la $a1, filewords
    la $a2, 100000
    syscall

    # Initialize integer value accumulator
    li $t1, 0
    li $t2, 10         # ASCII value for newline
    
    la $t0, filewords  # Load address of the buffer

    li $t6, 0    
    li $t8, 0

    # Open the file for writing
   li $v0, 13       # syscall code for open file
   la $a0, outputfile # Load the address of the filename
   li $a1, 1        # Open for write (O_WRONLY)
   syscall
   move $s1, $v0    # Store the file descriptor in $s0

   # Write header data to the file
    li $v0, 15  
   move $a0, $s1  
   la $a1, header_text  # Address of the header data
   la $a2, 19   # Length of the header data
   syscall

   # Close the file
  


    

loop:
    lb $t3, 23($t0)
    beqz $t3, end      # Exit loop if we reach the end of the file

    # Check if it's a valid numeric character (ASCII '0' to '9')
    li $t4, 48   # ASCII '0'
    li $t5, 57   # ASCII '9'
    blt $t3, $t4, not_numeric
    bgt $t3, $t5, not_numeric

    # Convert ASCII to integer
    sub $t3, $t3, $t4  # Convert ASCII to integer
    mul $t1, $t1, 10    # Multiply the current accumulated value by 10
    add $t1, $t1, $t3   # Add the new digit
    j continue_loop

not_numeric:
    # If it's not a valid numeric character, check for newline
    beq $t3, $t2, print_number

    # If it's not a number or newline, skip it
    j continue_loop

print_number:

add10:
   add $t6, $t6, $t1
   addi $t8, $t8, 1
   beq $t8, 3, intit
   li $t1, 0
   j continue_loop

        

intit: 
    div $t1, $t6, 3



 print:
    
    

    move  $a0, $t1          # $a0 = int to convert
    la   $a1, str             # $a1 = address of string where converted number will be kept
    jal  int2str

    la $a0, str             # Load address of string.
    jal strlen  

    jal check

    

    li $v0, 15  
    move $a0, $s1  
    la $a1, str  # Address of the  data
    move $a2, $t7   # Length of the  data
    syscall

   li $v0, 15  
   move $a0, $s1  
   la $a1, newline  # Address of the header data
   la $a2, 1   # Length of the header data
   syscall

   

    # Reset accumulator for the next number
    li $t1, 0
    li $t1, 0
    li $t6, 0
    li $t8, 0
    j continue_loop
    


continue_loop:
    addi $t0, $t0, 1   # Move to the next character
    j loop

int2str:
addi $sp, $sp, -4         # to avoid headaches save $t- registers used in this procedure on stack
sw   $t0, ($sp)           # so the values don't change in the caller. We used only $t0 here, so save that.
bltz $a0, neg_num         # is num < 0 ?
j    next0                # else, goto 'next0'

neg_num:                  # body of "if num < 0:"
li   $t0, '-'
sb   $t0, ($a1)           # *str = ASCII of '-' 
addi $a1, $a1, 1          # str++
li   $t0, -1
mul  $a0, $a0, $t0        # num *= -1

next0:
li   $t0, -1
addi $sp, $sp, -4         # make space on stack
sw   $t0, ($sp)           # and save -1 (end of stack marker) on MIPS stack

push_digits:
blez $a0, next1           # num < 0? If yes, end loop (goto 'next1')
li   $t0, 10              # else, body of while loop here
div  $a0, $t0             # do num / 10. LO = Quotient, HI = remainder
mfhi $t0                  # $t0 = num % 10
mflo $a0                  # num = num // 10  
addi $sp, $sp, -4         # make space on stack
sw   $t0, ($sp)           # store num % 10 calculated above on it
j    push_digits          # and loop

next1:
lw   $t0, ($sp)           # $t0 = pop off "digit" from MIPS stack
addi $sp, $sp, 4          # and 'restore' stack

bltz $t0, neg_digit       # if digit <= 0, goto neg_digit (i.e, num = 0)
j    pop_digits           # else goto popping in a loop

neg_digit:
li   $t0, '0'
sb   $t0, ($a1)           # *str = ASCII of '0'
addi $a1, $a1, 1          # str++
j    next2                # jump to next2

pop_digits:
bltz $t0, next2           # if digit <= 0 goto next2 (end of loop)
addi $t0, $t0, '0'        # else, $t0 = ASCII of digit
sb   $t0, ($a1)           # *str = ASCII of digit
addi $a1, $a1, 1          # str++
lw   $t0, ($sp)           # digit = pop off from MIPS stack 
addi $sp, $sp, 4          # restore stack
j    pop_digits           # and loop

next2:
sb  $zero, ($a1)          # *str = 0 (end of string marker)

lw   $t0, ($sp)           # restore $t0 value before function was called
addi $sp, $sp, 4          # restore stack
jr  $ra                   # jump to caller



strlen:
li $t9, 0 # initialize the count to zero
loop2:
lb $t7, 0($a0) # load the next character into t1
beqz $t7, exit # check for the null character
addi $a0, $a0, 1 # increment the string pointer
addi $t9, $t9, 1 # increment the count
j loop2 # return to the top of the loop
exit:
jr $ra

check:
    beq $t9,1,one
    beq,$t9,2,two
    li $t7,3

    jr $ra

one:  li $t7,1
     jr $ra

two:  li $t7,2
     jr $ra


end:

li $v0, 16   
move $a0, $s1
     # syscall code for close file
syscall
 


# Exit the program
    li $v0, 10
    syscall
