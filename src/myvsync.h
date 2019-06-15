    MAC MY_VERTICAL_SYNC

    sta WSYNC
    sta VSYNC
    sta WSYNC
    lda #0
    sta WSYNC
    sta VSYNC

    ENDM
