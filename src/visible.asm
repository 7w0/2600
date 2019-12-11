    lda #0
    sta VBLANK

    lda #229 ;(((192 * 76) + 13) / 64) = 228.203125
    sta WSYNC
    sta TIM64T

    include "kernelp0.asm"

WaitVisible
    lda INTIM
    bne WaitVisible
