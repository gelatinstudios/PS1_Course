.psx
.create "fillmem.bin", 0x80010000

.org 0x80010000

BASE_ADDR equ 0x0000

Main:
  li  $t0, 0xA000
  li  $t2, 0x11111111

Loop:
  sw   $t2, BASE_ADDR($t0)
  addi $t0, $t0, 4
  blt  $t0, 0xA100, Loop
        
End:

.close
