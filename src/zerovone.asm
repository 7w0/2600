    processor 6502

    include "vcs.h"
    include "macro.h"

;Battle at $0280
;$1B vs $1C
;0v1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    seg.u Variables
    org $80

; X positions
P0X .byte
P1X .byte
M0X .byte
M1X .byte
BLX .byte

; Y positions
P0Y .byte
P1Y .byte
M0Y .byte
M1Y .byte
BLY .byte

; Y Counters
P0YC .byte
P1YC .byte
M0YC .byte
M1YC .byte
BLYC .byte

; X forces
P0FX .byte
P1FX .byte
BLFX .byte

; Y forces
P0FY .byte
P1FY .byte
BLFY .byte

; Sprite Pointers
P0SPR .word
P1SPR .word

; Sprite offsets
P0SPROFF .byte
P1SPROFF .byte

; Constants
PH equ 4
BALLHEIGHT equ 5
GRAVITY equ 1
COLORP0 equ $36
COLORP1 equ $98
COLORBL equ $06
VBLANKTIM64T equ 42 ;((((37 - 1) * 76) + 13) / 64) = 42.9531

    seg Code
    org $f000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Initialize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Start
    CLEAN_START

    lda #COLORP0
    sta COLUP0
    lda #COLORP1
    sta COLUP1
    lda #COLORBL
    sta COLUPF

    lda #1
    sta VDELP0
    sta VDELBL

    lda #%00100011
    sta CTRLPF

    jsr StartPositions

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Frame
    VERTICAL_SYNC


; Vertical Blank timer setup
    lda #VBLANKTIM64T
    sta WSYNC
    sta TIM64T

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set X on all objects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #4
XLoop
    lda P0X,x
    jsr SetX
    dex
    bpl XLoop
    sta WSYNC
    sta HMOVE

; Init Y counters with current Y position
    lda P0Y
    sta P0YC
    lda P1Y
    sta P1YC

; Vertical Blank Wait
WaitVBlank
    lda INTIM
    bne WaitVBlank

; Turn off VBLANK
; A should already be zero? If somehow not, then lda #0 here
    sta VBLANK

;; Visible 2-line kernel
    ldx #192
KernelLoop
; Ball
    txa
    sec
    sbc BLY
    cmp #BALLHEIGHT
    bcc .DrawBall
    lda #0
    jmp .SetBall
.DrawBall
    lda #2
.SetBall
    sta ENABL
; P0
    txa
    sec
    sbc P0Y
    cmp #PH
    bcc .DrawP0
    lda #0
.DrawP0
    tay
    lda (P0SPR),y
    sta GRP0
; P1
    txa
    sec
    sbc P1Y
    cmp #PH
    bcc .DrawP1
    lda #0
.DrawP1
    tay
    lda (P1SPR),y)
    sta WSYNC
    sta GRP1
    dex
    bne KernelLoop

;; End Visible

; VBLANK on
    lda #2
    sta VBLANK

; Overscan timer setup
    lda #36 ;(((30 * 76) + 13) / 64) = 35.828125
    sta WSYNC
    sta TIM64T

; Overscan logic
    jsr ReadJoysticks
    jsr ApplyForces

; Overscan wait
WaitOverscan
    lda INTIM
    bne WaitOverscan

; Next frame
    jmp Frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StartPositions
    lda #5
    sta P0X

    lda #79
    sta BLX

    lda #147
    sta P1X

    lda #80
    sta P0Y
    sta P1Y
    sta BLY

    lda #8
    sta REFP1

    lda #<PGFX0
    sta P0SPR
    sta P1SPR

    lda #>PGFX0
    sta P0SPR+1
    sta P1SPR+1

    rts

SetX
    sta WSYNC
    bit 0
    sec
SetXDivide
    sbc #15
    bcs SetXDivide
    eor #7
    asl
    asl
    asl
    asl
    sta RESP0,x
    sta HMP0,x
    rts

ReadJoysticks
    lda #$10
    bit SWCHA
    bne DownP0
    inc P0FY
    jmp LeftP0
DownP0
    lda #$20
    bit SWCHA
    bne LeftP0
    dec P0FY
LeftP0
    lda #$40
    bit SWCHA
    bne RightP0
    dec P0FX
    jmp UpP1
RightP0
    lda #$80
    bit SWCHA
    bne UpP1
    inc P0FX
UpP1
    lda #$01
    bit SWCHA
    bne DownP1
    inc P1FY
    jmp LeftP1
DownP1
    lda #$02
    bit SWCHA
    bne LeftP1
    dec P1FY
LeftP1
    lda #$04
    bit SWCHA
    bne RightP1
    dec P1FX
    jmp EndJoy
RightP1
    lda #$08
    bit SWCHA
    bne EndJoy
    inc P1FX
EndJoy
    rts

DrawPlayers
    lda #PH
    sec
    isb P0YC
    bcs DrawP0
    lda #0
DrawP0
    tay
    lda (P0SPR),y
    sta GRP0

    lda #PH
    sec
    isb P1YC
    bcs DrawP1
    lda #0
DrawP1
    tay
    lda (P1SPR),y
    sta WSYNC
    sta GRP1

    rts

ApplyForces
    lda P0X
    clc
    adc P0FX
    sta P0X

    lda P0Y
    clc
    adc P0FY
    sta P0Y
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PGFX0
    .byte #%00000000
    .byte #%01000100
    .byte #%11111110
    .byte #%11000000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Finalize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $fffc

    .word Start
    .word Start
