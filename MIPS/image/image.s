.psx
.create "image.bin", 0x80010000

.org 0x80010000

; ---------------------
; IO Port
; ---------------------
IO_BASE_ADDR equ 0x1F80      ; IO Ports Memory map base address

; ---------------------
; GPU Registers
; ---------------------
GP0 equ 0x1810               ; GP0 @ $1F801810: Rendering data & VRAM Access
GP1 equ 0x1814               ; GP1 @ $1F801814: Display Control & Environment setup

; ---------------------
; Image constants
; ---------------------
IMG_WIDTH      equ 640
IMG_HEIGHT     equ 480
IMG_SIZE_BYTES equ 921600

Main:
  ; ---------------------------------------------------------------------------
  ; Set $a0 as the global parameter with the IO_BASE_ADDR to be used by subs
  ; ---------------------------------------------------------------------------
  lui $a0, IO_BASE_ADDR      ; Global Param: I/O Port Base Address (0x1F80****)

  ; ---------------------------------------------------------------------------
  ; Send commands to GP1 (mapped at 0x1F801814)
  ; These GP1 is for display control and environment setup
  ; (Command = 8-Bit MSB, Parameter = 24-Bit LSB)
  ; CCPPPPPP: CC=Command PPPPPP=Parameter
  ; ---------------------------------------------------------------------------
  li $t1, 0x00000000         ; 00 = Reset GPU
  sw $t1, GP1($a0)           ; Write to GP1

  li $t1, 0x03000000         ; 03 = Display enable
  sw $t1, GP1($a0)           ; Write to GP1

  li $t1, 0x08000037         ;
  sw $t1, GP1($a0)           ; Write to GP1

  li $t1, 0x06C60260         ; 06 = Horz Display Range - 0bxxxxxxxxxxXXXXXXXXXX (3168..608)
  sw $t1, GP1($a0)           ; Write to GP1
  
  li $t1, 0x0707e018         ;
  sw $t1, GP1($a0)           ; Write to GP1

  ; ---------------------------------------------------------------------------
  ; Send commands to GP0 (mapped at 0x1F801810)
  ; These GP0 commands are to setup the drawing area
  ; (Command = 8-Bit MSB, Parameter = 24-Bit LSB)
  ; CCPPPPPP  CC=Command PPPPPP=Parameter
  ; ---------------------------------------------------------------------------
  li $t1, 0xE1000400         ; E1 = Draw Mode Settings
  sw $t1, GP0($a0)			     ; Write to GP0

  li $t1, 0xE3000000		     ; E3 = Drawing Area TopLeft - 0bYYYYYYYYYYXXXXXXXXXX (10 bits for Y and X)
  sw $t1, GP0($a0)	         ; Write to GP0
  
  li $t1, 0xE403BD3F         ; E4 = Drawing area BottomRight - 0bYYYYYYYYYYXXXXXXXXXX (10 bits for X=319 and Y=239)
  sw $t1, GP0($a0)           ; Write to GP0

  li $t1, 0xE5000000         ; E5 = Drawing Offset - 0bYYYYYYYYYYYXXXXXXXXXXXX (X=0, Y=0)
  sw $t1, GP0($a0)		       ; Write to GP0
 
  ; ---------------------------------------------------------------------------
  ; Copy a rectangle from CPU to VRAM
  ; ---------------------------------------------------------------------------
  li $t1, 0xA0000000         ; A0 = Copy Rect CPU to VRAM (0xA0000000)
  sw $t1, GP0($a0)           ; Write GP0 Command
  
  li $t1, 0x00000000         ; Copy Area, TopLeft (x=150, y=100)
  sw $t1, GP0($a0)           ; Write to GP0
  
  li $t1, 0x01e003c0         ; Copy Area, 0xHHHHWWWW (Height=480, Width=640)
  sw $t1, GP0($a0)           ; Write to GP0

  li   $t0, IMG_SIZE_BYTES   ; Load the total of bytes of the image
  sra  $t0, $t0, 2
  
  la  $t2, Image             ; $t2 = image offset in memory
LoopWords:
  lw    $t1, 0($t2)          ; t1 = word from the image array
  nop
  sw    $t1, GP0($a0)        ; Write to GP0
  addiu $t2, 4               ; $t2 += 4
  addiu $t0, $t0, -1         ; t0--
  bnez  $t0, LoopWords       ; if ($t0 != 0), keep looping
  nop

LoopForever:
  j LoopForever              ; Continuous loop
  nop

Image:
        .incbin "logo.bin"
.close
