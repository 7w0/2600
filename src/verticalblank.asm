    lda #42 ;(((36 * 76) + 13) / 64) = 42.9531
    sta WSYNC
    sta TIM64T

    include "setxs.asm"

    sta WSYNC
    sta HMOVE

WaitVBlank
    lda INTIM
    bne WaitVBlank
