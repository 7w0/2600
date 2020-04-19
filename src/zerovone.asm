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

XDirP0 .byte
XDirP1 .byte
XDirBL .byte

YDirP0 .byte
YDirP1 .byte
YDirBL .byte

XVelP0 .word
XVelP1 .word
XVelBL .word

YVelP0 .word
YVelP1 .word
YVelBL .word

TempWord .word

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
RollAccX equ 10
RollAccY equ 10
BoostAccX equ 15
BoostAccY equ 15
GroundFriction equ 5

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
    jsr MovePlayers

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
    lda #PlayerMinX
    sta XP0+1
    lda #80
    sta XBL+1
    lda #PlayerMaxX
    sta XP1+1

    lda #PlayerMinY
    sta YP0+1
    sta YP1+1
    lda #167
    sta YBL+1

    lda #8
    sta REFP1

    lda #$01
    sta XDirP0

    lda #$00
    sta YDirP0

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

MovePlayers
; P0 UDLR 10 20 40 80
; P1 UDLR 01 02 04 08
; bit SWCHA bne

; Moving horizontally?
    lda XVelP0+0
    eor XVelP0+1
    beq .CheckBounds

; Apply current velocity
    lda XVelP0+1
    bmi .NegativeVelocityP0+1

; Positive velocity, subtract friction, add velocity

    sec
    lda XVelP0+0
    sbc #GroundFriction
    sta XVelP0+0
    lda XVelP0+1
    sbc #0
    sta XVelP0+1
    bcs .ApplyPositveVelocity
    lda #0
    sta XVelP0+0
    sta XVelP0+1

.ApplyPositveVelocity
    clc
    lda XP0+0
    adc XVelP0+0
    sta XP0+0
    lda XP0+1
    adc XVelP0+1
    sta XP0+1
    jmp .CheckBounds

; Negative velocity, add friction, subtract absolute velocity

.NegativeVelocityP0
    clc
    lda XVelP0+0
    adc #GroundFriction
    sta XVelP0+0
    lda XVelP0+1
    adc #0
    sta XVelP0+1
    bcs .ApplyNegativeVelocity
    lda #0
    sta XVelP0+0
    sta XVelP0+1
.ApplyNegativeVelocity
    sec
    lda #0
    sbc XVelP0+0
    sta TempWord+0
    lda #0
    sbc XVelP0+1
    sta TempWord+1

    sec
    lda XP0+0
    sbc TempWord+0
    sta XP0+0
    lda XP0+1
    sbc TempWord+1
    sta XP0+1

; Check if moved out of bounds

.CheckBounds
    lda XP0+1
    ldx #PlayerMaxX
    sec
    cmp #PlayerMaxX
    bcs .ForceX
    ldx #PlayerMinX
    sec
    cmp #PlayerMinX
    bcc .ForceX
    jmp .CheckY
.ForceX
    lda #0
    sta XP0+0
    stx XP0+1

.CheckY
    lda YP0+1
    ldy #PlayerMaxY
    sec
    cmp #PlayerMaxY
    bcs .ForceY
    ldy #PlayerMinY
    sec
    cmp #PlayerMinY
    bcc .ForceY
    jmp .CheckBoundsDone
.ForceY
    lda #0
    sta YP0+0
    sty YP0+1
.CheckBoundsDone

; Ground?
    lda YP0+1
    cmp #PlayerMinY
    bne .NotOnGround
    ; On the ground
    lda #$10
    bit SWCHA
    bne .NotRolling
    ; Direction?
    lda XDirP0
    bmi .RollLeft

    clc
    lda XVelP0+0
    adc #RollAccX
    sta XVelP0+0
    lda XVelP0+1
    adc #0
    sta XVelP0+1

    jmp .MoveDone
.RollLeft

    sec
    lda XVelP0+0
    sbc #RollAccX
    sta XVelP0+0
    lda XVelP0+1
    sbc #0
    sta XVelP0+1
    jmp .MoveDone

.GoUpLeftWall
    jmp .MoveDone
.NotRolling

.NotOnGround
    lda XP0+1
    cmp #PlayerMinX
    beq .OnWall
    cmp #PlayerMaxX
    beq .OnWall
    jmp .NotOnWall
.OnWall
.NotOnWall
.MoveDone
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
