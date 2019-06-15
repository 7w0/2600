    ldx #4
XLoop
    lda P0X,x
    jsr SetX
    dex
    bpl XLoop
