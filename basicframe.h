    MAC BASIC_FRAME

Frame

    MY_VERTICAL_SYNC

    ldx #37
VBlankLoop
    sta WSYNC
    dex
    bne VBlankLoop

    lda #0
    sta VBLANK

    ldx #192
VisibleLoop
    sta WSYNC
    dex
    bne VisibleLoop

    lda #2
    sta VBLANK

    ldx #30
OverscanLoop
    sta WSYNC
    dex
    bne OverscanLoop

    jmp Frame

    ENDM
