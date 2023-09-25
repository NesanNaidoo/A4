.data
    src_filename:   .asciiz "Desktop/A4/sample_images/LF/house_64_in_ascii_lf.ppm"  # Absolute source file path
    dest_filename:  .asciiz "Desktop/A4/sample_images/LF/house_64_in_ascii_lfV2.ppm"  # Absolute destination file path

    src_image_width:    .word 0
    src_image_height:   .word 0
    src_image_data:     .space 4096  # Allocate space for source image
    dest_image_width:   .word 0
    dest_image_height:  .word 0
    dest_image_data:    .space 4096  # Allocate space for destination image

.text
    main:
        # Open the source file
        li $v0, 13           # syscall 13 for file open
        la $a0, src_filename # Load the source filename
        li $a1, 0            # Open for reading
        li $a2, 0            # Mode (ignored for reading)
        syscall

        # Check if source file opened successfully
        bnez $v0, src_file_opened
        li $v0, 10           # Exit with error code
        syscall

    src_file_opened:
        # Read and parse the source PPM header
        li $t0, 0            # Initialize line counter
        read_src_header:
            li $v0, 8         # syscall 8 for reading a string
            la $a0, buffer    # Load a buffer for reading the line
            li $a1, 100       # Maximum line length
            syscall
            addi $t0, $t0, 1  # Increment line counter
            beq $t0, 3, read_src_dimensions # Skip 3 lines (the header)
            j read_src_header

        read_src_dimensions:
            # Parse the width and height from the source PPM header
            lw $t1, buffer    # Load the buffer into a register
            li $t2, 0         # Initialize digit accumulator for width
            li $t3, 0         # Initialize digit accumulator for height
            li $t4, 0         # Digit position (0 for width, 1 for height)
            parse_dimensions_loop:
                lb $t5, 0($t1) # Load a character from the buffer
                beqz $t5, src_header_done # Check for end of header (null terminator)
                addi $t1, $t1, 1 # Increment buffer pointer
                beq $t5, ' ', switch_to_height # Check for space (switch to height)
                sub $t5, $t5, '0' # Convert ASCII digit to integer
                mul $t5, $t5, 10 # Multiply by 10 to accumulate digits
                beq $t4, 0, accumulate_width # Accumulate width
                beq $t4, 1, accumulate_height # Accumulate height
                accumulate_width:
                    add $t2, $t2, $t5 # Add the digit to width
                    j parse_dimensions_loop
                accumulate_height:
                    add $t3, $t3, $t5 # Add the digit to height
                    j parse_dimensions_loop
                switch_to_height:
                    li $t4, 1 # Switch to accumulating height
                    j parse_dimensions_loop

        src_header_done:
            # Store source image dimensions
            sw $t2, src_image_width
            sw $t3, src_image_height

            # Allocate memory for the source image
            la $a0, src_image_data
            li $a1, 4096    # Allocate space for 64x64 RGB pixels
            li $v0, 9          # syscall 9 for memory allocation
            syscall

            # Read the source image data
            la $a0, src_image_data
            li $a1, 16384  # Read 4 bytes at a time (one integer, 0-255)
            li $v0, 14         # syscall 14 for reading an integer
            syscall

        # Open the destination file for writing
        li $v0, 13            # syscall 13 for file open
        la $a0, dest_filename # Load the destination filename
        li $a1, 1             # Open for writing (create if not exists)
        li $a2, 0             # Mode (ignored for writing)
        syscall

        # Check if destination file opened successfully
        bnez $v0, dest_file_opened
        li $v0, 10            # Exit with error code
        syscall

    dest_file_opened:
        # Write the destination PPM header
        li $v0, 4              # syscall 4 for printing a string
        la $a0, dest_ppm_header # Load the destination PPM header
        syscall

        # Write the destination image data
        la $a0, src_image_data  # Load the source image data address
        la $a1, dest_image_data # Load the destination image data address
        li $a2, 4096        # Number of bytes to copy
        jal copy_image_data    # Jump to subroutine to copy image data

        # Close the source file
        li $v0, 16             # syscall 16 for file close
        syscall

        # Close the destination file
        li $v0, 16             # syscall 16 for file close
        syscall

        # Exit program
        li $v0, 10             # syscall 10 for exit
        syscall

    copy_image_data:
        # Copies bytes from source image data to destination image data
        # $a0: Source address
        # $a1: Destination address
        # $a2: Number of bytes to copy
        copy_loop:
            lb $t0, 0($a0)    # Load a byte from the source
            sb $t0, 0($a1)    # Store the byte in the destination
            addi $a0, $a0, 1  # Increment source address
            addi $a1, $a1, 1  # Increment destination address
            addi $a2, $a2, -1 # Decrement byte count
            bnez $a2, copy_loop
            jr $ra             # Return from the subroutine

.data
    buffer:              .space 100        # Buffer to read lines from the source file
    dest_ppm_header:    .asciiz "P3\n64 64\n255\n"  # Hardcoded destination PPM header
