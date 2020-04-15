    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

XP0 .byte
XP1 .byte
XM0 .byte
XM1 .byte
XBL .byte

YP0 .byte
YP1 .byte
YM0 .byte
YM1 .byte
YBL .byte

XFracP0 .byte
XFracP1 .byte
XFracBL .byte

YFracP0 .byte
YFracP1 .byte
YFracBL .byte

XVP0 .byte
XVP1 .byte
XVBL .byte

YVP0 .byte
YVP1 .byte
YVBL .byte

LineColorP0 .byte
LineColorP1 .byte

LineCountP0 .byte
LineCountP1 .byte
LineCountM0 .byte
LineCountM1 .byte
LineCountBL .byte

PtrSpriteP0 .word
PtrSpriteP1 .word
PtrColorP0 .word
PtrColorP1 .word

Speed equ 100
PlayerHeight equ 9
BallHeight equ 9
PlayerMinX equ 1
PlayerMaxX equ 152
PlayerMinY equ 170
PlayerMaxY equ 255
MaxVelocityRollX equ 2

    seg Code
    org $f000

Start
    CLEAN_START

;; Delay P0 and BL
    lda #1
    sta VDELP0
    sta VDELBL

;; Set BL size 2 and PF to Score mode and Reflect
    lda #%00010011
    sta CTRLPF

;; Init pointers
    lda #<P0Colors
    sta PtrColorP0
    lda #>P0Colors
    sta PtrColorP0+1

    lda #<P1Colors
    sta PtrColorP1
    lda #>P1Colors
    sta PtrColorP1+1

    lda #<PlayerBitmap
    sta PtrSpriteP0
    sta PtrSpriteP1

    lda #>PlayerBitmap
    sta PtrSpriteP0+1
    sta PtrSpriteP1+1

;; Set initial positions
    jsr StartPositions

    lda #$06
    sta COLUPF
    lda #$D0
    sta COLUBK

;; Frame
Frame
    VERTICAL_SYNC

;; Vertical Blank timer setup
;; (((36 * 76) + 13) / 64) = 42.9531
    lda #42
    sta WSYNC
    sta TIM64T

;; Set X on all objects
    ldx #4
SetXLoop
    lda XP0,x
    jsr SetX
    dex
    bpl SetXLoop
    sta WSYNC
    sta HMOVE

; Init Y counters to object Y coordinates
    ldx #4
YCounterLoop
    lda YP0,x
    sta LineCountP0,x
    dex
    bpl YCounterLoop

;; Vertical Blank Wait
WaitVBlank
    lda INTIM
    bne WaitVBlank
    sta VBLANK ; Turn off VBLANK. A is already 0.

;; Visible
    ldx #96
KernelLoop

;; Ball
    ldy #0
    lda #1
    sec
    isb LineCountBL
    bcc .NoBall
    ldy #2
.NoBall
    sty ENABL

;; P0
    lda #PlayerHeight
    sec
    isb LineCountP0
    bcs .DrawP0
    lda #0
.DrawP0
    tay
    lda (PtrColorP0),y
    sta LineColorP0
    lda (PtrSpriteP0),y
    sta GRP0

; P1
    lda #PlayerHeight
    sec
    isb LineCountP1
    bcs .DrawP1
    lda #0
.DrawP1
    tay
    lda (PtrColorP1),y
    sta LineColorP1
    lda (PtrSpriteP1),y
    tay

    lda LineColorP0
    sta WSYNC
    sta COLUP0
    lda LineColorP1
    sta COLUP1
    sty GRP1

    dex
    bne KernelLoop

;; Overscan
    lda #2
    sta VBLANK

;; Overscan timer setup
;; (((30 * 76) + 13) / 64) = 35.828125
    lda #36
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
    lda #0
    sta XP0
    lda #80
    sta XBL
    lda #152
    sta XP1

    lda #169
    sta YP0
    sta YP1
    lda #167
    sta YBL

    lda #8
    sta REFP1

    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set X Coordinate (A) of object offset (X) from P0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
.UpP0
    lda #$10
    bit SWCHA
    bne .DownP0
    clc
    lda YFracP0
    adc #<Speed
    sta YFracP0
    lda YP0
    adc #>Speed
    sta YP0

.DownP0
    lda #$20
    bit SWCHA
    bne .LeftP0
    sec
    lda YFracP0
    sbc #<Speed
    sta YFracP0
    lda YP0
    sbc #>Speed
    sta YP0

.LeftP0
    lda #$40
    bit SWCHA
    bne .RightP0
    sec
    lda XFracP0
    sbc #<Speed
    sta XFracP0
    lda XP0
    sbc #>Speed
    sta XP0

.RightP0
    lda #$80
    bit SWCHA
    bne .UpP1
    clc
    lda XFracP0
    adc #<Speed
    sta XFracP0
    lda XP0
    adc #>Speed
    sta XP0

.UpP1
    lda #$01
    bit SWCHA
    bne .DownP1
    clc
    lda YFracP1
    adc #<Speed
    sta YFracP1
    lda YP1
    adc #>Speed
    sta YP1

.DownP1
    lda #$02
    bit SWCHA
    bne .LeftP1
    sec
    lda YFracP1
    sbc #<Speed
    sta YFracP1
    lda YP1
    sbc #>Speed
    sta YP1

.LeftP1
    lda #$04
    bit SWCHA
    bne .RightP1
    sec
    lda XFracP1
    sbc #<Speed
    sta XFracP1
    lda XP1
    sbc #>Speed
    sta XP1

.RightP1
    lda #$08
    bit SWCHA
    bne .JoyDone
    clc
    lda XFracP1
    adc #<Speed
    sta XFracP1
    lda XP1
    adc #>Speed
    sta XP1

.JoyDone
    rts

;; DATA

    align $100

PlayerBitmap
    .byte #0
    .byte #%00011000
    .byte #%00100100
    .byte #%01000010
    .byte #%01011010
    .byte #%01111110
    .byte #%01000010
    .byte #%00100100
    .byte #%00011000

P0Colors
    .byte #0
    .byte #$06
    .byte #$06
    .byte #$06
    .byte #$38
    .byte #$38
    .byte #$06
    .byte #$06
    .byte #$06

P1Colors
    .byte #0
    .byte #$06
    .byte #$06
    .byte #$06
    .byte #$98
    .byte #$98
    .byte #$06
    .byte #$06
    .byte #$06

;; Finalize
    org $fffc

    .word Start
    .word Start
