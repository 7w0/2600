    MAC PADDLE_0_CHECK

    lda INPT0
    bpl .store
    .byte $2c
.store sty P0X

    ENDM
