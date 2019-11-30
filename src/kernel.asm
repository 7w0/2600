    ldx #192
    ldy #0

Kernel
    txa
    sta COLUPF
    sty COLUBK
    lda #$CC
    sta PF0
    lda #$CC
    sta PF1
    lda #$CC
    sta PF2

    sta WSYNC

    iny
    dex

    bne Kernel

