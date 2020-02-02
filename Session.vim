let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/lab/2600
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
argglobal
%argdel
$argadd src
edit src/variables.asm
set splitbelow splitright
wincmd _ | wincmd |
vsplit
wincmd _ | wincmd |
vsplit
2wincmd h
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
wincmd _ | wincmd |
split
1wincmd k
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 24 + 70) / 141)
exe '2resize ' . ((&lines * 17 + 18) / 37)
exe 'vert 2resize ' . ((&columns * 78 + 70) / 141)
exe '3resize ' . ((&lines * 17 + 18) / 37)
exe 'vert 3resize ' . ((&columns * 78 + 70) / 141)
exe '4resize ' . ((&lines * 17 + 18) / 37)
exe 'vert 4resize ' . ((&columns * 37 + 70) / 141)
exe '5resize ' . ((&lines * 17 + 18) / 37)
exe 'vert 5resize ' . ((&columns * 37 + 70) / 141)
argglobal
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=999
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 25 - ((24 * winheight(0) + 17) / 35)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
25
normal! 05|
lcd ~/lab/2600
wincmd w
argglobal
if bufexists("~/lab/2600/src/visible.asm") | buffer ~/lab/2600/src/visible.asm | else | edit ~/lab/2600/src/visible.asm | endif
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=999
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 11 - ((10 * winheight(0) + 8) / 17)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
11
normal! 013|
lcd ~/lab/2600
wincmd w
argglobal
if bufexists("~/lab/2600/src/init.asm") | buffer ~/lab/2600/src/init.asm | else | edit ~/lab/2600/src/init.asm | endif
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=999
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 13 - ((12 * winheight(0) + 8) / 17)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
13
normal! 011|
lcd ~/lab/2600
wincmd w
argglobal
if bufexists("~/lab/2600/src/kernelp0.asm") | buffer ~/lab/2600/src/kernelp0.asm | else | edit ~/lab/2600/src/kernelp0.asm | endif
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=999
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 9 - ((8 * winheight(0) + 8) / 17)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
9
normal! 05|
lcd ~/lab/2600
wincmd w
argglobal
if bufexists("~/lab/2600/src/data.asm") | buffer ~/lab/2600/src/data.asm | else | edit ~/lab/2600/src/data.asm | endif
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=999
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 7 - ((6 * winheight(0) + 8) / 17)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
7
normal! 05|
lcd ~/lab/2600
wincmd w
4wincmd w
exe 'vert 1resize ' . ((&columns * 24 + 70) / 141)
exe '2resize ' . ((&lines * 17 + 18) / 37)
exe 'vert 2resize ' . ((&columns * 78 + 70) / 141)
exe '3resize ' . ((&lines * 17 + 18) / 37)
exe 'vert 3resize ' . ((&columns * 78 + 70) / 141)
exe '4resize ' . ((&lines * 17 + 18) / 37)
exe 'vert 4resize ' . ((&columns * 37 + 70) / 141)
exe '5resize ' . ((&lines * 17 + 18) / 37)
exe 'vert 5resize ' . ((&columns * 37 + 70) / 141)
tabnext 1
badd +1 ~/lab/2600/src/variables.asm
badd +1 ~/lab/2600/src
badd +1 ~/lab/2600/src/visible.asm
badd +11 ~/lab/2600/src/init.asm
badd +0 ~/lab/2600/src/kernelp0.asm
badd +7 ~/lab/2600/src/data.asm
badd +25 ~/lab/2600/src/2600.asm
badd +7 ~/lab/2600/src/verticalblank.asm
badd +4 ~/lab/2600/Makefile
badd +1 ~/lab/2600/kernelp0.asm
badd +1 ~/lab/2600/src/standbmp.asm
badd +1 ~/lab/2600/src/hattedman.asm
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=atI
set winminheight=1 winminwidth=1
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
