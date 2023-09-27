.data 
filename: .asciiz "C:/Users/User/Desktop/A4/A4/house_64_in_ascii_crlf.ppm"
outputfile: .asciiz "C:/Users/User/Desktop/A4/A4/greyscale.ppm"
header_text:   .asciiz "P2\n# GRY\n64 64\n255\n"
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
    la $a2, 300000
    syscall

    # Initialize integer value accumulator
    li $t1, 0
    li $t2, 10         # ASCII value for newline
    la $t0, filewords  # Load address of the buffer

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
  li $v0, 16   
   move $a0, $s1
     # syscall code for close file
   syscall

    

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
    # Print the accumulated integer
average: 
add $t6, $t6, $t1

 
 print:
    add $t8, $t8, $t1
    li $v0, 1
    move $a0, $t1
    syscall

    # Print a newline
    li $v0, 4
    la $a0, newline
    syscall

    # Reset accumulator for the next number
    li $t1, 0
    j continue_loop
    


continue_loop:
    addi $t0, $t0, 1   # Move to the next character
    j loop

end:


# Exit the program
    li $v0, 10
    syscall
