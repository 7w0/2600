    processor 6502

    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RAM_ORIGIN = $80
CODE_ORIGIN = $f000
VCS_START = $fffc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg.u Variables
    org RAM_ORIGIN

XP0 .byte
XP1 .byte
XM0 .byte
XM1 .byte
XBL .byte

DEC_XP0 .byte
DEC_XP1 .byte
DEC_XBL .byte

XP0VW .byte
XP0VD .byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg Code
    org CODE_ORIGIN

Start
    CLEAN_START

;; Set initial positions
    lda #$00
    sta XP0
    lda #$0F
    sta XP1
    lda #$10
    sta XM0
    lda #$1F
    sta XM1
    lda #$20
    sta XBL

;; Frame
Frame
    VERTICAL_SYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VERTICAL BLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Timer (((36 * 76) + 13) / 64) = 42.9531
    lda #42
    sta WSYNC
    sta TIM64T

    ; Set Xs
    ldx #4
XLoop
    lda XP0,x
    jsr SetX
    dex
    bpl XLoop

    sta WSYNC
    sta HMOVE

    ; Wait
WaitVBlank
    lda INTIM
    bne WaitVBlank
    sta VBLANK ; Turn off VBLANK. A is already 0.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VISIBLE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ldx #192
DisplayLoop
    sta WSYNC
    dex
    bne DisplayLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OVERSCAN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Turn on VBLANK
    lda #2
    sta VBLANK

    ; Timer (((30 * 76) + 13) / 64) = 35.828125
    lda #36
    sta WSYNC
    sta TIM64T

    ; Logic

    ; Wait
WaitOverscan
    lda INTIM
    bne WaitOverscan

    jmp Frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SUBROUTINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Set X Coordinate (A) of object offset (X) from P0
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SET START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org VCS_START

    .word Start
    .word Start
