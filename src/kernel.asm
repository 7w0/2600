    ldx #181

Kernel
    txa
    sta WSYNC
    sta GRP0
    sta GRP1
    sta ENAM0
    sta ENAM1
    sta ENABL
    sta NUSIZ0
    sta NUSIZ1
    sta CTRLPF

    dex

    bne Kernel

