    lda #<PNKGRL
    sta P0SPRIPTR
    lda #>PNKGRL
    sta P0SPRIPTR+1

    lda #<PGCOLU
    sta P0COLUPTR
    lda #>PGCOLU
    sta P0COLUPTR+1

    lda #33
    sta P0X
    sta P0Y
