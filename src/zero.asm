    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

; Position
XP0 .byte
YP0 .byte
XDecP0 .byte
YDecP0 .byte

; Destination
XDestP0 .byte
YDestP0 .byte
XDestDecP0 .byte
YDestDecP0 .byte

; Player Direction
DirP0 .byte
DirDecP0 .byte

; Acceleration
XAccP0 .byte
YAccP0 .byte
XAccDecP0 .byte
YAccDecP0 .byte

; Velocity
XVelP0 .byte
YVelP0 .byte
XVelDecP0 .byte
YVelDecP0 .byte

TempWord .word

; D0:0 Roll
; D1:0 Boost
; D2:0 Direction -Clockwise
; D3:0 Direction +Clockwise
; D4:0 Jump
FlagsP0 .byte

LineColorP0 .byte

LineCountP0 .byte
LineCountM0 .byte

PtrSpriteP .word
FrameP0 .byte
PtrColorP0 .word

    seg Code
    org $f000

; Constants
Gravity equ 5
PlayerHeight equ 9
PlayerMinX equ 1
PlayerMaxX equ 152
PlayerMinY equ 170
PlayerMaxY equ 255
RollAccX equ 10
RollAccY equ 10
RollDecX equ 5
BoostAccX equ 15
BoostAccY equ 15
TurnRate equ 10

Start
    CLEAN_START

;; Vertical Delay P0 and BL
    lda #1
    sta VDELP0
    sta VDELBL

;; Set BL size 2 and PF to Score mode and Reflect
    lda #%00010011
    sta CTRLPF

;; Init pointers
    lda #<ColorFrame0
    sta PtrColorP0
    lda #>ColorFrame0
    sta PtrColorP0+1

    lda #<Frame0
    sta PtrSpriteP

    lda #>Frame0
    sta PtrSpriteP+1

;; Set initial positions
    jsr StartPositions

    lda #$06
    sta COLUPF
    lda #$D0
    sta COLUBK

    lda #$ff
    sta FlagsP0
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

    sta WSYNC
    sta HMOVE

; Init Y counters to object Y coordinates
    lda YP0
    sta LineCountP0

;; Vertical Blank Wait
WaitVBlank
    lda INTIM
    bne WaitVBlank
    sta VBLANK ; Turn off VBLANK. A is already 0.

;; Visible
    ldx #96
DisplayLoop

;; P0
    lda #PlayerHeight
    sec
    isb LineCountP0
    bcs .DrawP0
    lda #0
.DrawP0
    clc
    adc FrameP0
    tay
    lda (PtrColorP0),y
    sta LineColorP0
    lda (PtrSpriteP),y
    sta GRP0

    lda LineColorP0
    sta WSYNC
    sta COLUP0
    sta WSYNC
    sta GRP1

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

    lda DirP0
    and #15

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
    lda #50
    sta XP0

    lda #200
    sta YP0

    lda #0
    sta FrameP0

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

    rts

UpdatePlayers
.CheckLeft
    lda #$04
    and FlagsP0,x
    bne .CheckRight
    sec
    lda DirDecP0,x
    sbc #TurnRate
    sta DirDecP0,x
    lda DirP0,x
    sbc #0
    sta DirP0,x
    jmp .CheckAcceleration
.CheckRight
    lda #$08
    and FlagsP0,x
    bne .CheckAcceleration
    clc
    lda DirDecP0,x
    adc #TurnRate
    sta DirDecP0,x
    lda DirP0,x
    adc #0
    sta DirP0,x

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

    ldx #0
.CalcDestLoop
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
    bpl .CalcDestLoop

    rts

ApplyDestination

    ldx #0
.ApplyDestLoop
    lda XDestDecP0,x
    sta XDecP0,x

    lda XDestP0,x
    sta XP0,x

    lda YDestDecP0,x
    sta YDecP0,x

    lda YDestP0,x
    sta YP0,x

    dex
    bpl .ApplyDestLoop

    rts

    align $100

Frame0
    .byte #0
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%10111101
    .byte #%10111101
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
Frame1
    .byte #0
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
    .byte #%10111000
    .byte #%00011101
    .byte #%00000000
    .byte #%00000000
    .byte #%00000000
Frame2
    .byte #0
    .byte #%00000000
    .byte #%00000000
    .byte #%01000000
    .byte #%10011100
    .byte #%00111001
    .byte #%00000010
    .byte #%00000000
    .byte #%00000000
Frame3
    .byte #0
    .byte #%00000000
    .byte #%00000000
    .byte #%01000000
    .byte #%00011000
    .byte #%00011000
    .byte #%00000010
    .byte #%00000000
    .byte #%00000000
Frame4
    .byte #0
    .byte #%00000000
    .byte #%00100000
    .byte #%01000000
    .byte #%00011000
    .byte #%00011000
    .byte #%00000010
    .byte #%00000100
    .byte #%00000000
Frame5
    .byte #0
    .byte #%00000000
    .byte #%00100000
    .byte #%00001000
    .byte #%00011000
    .byte #%00011000
    .byte #%00010000
    .byte #%00000100
    .byte #%00000000
Frame6
    .byte #0
    .byte #%00010000
    .byte #%00100000
    .byte #%00001000
    .byte #%00011000
    .byte #%00011000
    .byte #%00010000
    .byte #%00000100
    .byte #%00001000
Frame7
    .byte #0
    .byte #%00010000
    .byte #%00000000
    .byte #%00010000
    .byte #%00011000
    .byte #%00011000
    .byte #%00001000
    .byte #%00000000
    .byte #%00001000
Frame8
    .byte #0
    .byte #%00011000
    .byte #%00000000
    .byte #%00011000
    .byte #%00011000
    .byte #%00011000
    .byte #%00011000
    .byte #%00000000
    .byte #%00011000

ColorFrame0
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
ColorFrame1
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
ColorFrame2
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
ColorFrame3
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
ColorFrame4
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
ColorFrame5
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
ColorFrame6
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
ColorFrame7
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
ColorFrame8
    .byte #0
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;
    .byte #$0E;

    org $fffc

    .word Start
    .word Start
