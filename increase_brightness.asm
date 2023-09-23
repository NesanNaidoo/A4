.data
    # Hardcoded PPM header for input and output files
    inputHeader: .asciiz "P3\n64 64\n255\n"
    outputHeader: .asciiz "P3\n64 64\n255\n"
    inputFileName: .asciiz "\Users\User\Desktop\A4\sample_images\crlf\house_64_in_ascii_crlf.ppm"
    outputFileName: .asciiz "\Users\User\Desktop\A4\sample_images\crlf\house_64_in_ascii_crlfv2.ppm"
    buffer: .space 3  # Buffer size for RGB values (no padding)

    # Variables for holding the sum of RGB values in both images
    totalR_original: .word 0
    totalG_original: .word 0
    totalB_original: .word 0
    totalR_modified: .word 0
    totalG_modified: .word 0
    totalB_modified: .word 0

    # String labels for displaying the averages
    averageOriginalLabel: .asciiz "Average pixel value of the original image:\n"
    averageModifiedLabel: .asciiz "Average pixel value of new image:\n"

.text
    main:
        # Open the input file for reading
        li $v0, 13           # syscall code for open
        la $a0, inputFileName
        li $a1, 0            # Read mode
        li $a2, 0            # File permission
        syscall
        move $s0, $v0        # Store the file descriptor in $s0

        # Open the output file for writing
        li $v0, 13           # syscall code for open
        la $a0, outputFileName
        li $a1, 1            # Write mode
        li $a2, 0            # File permission
        syscall
        move $s1, $v0        # Store the file descriptor in $s1

        # Write the PPM header to the output file
        li $v0, 15           # syscall code for write
        move $a0, $s1        # Output file descriptor
        la $a1, outputHeader
        li $a2, 21           # Length of the header
        syscall

        # Loop through each pixel
        li $t4, 4096    # Total number of pixels
        li $t5, 0            # Loop counter

    loop:
        # Read RGB values from the input file
        li $v0, 14          # syscall code for read
        move $a0, $s0       # Input file descriptor
        la $a1, buffer
        li $a2, 3           # Buffer size for RGB values
        syscall

        # Convert the ASCII values to integers (assuming valid input)
        lb $t6, buffer
        lb $t7, buffer+1
        lb $t8, buffer+2
        subi $t6, $t6, 48   # Convert ASCII to integer
        subi $t7, $t7, 48
        subi $t8, $t8, 48

        # Increase each RGB value by 10 (clamp to 255)
        addi $t6, $t6, 10
        addi $t7, $t7, 10
        addi $t8, $t8, 10
        bgt $t6, 255, clamp_r
        bgt $t7, 255, clamp_g
        bgt $t8, 255, clamp_b
        j write_pixel

    clamp_r:
        li $t6, 255

    clamp_g:
        li $t7, 255

    clamp_b:
        li $t8, 255

    write_pixel:
        # Write modified RGB values to the output file
        sb $t6, buffer
        sb $t7, buffer+1
        sb $t8, buffer+2
        li $v0, 15           # syscall code for write
        move $a0, $s1        # Output file descriptor
        la $a1, buffer
        li $a2, 3            # Buffer size for RGB values
        syscall


        # Update the sum of RGB values for both original and modified images
        lw $t9, totalR_original
        lw $t10, totalG_original
        lw $t11, totalB_original
        add $t9, $t9, $t6   # $t6 contains the modified R value
        add $t10, $t10, $t7  # $t7 contains the modified G value
        add $t11, $t11, $t8  # $t8 contains the modified B value
        sw $t9, totalR_original
        sw $t10, totalG_original
        sw $t11, totalB_original

        lw $t12, totalR_modified
        lw $t13, totalG_modified
        lw $t14, totalB_modified
        add $t12, $t12, $t6  # $t6 contains the modified R value
        add $t13, $t13, $t7  # $t7 contains the modified G value
        add $t14, $t14, $t8  # $t8 contains the modified B value
        sw $t12, totalR_modified
        sw $t13, totalG_modified
        sw $t14, totalB_modified


        # Check if we've processed all pixels
        addi $t5, $t5, 1
        bne $t5, $t4, loop

        # Close input and output files
        li $v0, 16          # syscall code for close
        move $a0, $s0       # Input file descriptor
        syscall

        li $v0, 16          # syscall code for close
        move $a0, $s1       # Output file descriptor

        calculate_average_original:
            # Calculate average RGB values for the original image
            lw $t15, totalR_original
            lw $t16, totalG_original
            lw $t17, totalB_original
            li $t18, 4096  # Total number of pixels
            divu $t15, $t15, $t18
            divu $t16, $t16, $t18
            divu $t17, $t17, $t18

            # Convert average RGB values to floating-point double values
            mtc1 $t15, $f4      # Move average R to $f4
            mtc1 $t16, $f6      # Move average G to $f6
            mtc1 $t17, $f8      # Move average B to $f8
            cvt.d.w $f4, $f4    # Convert R to double
            cvt.d.w $f6, $f6    # Convert G to double
            cvt.d.w $f8, $f8    # Convert B to double

            # Display label for the average RGB values on the console
            li $v0, 4            # syscall code for printing a string
            la $a0, averageOriginalLabel
            syscall

            # Display the average RGB values on the console
            li $v0, 3            # syscall code for printing a double
            mov.d $f12, $f4      # Set $f12 to the value in $f4 (average R)
            syscall
            li $v0, 4            # Print a newline
            la $a0, newLine
            syscall

            li $v0, 3            # syscall code for printing a double
            mov.d $f12, $f6      # Set $f12 to the value in $f6 (average G)
            syscall
            li $v0, 4            # Print a newline
            la $a0, newLine
            syscall

            li $v0, 3            # syscall code for printing a double
            mov.d $f12, $f8      # Set $f12 to the value in $f8 (average B)
            syscall
            li $v0, 4            # Print a newline
            la $a0, newLine
            syscall

        # Calculate and display the average RGB values for the new image
        calculate_average_modified:
            # Calculate average RGB values for the new image
            lw $t15, totalR_modified
            lw $t16, totalG_modified
            lw $t17, totalB_modified
            li $t18,4096  # Total number of pixels
            divu $t15, $t15, $t18
            divu $t16, $t16, $t18
            divu $t17, $t17, $t18

            # Convert average RGB values to floating-point double values
            mtc1 $t15, $f4      # Move average R to $f4
            mtc1 $t16, $f6      # Move average G to $f6
            mtc1 $t17, $f8      # Move average B to $f8
            cvt.d.w $f4, $f4    # Convert R to double
            cvt.d.w $f6, $f6    # Convert G to double
            cvt.d.w $f8, $f8    # Convert B to double

            # Display label for the average RGB values on the console
            li $v0, 4            # syscall code for printing a string
            la $a0, averageModifiedLabel
            syscall

            # Display the average RGB values on the console
            li $v0, 3            # syscall code for printing a double
            mov.d $f12, $f4      # Set $f12 to the value in $f4 (average R)
            syscall
            li $v0, 4            # Print a newline
            la $a0, newLine
            syscall

            li $v0, 3            # syscall code for printing a double
            mov.d $f12, $f6      # Set $f12 to the value in $f6 (average G)
            syscall
            li $v0, 4            # Print a newline
            la $a0, newLine
            syscall

            li $v0, 3            # syscall code for printing a double
            mov.d $f12, $f8      # Set $f12 to the value in $f8 (average B)
            syscall
            li $v0, 4            # Print a newline
            la $a0, newLine
            syscall
        

        # Exit the program
        li $v0, 10          # syscall code for exit
        syscall
