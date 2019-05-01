    MAC VISIBLE

    lda #0
    sta VBLANK

    ldy #192
VisibleLoop
    sta WSYNC
    PADDLE_0_CHECK
    sty COLUP0
    ;lda #$ff
    sta GRP0
    dey
    bne VisibleLoop

    ENDM
