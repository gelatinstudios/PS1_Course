.psx
.create "hellogpu.bin", 0x80010000

.org 0x80010000

IO_BASE_ADDR equ 0x1f80

GP0 equ 0x1810
GP1 equ 0x1814

        lui $t0, IO_BASE_ADDR

;;; control
        ;; reset gpu
        li $t1, 0x00000000
        sw $t1, GP1($t0)
        
        ;; display enable
        li $t1, 0x03000000
        sw $t1, GP1($t0)

        ;; dispaly mode (320x240, 15-bit, NTSC)
        li $t1, 0x08000001
        sw $t1, GP1($t0)

        ;; horizontal range
        li $t1, 0x06c60260
        sw $t1, GP1($t0)
        
        ;; vertical range
        li $t1, 0x07042018
        sw $t1, GP1($t0)

;;; clear screen
        ;; draw mode
        li $t1, 0xe1000400
        sw $t1, GP0($t0)

        ;; topleft
        li $t1, 0xe3000000
        sw $t1, GP0($t0)

        ;; bottom right
        li $t1, 0xe403bd3f
        sw $t1, GP0($t0)

        ;; drawing offset
        li $t1, 0xe5000000
        sw $t1, GP0($t0)

        
        ;; fill rectangle
        li $t1, 0x0200ff00
        sw $t1, GP0($t0)

        ;; topleft
        li $t1, 0x00000000
        sw $t1, GP0($t0)

        ;; width & height
        li $t1, 0x00ef013f
        sw $t1, GP0($t0)

        
;;; draw triangle
        ;; flat magenta triangle
        li $t1, 0x20ff00ff
        sw $t1, GP0($t0)

        li $t1, 0x00100020
        sw $t1, GP0($t0)

        li $t1, 0x00500010
        sw $t1, GP0($t0)

        li $t1, 0x00250060
        sw $t1, GP0($t0)

;;; draw quad
        li $t1, 0x286d8240
        sw $t1, GP0($t0)

        li $t1, 0x00960096
        sw $t1, GP0($t0)

        li $t1, 0x006400be
        sw $t1, GP0($t0)

        li $t1, 0x00dc00a0
        sw $t1, GP0($t0)

        li $t1, 0x00cb0104
        sw $t1, GP0($t0)

;;; draw triangle
        ;; gouraud triangle
        li $t1, 0x30c0c0c0
        sw $t1, GP0($t0)

        li $t1, 0x00900050
        sw $t1, GP0($t0)

        li $t1, 0x0000d7ff
        sw $t1, GP0($t0)
        
        li $t1, 0x00900010
        sw $t1, GP0($t0)

        li $t1, 0x004bea83
        sw $t1, GP0($t0)

        li $t1, 0x00e00060
        sw $t1, GP0($t0)

Loop:   j Loop
        nop

.close
