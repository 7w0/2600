    processor 6502

    seg.u Variables
    org $80
X .byte
Y .byte

    seg Code
    org $f000

Start
    lda #$f0
    sta X
    lda #$f8
    sta Y
    org $fffc

    .word Start
    .word Start

