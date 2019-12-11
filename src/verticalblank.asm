    lda #42 ;(((36 * 76) + 13) / 64) = 42.9531
    sta WSYNC
    sta TIM64T

    lda P0Y
    sta P0YCNT

    include "setxs.asm"

    sta WSYNC
    sta HMOVE

WaitVBlank
    lda INTIM
    bne WaitVBlank
