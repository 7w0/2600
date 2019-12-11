NAME=2600
SRC=./src
BIN=./bin
ASM=dasm
ASMFLAGS=-I$(SRC) -L$(BIN)/$(NAME).lst -s$(BIN)/$(NAME).sym -f3 -v4 -T1 -E2
TARGET=$(BIN)/$(NAME).bin

$(NAME):
	$(ASM) $(SRC)/$(NAME).asm $(ASMFLAGS) -o$(TARGET)
