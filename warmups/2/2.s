.psx
.create "exercise2.bin", 0x80010000
.org 0x80010000
Main:
        li $t0, 1
        li $t1, 0
Loop:
        add $t1, $t1, $t0
        addi $t0, $t0, 1
        ble $t0, 10, Loop
        nop
; 1. Start $t0 with the value 1 and $t1 with the value 0
; 2. Loop, incrementing $t0 until it reaches the value 10
; 3. Keep adding and accumulating all values of $t0 inside $t1
End:
.close
