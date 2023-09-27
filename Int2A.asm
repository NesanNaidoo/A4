# Constants
.data
newline:    .asciiz "\n"    # Newline character for output

# Input: Hardcoded integer in the range 1 to 255
.text
main:
    li $t0, 100            # Replace 300 with your hardcoded integer

    # Check if the input is within the valid range (1 to 255)
    li $t1, 1
    li $t2, 255
    blt $t0, $t1, invalid_input  # Branch if input < 1
    bgt $t0, $t2, invalid_input  # Branch if input > 255

    # Convert the integer to ASCII
    li $t3, 10              # Divide by 10 (for decimal conversion)
    li $t4, 0               # Initialize the result

convert_loop:
    divu $t0, $t0, $t3      # Divide by 10
    mflo $t0                # Quotient in $t0
    mfhi $t5                # Remainder in $t5

    addi $t5, $t5, 48       # Convert remainder to ASCII (add '0')
    sb $t5, ($sp)           # Store ASCII character on the stack
    addi $sp, $sp, -1       # Decrement stack pointer

    bnez $t0, convert_loop  # Repeat until quotient is zero

    # Output the ASCII characters
output_loop:
    addi $sp, $sp, 1        # Increment stack pointer
    lb $a0, ($sp)           # Load ASCII character
    li $v0, 11              # Print character syscall code
    syscall

    addi $sp, $sp, 1        # Increment stack pointer
    lb $a0, newline         # Load newline character
    li $v0, 11              # Print character syscall code
    syscall

    bnez $sp, output_loop   # Repeat until stack is empty

    # Exit
    li $v0, 10              # Exit syscall code
    syscall

invalid_input:
    li $v0, 4               # Print string syscall code
    la $a0, invalid_msg     # Load address of error message
    syscall

    # Exit
    li $v0, 10              # Exit syscall code
    syscall

# Error message for invalid input
.data
invalid_msg: .asciiz "Invalid input. Please enter an integer in the range 1 to 255.\n"
