NAME=2600
SRC=./src
BIN=./bin
ASM=dasm
ASMFLAGS=-I$(SRC) -l$(BIN)/$(NAME).lst -s$(BIN)/$(NAME).sym -f3 -v5 -E2
TARGET=$(BIN)/$(NAME).bin

$(NAME):
	$(ASM) $(SRC)/$(NAME).asm $(ASMFLAGS) -o$(TARGET)
