    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

XP0 .word
XP1 .word
XM0 .byte
XM1 .byte
XBL .word

YP0 .word
YP1 .word
YM0 .byte
YM1 .byte
YBL .word

XVelP0 .word
XVelP1 .word
XVelBL .word

XAccP0 .word
XAccP1 .word
XAccBL .word

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

    seg Code
    org $f000

; Constants
Gravity equ 100
PlayerHeight equ 7
PlayerMinX equ 1
PlayerMaxX equ 152
PlayerMinY equ 170
PlayerMaxY equ 255

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
    lda XP0+1
    ldx #0
    jsr SetX

    lda XP1+1
    ldx #1
    jsr SetX

    lda XBL+1
    ldx #4
    jsr SetX

    sta WSYNC
    sta HMOVE

; Init Y counters to object Y coordinates
    lda YP0+1
    sta LineCountP0

    lda YP1+1
    sta LineCountP1

    lda YBL+1
    sta LineCountBL

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

; Turn on VBLANK
    lda #2
    sta VBLANK

;; Timer setup
;; (((30 * 76) + 13) / 64) = 35.828125
    lda #36
    sta WSYNC
    sta TIM64T

; Overscan logic
    jsr ReadJoysticks

;; Apply accleration
    clc
    lda XVelP0
    adc XAccP0
    sta XVelP0
    lda XVelP0+1
    adc XAccP0+1
    sta XVelP0+1

    clc
    lda XP0
    adc XVelP0
    sta XP0
    lda XP0+1
    adc XVelP0+1
    sta XP0+1

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
    sta XP0+1
    lda #80
    sta XBL+1
    lda #152
    sta XP1+1

    lda #169
    sta YP0+1
    sta YP1+1
    lda #167
    sta YBL+1

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

.DownP0
    lda #$20
    bit SWCHA
    bne .LeftP0

    ldx #0
    ldy #0
.LeftP0
    lda #$40
    bit SWCHA
    bne .RightP0
    ldy #10
    ldx #$FF
    jmp .ApplyXP0
.RightP0
    lda #$80
    bit SWCHA
    bne .UpP1
    ldy #10
.ApplyXP0
    sty XAccP0
    stx XAccP0+1

.UpP1
    lda #$01
    bit SWCHA
    bne .DownP1

.DownP1
    lda #$02
    bit SWCHA
    bne .LeftP1

.LeftP1
    lda #$04
    bit SWCHA
    bne .RightP1

.RightP1
    lda #$08
    bit SWCHA
    bne .JoyDone

.JoyDone
    rts

;; DATA

    align $100

PlayerBitmap
    .byte #0
    .byte #%00011000
    .byte #%00100100
    .byte #%01011010
    .byte #%01111110
    .byte #%00100100
    .byte #%00011000

P0Colors
    .byte #0
    .byte #$06
    .byte #$06
    .byte #$38
    .byte #$38
    .byte #$06
    .byte #$06

P1Colors
    .byte #0
    .byte #$06
    .byte #$06
    .byte #$98
    .byte #$98
    .byte #$06
    .byte #$06

;; Finalize
    org $fffc

    .word Start
    .word Start
