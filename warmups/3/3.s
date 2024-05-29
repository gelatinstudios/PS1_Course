.psx
.create "exercise3.bin", 0x80010000
.org 0x80010000
Main:
        li $t0, 27
        li $t1, 3
        li $t2, 0
Loop:   blt $t0, $t1, End
        nop
        sub $t0, $t0, $t1
        addi $t2, $t2, 1
        j   Loop
        nop
End:
.close
