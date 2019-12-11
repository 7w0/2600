    ldy #SPRHEIGHT

KLOOP
    lda (P0SPRIPTR),y
    sta GRP0
    lda (P0COLUPTR),y
    sta COLUP0

    sta WSYNC

    dey
    bpl KLOOP
