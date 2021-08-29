set name=2600
set src=.\src
set bin=.\bin
set asm=dasm
set asmflags=-I%src% -L%bin%\%name%.lst -s%bin%\%name%.sym -f3 -v4 -T1 -E2
set target=%bin%\%name%.bin

%asm% %src%\%name%.asm %asmflags% -o%target%