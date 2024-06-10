.psx
.create "factorial.bin", 0x80010000

.org 0x80010000

Main:
        li $t0, 6
        
        li $t3, 1
        li $t4, 1
        li $t1, 1
OuterWhile:
        bgt $t1, $t0, EndOuterWhile
        nop
        li $t4, 0
        li $t2, 0
InnerWhile:
        bge $t2, $t1, EndInnerWhile
        nop
        add $t4, $t4, $t3
        addi $t2, $t2, 1
        j InnerWhile
        nop
EndInnerWhile:
        move $t3, $t4
        addi $t1, $t1, 1
        j OuterWhile
        nop
EndOuterWhile:
.close
