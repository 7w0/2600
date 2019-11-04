    processor 6502

    include "vcs.h"
    include "macro.h"

    seg.u Variables
    org $80

    include "variables.asm"

    seg Code

    org $f000

    include "setx.asm"

Start
    CLEAN_START

    include "init.asm"

Frame
    VERTICAL_SYNC

    include "verticalblank.asm"
    include "visible.asm"
    include "overscan.asm"

    jmp Frame

    include "data.asm"

    org $fffc

    .word Start
    .word Start
