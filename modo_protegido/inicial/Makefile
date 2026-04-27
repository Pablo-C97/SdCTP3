# Variables
AS = as
LD = ld
OBJCOPY = objcopy
ASFLAGS = -g
LDFLAGS = -T link.ld

# Archivos
OBJ = main.o
ELF = main.elf
IMG = main.img

# Regla principal
all: $(IMG)

$(IMG): $(ELF)
	$(OBJCOPY) -O binary $(ELF) $(IMG)

$(ELF): $(OBJ)
	$(LD) $(LDFLAGS) -o $(ELF) $(OBJ)

$(OBJ): main.S
	$(AS) $(ASFLAGS) -o $(OBJ) main.S

# Limpiar archivos generados
clean:
	rm -f $(OBJ) $(ELF) $(IMG)