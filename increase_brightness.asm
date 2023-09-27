.data 
filename: .asciiz "C:/Users/User/Desktop/A4/house_64_in_ascii_crlf.ppm"
outputfile: .asciiz "C:/Users/User/Desktop/A4/New.ppm"
header_text:   .asciiz "P3\n# New\n64 64\n255\n"
filewords: .space 100000
str:   .space 128
newline: .asciiz "\n"
out1: .asciiz "Average pixel value of the original image:\n"
out2: .asciiz "\nAverage pixel value of new image:\n"
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

    # Initialize accumulator
    li $t1, 0
    li $t2, 10         # ASCII value for newline
    la $t0, filewords  

    # Open the file for writing
   li $v0, 13     
   la $a0, outputfile 
   li $a1, 1        
   syscall
   move $s1, $v0   

   # Write header data to the file
    li $v0, 15  
   move $a0, $s1  
   la $a1, header_text  # Address of the header data
   la $a2, 19   # Length of the header data
   syscall

 


    

loop:
    lb $t3, 23($t0)
    beqz $t3, end      # Exit loop if we reach the end of the file

    # Check if it's a valid number character (ASCII '0' to '9')
    li $t4, 48   # ASCII '0'
    li $t5, 57   # ASCII '9'
    blt $t3, $t4, not_numeric
    bgt $t3, $t5, not_numeric

    # Convert ASCII to integer
    sub $t3, $t3, $t4 
    mul $t1, $t1, 10    
    add $t1, $t1, $t3   
    j continue_loop

not_numeric:
    # If it's not a valid number character, check for newline
    beq $t3, $t2, print_number

    # Else skip it
    j continue_loop

print_number:
    # Print the  integer
average: 
add $t6, $t6, $t1 #old image running total

add10:
    addi $t1, $t1, 10
    bgt $t1, 255, clamp
 print:
    add $t8, $t8, $t1 #new image running total
    

    move  $a0, $t1          # $a0 = int to convert
    la   $a1, str             # $a1 = address of string where converted number will be kept
    jal  int2str

    la $a0, str            
    jal strlen  

    jal check

    

    li $v0, 15  
    move $a0, $s1  
    la $a1, str  
    move $a2, $t7  
    syscall

   li $v0, 15  
   move $a0, $s1  
   la $a1, newline 
   la $a2, 1   
   syscall

   

    # Reset accumulator for the next number
    li $t1, 0
    j continue_loop
    
clamp:
addi $t1, $zero, 255
j print

continue_loop:
    addi $t0, $t0, 1   # Move to the next character
    j loop

int2str:
addi $sp, $sp, -4         
sw   $t0, ($sp)           
j    next0                # else, goto 'next0'



next0:
li   $t0, -1
addi $sp, $sp, -4         
sw   $t0, ($sp)           

push_digits:
blez $a0, next1          
li   $t0, 10              
div  $a0, $t0             # do num / 10. LO = Quotient, HI = remainder
mfhi $t0                  # $t0 = num % 10
mflo $a0                  # num = num // 10  
addi $sp, $sp, -4         
sw   $t0, ($sp)           # store num % 10 calculated above on it
j    push_digits          # and loop

next1:
lw   $t0, ($sp)           
addi $sp, $sp, 4         

bltz $t0, neg_digit      
j    pop_digits           

neg_digit:
li   $t0, '0'
sb   $t0, ($a1)
addi $a1, $a1, 1         
j    next2               

pop_digits:
bltz $t0, next2           # if digit <= 0 goto next2 (end of loop)
addi $t0, $t0, '0'       
sb   $t0, ($a1)           
addi $a1, $a1, 1          
lw   $t0, ($sp)           
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
 
 li $v0, 4 
la $a0, out1
syscall

li $t9, 31334400
mtc1 $t9, $f14

mtc1 $t6, $f0
div.d $f4, $f0, $f14
li $v0, 3
add.d $f12, $f4, $f30
syscall

li $v0, 4 
la $a0, out2
syscall

mtc1 $t8, $f6
div.d $f10, $f6, $f14
li $v0, 3
add.d $f12, $f10, $f30
syscall

# Exit the program
    li $v0, 10
    syscall
