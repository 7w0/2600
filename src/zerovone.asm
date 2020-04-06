    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

P0X .byte
P1X .byte
M0X .byte
M1X .byte
BLX .byte

P0Y .byte
P1Y .byte
M0Y .byte
M1Y .byte
BLY .byte

PH equ 8

    seg Code
    org $f000

Start
    CLEAN_START

    lda #10
    sta P0X
    sta P0Y
    sta M0X
    sta M0Y

    lda #100
    sta P1X
    sta P1Y
    sta M1X
    sta M1Y

Frame
    VERTICAL_SYNC

; Vertical Blank
    lda #42 ;(((36 * 76) + 13) / 64) = 42.9531
    sta WSYNC
    sta TIM64T

; Set X for all 5 objects
    ldx #4
XLoop
    lda P0X,x
    jsr SetX
    dex
    bpl XLoop

    sta WSYNC
    sta HMOVE

WaitVBlank
    lda INTIM
    bne WaitVBlank
; End Vertical Blank

; Visible

    lda #0
    sta VBLANK

    lda #229 ;(((192 * 76) + 13) / 64) = 228.203125
    sta WSYNC
    sta TIM64T

    ; Draw logic

WaitVisible
    lda INTIM
    bne WaitVisible

; End Visible

; Overscan

    lda #%10000010
    sta VBLANK

    lda #36 ;(((30 * 76) + 13) / 64) = 35.828125
    sta WSYNC
    sta TIM64T

    ; Overscan logic

WaitOverscan
    lda INTIM
    bne WaitOverscan

; End Overscan

    jmp Frame

; Subroutines

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

; Data

    org $fffc

    .word Start
    .word Start
