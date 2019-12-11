    lda #<HATMAN
    sta P0SPRIPTR
    lda #>HATMAN
    sta P0SPRIPTR+1

    lda #<HMCOLU
    sta P0COLUPTR
    lda #>HMCOLU
    sta P0COLUPTR+1

    lda #33
    sta P0X
    sta P0Y
