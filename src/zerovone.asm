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

PlayerHeight equ 9
BallHeight equ 9

    seg Code
    org $f000

Start
    CLEAN_START

;; Delay P0 and BL
    lda #1
    sta VDELP0
    sta VDELBL

;; Set BL size 4 and PF to Score mode and Reflect
    lda #%00100011
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
    lda #BallHeight
    sta ENABL
    sec
    isb LineCountBL
    bcc .NoBall
    lda #2
    sta ENABL
.NoBall

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
    jsr ApplyForces

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
    sta XP0
    lda #79
    sta XBL
    lda #147
    sta XP1

    lda #242;#PlayerHeight
    sta YP0
    sta YP1
    lda #242;#BallHeight
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
;; Y P0
    ldx YP0
    ldy #0

.UpP0
    lda #$10
    bit SWCHA
    bne .DownP0
    cpx #254
    bcs .ApplyYVP0
    ldy #$01
    jmp .ApplyYVP0

.DownP0
    lda #$20
    bit SWCHA
    bne .ApplyYVP0
    cpx #175
    bcc .ApplyYVP0
    ldy #$FF

.ApplyYVP0
    sty YVP0

;; X P0
    ldx XP0
    ldy #0

.LeftP0
    lda #$40
    bit SWCHA
    bne .RightP0
    cpx #1
    bcc .ApplyXVP0
    ldy #$FF
    jmp .ApplyXVP0
.RightP0
    lda #$80
    bit SWCHA
    bne .ApplyXVP0
    cpx #152
    bcs .ApplyXVP0
    ldy #$01

.ApplyXVP0
    sty XVP0

;; Y P1
    ldx YP1
    ldy #0

.UpP1
    lda #$01
    bit SWCHA
    bne .DownP1
    cpx #254
    bcs .ApplyYVP1
    ldy #$01
    jmp .ApplyYVP1

.DownP1
    lda #$02
    bit SWCHA
    bne .ApplyYVP1
    cpx #175
    bcc .ApplyYVP1
    ldy #$FF

.ApplyYVP1
    sty YVP1

;; X P1
    ldx XP1
    ldy #0

.LeftP1
    lda #$04
    bit SWCHA
    bne .RightP1
    cpx #1
    bcc .ApplyXVP1
    ldy #$FF
    jmp .ApplyXVP1
.RightP1
    lda #$08
    bit SWCHA
    bne .ApplyXVP1
    cpx #152
    bcs .ApplyXVP1
    ldy #$01

.ApplyXVP1
    sty XVP1

    rts

ApplyForces
; P0
    lda XP0
    clc
    adc XVP0
    sta XP0

    lda YP0
    clc
    adc YVP0
    sta YP0
; P1
    lda XP1
    clc
    adc XVP1
    sta XP1

    lda YP1
    clc
    adc YVP1
    sta YP1
; BL
    lda XBL
    clc
    adc XVBL
    sta XBL

    lda YBL
    clc
    adc YVBL
    sta YBL
    rts

;; DATA

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
    .byte #$06;
    .byte #$06;
    .byte #$06;
    .byte #$38;
    .byte #$38;
    .byte #$06;
    .byte #$06;
    .byte #$06;

P1Colors
    .byte #0
    .byte #$06;
    .byte #$06;
    .byte #$06;
    .byte #$98;
    .byte #$98;
    .byte #$06;
    .byte #$06;
    .byte #$06;

;; Finalize
    org $fffc

    .word Start
    .word Start
