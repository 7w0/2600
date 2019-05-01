    MAC VERTICAL_BLANK

    lda #43 ;(((36 * 76) + 13) / 64) = 42.9531
    sta WSYNC
    sta TIM64T

    SET_XS

    sta WSYNC
    sta HMOVE

WaitVBlank
    lda INTIM
    bne WaitVBlank

    ENDM
