    processor 6502

    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg.u Variables
    org $80

; X positions
P0X .byte
P1X .byte
M0X .byte
M1X .byte
BLX .byte

; Y positions
P0Y .byte
P1Y .byte
M0Y .byte
M1Y .byte
BLY .byte

; X forces
P0FX .byte
P1FX .byte
BLFX .byte

; Y forces
P0FY .byte
P1FY .byte
BLFY .byte

; Sprite Pointers
P0SPR .word
P1SPR .word

; Sprite offsets
P0SPROFF .byte
P1SPROFF .byte

; Constants (prepend # when used)
PH equ 3
BALLHEIGHT equ 5
GRAVITY equ 1
COLORP0 equ $36
COLORP1 equ $98
COLORBL equ $06

    seg Code
    org $f000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Initialize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Start
    CLEAN_START

    jsr StartPositions

    lda #COLORP0
    sta COLUP0
    lda #COLORP1
    sta COLUP1
    lda #COLORBL
    sta COLUPF

    lda #2
    sta ENABL

    lda #0
    tay

    lda (P0SPR),y
    sta GRP0

    lda (P1SPR),y
    sta GRP1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Frame
    VERTICAL_SYNC

; Vertical Blank timer setup
    lda #42 ;(((36 * 76) + 13) / 64) = 42.9531
    sta WSYNC
    sta TIM64T

; Set X on all objects
    ldx #4
XLoop
    lda P0X,x
    jsr SetX
    dex
    bpl XLoop

    sta WSYNC
    sta HMOVE

; Vertical Blank Wait
WaitVBlank
    lda INTIM
    bne WaitVBlank

; Turn off VBLANK
; A should already be zero? If somehow not, then lda #0 here
    sta VBLANK

; Visible timer setup
    lda #229 ;(((192 * 76) + 13) / 64) = 228.203125
    sta WSYNC
    sta TIM64T

; Draw logic

; Visible wait
WaitVisible
    lda INTIM
    bne WaitVisible

; VBLANK on
    lda #2
    sta VBLANK

; Overscan timer setup
    lda #36 ;(((30 * 76) + 13) / 64) = 35.828125
    sta WSYNC
    sta TIM64T

; Overscan logic
    jsr ReadJoysticks

; Overscan wait
WaitOverscan
    lda INTIM
    bne WaitOverscan

; Next frame
    jmp Frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StartPositions
    lda #5
    sta P0X

    lda #79
    sta BLX

    lda #147
    sta P1X

    lda #0
    sta P0Y
    sta P1Y
    sta BLY

    lda #8
    sta REFP1

    lda #<PGFX0
    sta P0SPR
    sta P1SPR

    lda #>PGFX0
    sta P0SPR+1
    sta P1SPR+1

    rts

SetX
    sta WSYNC
    bit 0
    sec
SetXDivide
    sbc #15
    bcs SetXDivide
    eor #7
    asl
    asl
    asl
    asl
    sta RESP0,x
    sta HMP0,x
    rts

ReadJoysticks
    lda #$10
    bit SWCHA
    bne DownP0
    dec P0Y
    jmp LeftP0
DownP0
    lda #$20
    bit SWCHA
    bne LeftP0
    inc P0Y
LeftP0
    lda #$40
    bit SWCHA
    bne RightP0
    dec P0X
    jmp UpP1
RightP0
    lda #$80
    bit SWCHA
    bne UpP1
    inc P0X
UpP1
    lda #$01
    bit SWCHA
    bne DownP1
    dec P1Y
    jmp LeftP1
DownP1
    lda #$02
    bit SWCHA
    bne LeftP1
    inc P1Y
LeftP1
    lda #$04
    bit SWCHA
    bne RightP1
    dec P1X
    jmp EndJoy
RightP1
    lda #$08
    bit SWCHA
    bne EndJoy
    inc P1X
EndJoy
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    align $100

PGFX0
    .byte #%11000000
    .byte #%11111110
    .byte #%01000100

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Finalize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $fffc

    .word Start
    .word Start
