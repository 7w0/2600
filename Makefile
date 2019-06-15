SRC=./src
BIN=./bin
ASM=/home/j/bin/dasm/bin/dasm
ASMFLAGS=-I$(SRC) -l$(BIN)/2600.lst -s$(BIN)/2600.sym -f3 -v5
TARGET=$(BIN)/2600.bin

all:
	$(ASM) $(SRC)/2600.asm $(ASMFLAGS) -o$(TARGET)
	stella -lc Paddles $(TARGET)
	#stella -debug $(TARGET)
