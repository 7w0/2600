    processor 6502

    include "vcs.h"
    include "macro.h"
    include "aliases.h"
    include "variables.h"
    include "init.h"
    include "verticalblank.h"
    include "visible.h"
    include "overscan.h"
    include "setx.h"
    include "setxs.h"
    include "paddle0.h"
    include "data.h"

    VARIABLES

    seg Code

    org $f000

    SET_X

Start

    CLEAN_START
    INIT

Frame

    VERTICAL_SYNC
    VERTICAL_BLANK
    VISIBLE
    OVERSCAN

    jmp Frame

    DATA

    org $fffc

    .word Start
    .word Start
