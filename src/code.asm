    seg Code

    org $f000

    include "subs.asm"
    include "start.asm"
    include "frame.asm"
    include "data.asm"

    org $fffc

    .word Start
    .word Start
