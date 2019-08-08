; Set exact x-coordinate of sprite P0,x to A.

; In: A = x-coordinate
;     X = sprite offset from P0

; Out: None

; Side Effects: Calls WSYNC. Strobes RESP0,X at the
; correct cycle and sets HMP0,X. A = horizontal
; motion value.

; Notes: X 0 = P0, 1 = P1, 2 = M0, 3 = M1, 4 = Ball.
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
