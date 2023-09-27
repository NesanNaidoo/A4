jal check

check:
    beq $t9,1,one
    beq,$t9,2,two
    li $t7,3

    jr $ra

one:  li $t7,1
     jr $ra

two:  li $t7,2
     jr $ra