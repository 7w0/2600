    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

XP0W .byte
XP0D .byte

    seg Code
    org $f000

Start
    CLEAN_START

;; Set initial positions
    lda #$0A
    sta XP0W
    lda #0
    sta XP0D

;; Frame
Frame
    VERTICAL_SYNC

;; Vertical Blank timer setup
;; (((36 * 76) + 13) / 64) = 42.9531
    lda #42
    sta WSYNC
    sta TIM64T

;; Set X on all objects
    lda XP0W
    ldx #0
    jsr SetX

    sta WSYNC
    sta HMOVE

;; Vertical Blank Wait
WaitVBlank
    lda INTIM
    bne WaitVBlank
    sta VBLANK ; Turn off VBLANK. A is already 0.

;; Visible
    ldx #192
DisplayLoop
    sta WSYNC
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

; Overscan wait
WaitOverscan
    lda INTIM
    bne WaitOverscan

; Next frame
    jmp Frame

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

;; End
    org $fffc

    .word Start
    .word Start
