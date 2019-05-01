ASM=/home/j/bin/dasm/bin/dasm
ASMFLAGS=-l2600.lst -s2600.sym -f3 -v5
TARGET=2600.bin

all:
	$(ASM) 2600.asm $(ASMFLAGS) -o$(TARGET)
	stella -lc Paddles $(TARGET)
	#stella -debug $(TARGET)
