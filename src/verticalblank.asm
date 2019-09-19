    lda #42 ;(((36 * 76) + 13) / 64) = 42.9531
    sta WSYNC
    sta TIM64T

    include "setxs.asm"

    lda P0Y
    sta Y0
    lda P1Y
    sta Y1

    sta WSYNC
    sta HMOVE

WaitVBlank
    lda INTIM
    bne WaitVBlank
