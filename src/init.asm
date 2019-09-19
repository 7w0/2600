    lda #05
    sta P0X
    lda #20
    sta P1X
    lda #45
    sta M0X
    lda #80
    sta M1X
    lda #100
    sta BLX

    lda #60
    sta P0Y
    lda #70
    sta P1Y
    lda #80
    sta M0Y
    lda #90
    sta M1Y
    lda #100
    sta BLY

    lda #<STANDBMP
    sta P0SPRIPTR
    sta P1SPRIPTR

    lda #>STANDBMP
    sta P0SPRIPTR+1
    sta P1SPRIPTR+1

    lda #<PNKGRCOLU
    sta P0COLUPTR
    sta P1COLUPTR

    lda #>PNKGRCOLU
    sta P0COLUPTR+1
    sta P1COLUPTR+1

    lda #0
    sta ENAM0
    sta ENAM1
    sta ENABL

    lda #$00
    sta NUSIZ0
    sta NUSIZ1
    lda #$00
    sta CTRLPF

    lda #$A3
    sta COLUP0
    lda #$B3
    sta COLUP1
    lda #$C3
    sta COLUPF

    lda #1
    sta VDELP0
