    processor 6502

    seg.u Variables
    org $80
XL .byte
XH .byte
XVL .byte
XVH .byte
XAL .byte
XAH .byte
XDL .byte
XDH .byte

    seg Code
    org $f000

Start
    lda #$00
    sta XL
    sta XH

    lda #$01
    sta XAL

    lda #$10
    sta XAH

Go
    clc
    lda XVL
    adc XAL
    sta XDL
    lda XVH
    adc XAH
    sta XDH

    clc
    lda XL
    adc XDL

    org $fffc

    .word Start
    .word Start

