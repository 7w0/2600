    lda #0
    sta VBLANK

    ldy #192
VisibleLoop
    sta WSYNC
    include "paddle0.asm"
    sty COLUP0
    ;lda #$ff
    sta GRP0
    dey
    bne VisibleLoop
