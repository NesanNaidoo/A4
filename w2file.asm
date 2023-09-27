.data
filename:      .asciiz "C:/Users/User/Desktop/A4/A4/output.ppm"  # Replace with your filename
header_text:   .asciiz "P6\n# Tes\n2 2\n255\n"  # PPM header in ASCII format

test: .asciiz  "test"
.text
.globl main

main:
   # Open the file for writing
   li $v0, 13       # syscall code for open file
   la $a0, filename # Load the address of the filename
   li $a1, 1        # Open for write (O_WRONLY)
   syscall
   move $s1, $v0    # Store the file descriptor in $s0

   # Write header data to the file
    li $v0, 15  
   move $a0, $s1  
   la $a1, header_text  # Address of the header data
   la $a2, 17   # Length of the header data
   syscall

  li $v0, 15  
   move $a0, $s1  
   la $a1, test  # Address of the header data
   la $a2, 4   # Length of the header data
   syscall

 

   # Close the file
  li $v0, 16   
   move $a0, $s1
     # syscall code for close file
   syscall

  
