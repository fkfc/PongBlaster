#PROJETO = $(shell basename $(CURDIR))
PROJETO = pongblas
EXE_FILE = $(PROJETO).com

CC = sdcc
ASM = sdasz80

#Dirs
SRC_DIR = src
BUILD_DIR = build
OUTPUT_DIR = bin


#Entrada
C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.s)

OBJ_C_FILES = $(addprefix $(BUILD_DIR)/,$(notdir $(C_FILES:.c=.c.rel)))
OBJ_ASM_FILES = $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_FILES:.s=.asm.rel)))
OBJ_FILES = $(OBJ_C_FILES) $(OBJ_ASM_FILES)

#Paths de libs / includes
#avelino
AVELINO_PATH = ext/avelino
AVELINO_LIB_PATH = $(AVELINO_PATH)/lib
AVELINO_SRC_PATH = $(AVELINO_PATH)/src
AVELINO_INCLUDE_PATH = $(AVELINO_PATH)/include
AVELINO_SRC_C_FILES = $(wildcard $(AVELINO_SRC_PATH)/*.c)
AVELINO_SRC_ASM_FILES = $(wildcard $(AVELINO_SRC_PATH)/*.s) 
AVELINO_OBJ_C_FILES = $(addprefix $(AVELINO_LIB_PATH)/,$(notdir $(AVELINO_SRC_C_FILES:.c=.c.rel)))
AVELINO_OBJ_ASM_FILES = $(addprefix $(AVELINO_LIB_PATH)/,$(notdir $(AVELINO_SRC_ASM_FILES:.s=.asm.rel)))
AVELINO_OBJ_FILES = $(AVELINO_OBJ_C_FILES) $(AVELINO_OBJ_ASM_FILES)

#solidc
SOLIDC_PATH = ext/solidc
SOLIDC_LIB_PATH = $(SOLIDC_PATH)/lib
SOLIDC_SRC_PATH = $(SOLIDC_PATH)/src
SOLIDC_INCLUDE_PATH = $(SOLIDC_PATH)/include
SOLIDC_SRC_C_FILES = $(wildcard $(SOLIDC_SRC_PATH)/*.c)
SOLIDC_SRC_ASM_FILES = $(wildcard $(SOLIDC_SRC_PATH)/*.s) 
SOLIDC_OBJ_C_FILES = $(addprefix $(SOLIDC_LIB_PATH)/,$(notdir $(SOLIDC_SRC_C_FILES:.c=.c.rel)))
SOLIDC_OBJ_ASM_FILES = $(addprefix $(SOLIDC_LIB_PATH)/,$(notdir $(SOLIDC_SRC_ASM_FILES:.s=.asm.rel)))
SOLIDC_OBJ_FILES = $(SOLIDC_OBJ_C_FILES) $(SOLIDC_OBJ_ASM_FILES)


#MSX-DOS com argumentos de linha de comando
MSXDOS_CRT = crt0msx_msxdos_advanced.asm.rel
CODE_LOC_ADDR = 0x0178

#MSX-DOS simples
#MSXDOS_CRT = crt0msx_msxdos.asm.rel
#CODE_LOC_ADDR = 0x0107




#Parametros
AVELINO_LIBS = $(AVELINO_LIB_PATH)/$(MSXDOS_CRT) $(AVELINO_LIB_PATH)/putchar.asm.rel $(AVELINO_LIB_PATH)/getchar.asm.rel $(AVELINO_LIB_PATH)/dos2.asm.rel $(AVELINO_LIB_PATH)/conio.c.rel $(AVELINO_LIB_PATH)/ioport.asm.rel

SOLIDC_LIBS = $(SOLIDC_LIB_PATH)/VDPgraph2.asm.rel

INCLUDE_PATHS = $(AVELINO_INCLUDE_PATH) $(SOLIDC_INCLUDE_PATH)




.PHONY: clean

all: $(PROJETO)

$(PROJETO): $(OUTPUT_DIR)/$(EXE_FILE)


$(OUTPUT_DIR)/$(EXE_FILE): $(BUILD_DIR)/$(PROJETO).ihx
	hex2bin $^
	mv $(BUILD_DIR)/$(PROJETO).bin $@

$(BUILD_DIR)/$(PROJETO).ihx: avelino solidc $(OBJ_C_FILES) $(OBJ_ASM_FILES)
	$(CC) -mz80 --code-loc $(CODE_LOC_ADDR) --data-loc 0 --no-std-crt0 $(addprefix -I ,$(INCLUDE_PATHS)) $(AVELINO_LIBS) $(SOLIDC_LIBS) $(OBJ_FILES) -o $@
	

$(BUILD_DIR)/%.c.rel: $(SRC_DIR)/%.c
	$(CC) -mz80 -c $(addprefix -I ,$(INCLUDE_PATHS)) $< -o $@

$(BUILD_DIR)/%.asm.rel: $(SRC_DIR)/%.s
	$(ASM) -o $@ $<

$(PROJETO)-clean:
	rm -f $(OUTPUT_DIR)/$(EXE_FILE)
	rm -f $(OBJ_FILES)
	rm -f $(BUILD_DIR)/$(PROJETO).lk
	rm -f $(BUILD_DIR)/$(PROJETO).ihx
	rm -f $(BUILD_DIR)/$(PROJETO).map
	rm -f $(BUILD_DIR)/$(PROJETO).noi
	rm -f $(BUILD_DIR)/*.asm
	rm -f $(BUILD_DIR)/*.lst
	rm -f $(BUILD_DIR)/*.sym
	


avelino: $(AVELINO_OBJ_C_FILES) $(AVELINO_OBJ_ASM_FILES)

$(AVELINO_LIB_PATH)/%.asm.rel: $(AVELINO_SRC_PATH)/%.s
	$(ASM) -o $@ $<

$(AVELINO_LIB_PATH)/%.c.rel: $(AVELINO_SRC_PATH)/%.c
	$(CC) -mz80 -c $< -o $@ 
	
	
avelino-clean:
	rm -f $(AVELINO_LIB_PATH)/*

	
	
	
solidc: $(SOLIDC_OBJ_C_FILES) $(SOLIDC_OBJ_ASM_FILES)

$(SOLIDC_LIB_PATH)/%.asm.rel: $(SOLIDC_SRC_PATH)/%.s
	$(ASM) -o $@ $<

$(SOLIDC_LIB_PATH)/%.c.rel: $(SOLIDC_SRC_PATH)/%.c
	$(CC) -mz80 -c $< -o $@
	
	
solidc-clean:
	rm -f $(SOLIDC_LIB_PATH)/*


clean: $(PROJETO)-clean avelino-clean solidc-clean

run: 
	openmsx -machine MSX2TR_Felipe  -diska aux/msx/dos2/MSXDOS2E.DSK -diskb ./$(OUTPUT_DIR)/

	