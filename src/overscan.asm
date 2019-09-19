    lda #%10000010
    sta VBLANK

    lda #36 ;(((30 * 76) + 13) / 64) = 35.828125
    sta WSYNC
    sta TIM64T

WaitOverscan
    include "clearvisible.asm"

    lda INTIM
    bne WaitOverscan
