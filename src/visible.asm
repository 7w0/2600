    lda #0
    sta VBLANK

    lda #228 ;(((192 * 76) + 13) / 64) = 228.203125
    sta WSYNC
    sta TIM64T

VisibleLoop

    lda INTIM
    bne VisibleLoop
