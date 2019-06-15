    processor 6502

    lda INPT0
    bpl .store
    .byte $2c
.store sty P0X
