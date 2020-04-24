    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

XP0 .byte
XP1 .byte
XBL .byte
YP0 .byte
YP1 .byte
YBL .byte
XDecP0 .byte
XDecP1 .byte
XDecBL .byte
YDecP0 .byte
YDecP1 .byte
YDecBL .byte
XDestP0 .byte
XDestP1 .byte
XDestBL .byte
YDestP0 .byte
YDestP1 .byte
YDestBL .byte
XDestDecP0 .byte
XDestDecP1 .byte
XDestDecBL .byte
YDestDecP0 .byte
YDestDecP1 .byte
YDestDecBL .byte
XDirP0 .byte
XDirP1 .byte
XDirBL .byte
YDirP0 .byte
YDirP1 .byte
YDirBL .byte
XAccP0 .byte
XAccP1 .byte
XAccBL .byte
YAccP0 .byte
YAccP1 .byte
YAccBL .byte
XAccDecP0 .byte
XAccDecP1 .byte
XAccDecBL .byte
YAccDecP0 .byte
YAccDecP1 .byte
YAccDecBL .byte
XVelP0 .byte
XVelP1 .byte
XVelBL .byte
YVelP0 .byte
YVelP1 .byte
YVelBL .byte
XVelDecP0 .byte
XVelDecP1 .byte
XVelDecBL .byte
YVelDecP0 .byte
YVelDecP1 .byte
YVelDecBL .byte
XMinP0 .byte
XMinP1 .byte
XMinBL .byte
YMinP0 .byte
YMinP1 .byte
YMinBL .byte
XMaxP0 .byte
XMaxP1 .byte
XMaxBL .byte
YMaxP0 .byte
YMaxP1 .byte
YMaxBL .byte

TempWord .word

; D0:0 Roll
; D1:0 Boost
; D2:0 Direction -Clockwise
; D3:0 Direction +Clockwise
; D4:0 Jump
FlagsP0 .byte
FlagsP1 .byte

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

Gravity equ 5
PlayerHeight equ 7
PlayerMinX equ 1
PlayerMaxX equ 152
PlayerMinY equ 170
PlayerMaxY equ 255
RollAccX equ 10
RollAccY equ 10
RollDecX equ 5
BoostAccX equ 15
BoostAccY equ 15

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

    lda #$ff
    sta FlagsP0
    sta FlagsP1
;; Frame
Frame
    VERTICAL_SYNC

;; Vertical Blank timer setup
;; (((36 * 76) + 13) / 64) = 42.9531
    lda #42
    sta WSYNC
    sta TIM64T

;; Set X on all objects
    lda XP0
    ldx #0
    jsr SetX

    lda XP1
    ldx #1
    jsr SetX

    lda XBL
    ldx #4
    jsr SetX

    sta WSYNC
    sta HMOVE

; Init Y counters to object Y coordinates
    lda YP0
    sta LineCountP0

    lda YP1
    sta LineCountP1

    lda YBL
    sta LineCountBL

;; Vertical Blank Wait
WaitVBlank
    lda INTIM
    bne WaitVBlank
    sta VBLANK ; Turn off VBLANK. A is already 0.

;; Visible
    ldx #96
DisplayLoop

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
    bne DisplayLoop

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
    jsr HandleInput
    ldx #0
    jsr UpdatePlayers
    jsr CalculateDestination
    jsr ApplyDestination

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
    sta XP0
    lda #80
    sta XBL
    lda #PlayerMaxX
    sta XP1

    lda #PlayerMinY
    sta YP0
    sta YP1
    lda #167
    sta YBL

    lda #8
    sta REFP1

    lda #$01
    sta XDirP0

    lda #$01
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

HandleInput
    ; P0
    lda SWCHA
    lsr
    lsr
    lsr
    lsr
    ldx INPT4
    bpl .ButtonDownP0
    ora #$10
.ButtonDownP0
    sta TempWord+0

    lda FlagsP0
    and #$e0
    ora TempWord+0
    sta FlagsP0

    ; P1
    lda SWCHA
    and #$0f
    ldx INPT5
    bpl .ButtonDownP1
    ora #$10
.ButtonDownP1
    sta TempWord+0

    lda FlagsP1
    and #$e0
    ora TempWord+0
    sta FlagsP1

    rts

UpdatePlayers
    lda #$04
    and FlagsP0,x
    bne .CheckRight
    lda #$ff
    sta XDirP0
    jmp .CheckAcceleration
.CheckRight
    lda #$08
    and FlagsP0,x
    bne .CheckAcceleration
    lda #$01
    sta XDirP0
.CheckAcceleration
    lda #$01
    and FlagsP0,x
    bne .CheckBoosting
.CheckBoosting
    lda #$02
    and FlagsP0,x
    bne .NotAccelerating
.NotAccelerating
    lda #$01
    and FlagsP0,x
    bne .NotRolling
    ; On surface?
    lda YP0,x
    cmp #PlayerMinY
    beq .OnSurface
    lda XP0,x
    cmp #PlayerMinX
    bne .OnSurface
    cmp #PlayerMaxX
    bne .OnSurface
    jmp .InAir
.OnSurface
    lda XAccDecP0,x
    adc #<RollAccX
    sta XAccDecP0,x
    lda XAccP0,x
    adc #>RollAccX
    sta XAccP0,x
    jmp .NotBoosting
.NotRolling
    lda #02
    and FlagsP0,x
    bne .NotBoosting
.NotBoosting
    jmp .EndUpdatePlayer
.InAir
.EndUpdatePlayer
    rts

CalculateDestination

    ldx #2
.ObjectLoop
    clc
    lda XVelDecP0,x
    adc XAccDecP0,x
    sta TempWord+0
    lda XVelP0,x
    adc XAccP0,x
    sta TempWord+1

    clc
    lda XDecP0,x
    adc TempWord+0
    sta XDestDecP0,x
    lda XP0,x
    adc TempWord+1
    sta XDestP0,x

    clc
    lda YVelDecP0,x
    adc YAccDecP0,x
    sta TempWord+0
    lda YVelP0,x
    adc YAccP0,x
    sta TempWord+1

    clc
    lda YDecP0,x
    adc TempWord+0
    sta YDestDecP0,x
    lda YP0,x
    adc TempWord+1
    sta YDestP0,x

    dex
    bpl .ObjectLoop

    rts

ApplyDestination

    ldx #2
.DestLoop
    lda XDestDecP0,x
    sta XDecP0,x

    lda XDestP0,x
    sta XP0,x

    lda YDestDecP0,x
    sta YDecP0,x

    lda YDestP0,x
    sta YP0,x

    dex
    bpl .DestLoop

    rts

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

RollTableX
    .byte 10,8,6,4,2,0, -2, -4,-6,-8,-10,-8,-6,-4,-2,  0, 2, 4, 6, 8
RollTableY
    .byte 0, 2,4,6,8,10, 8,  6, 4, 2,  0,-2,-4,-6,-8,-10,-8,-6,-4,-2

    org $fffc

    .word Start
    .word Start
