TARGET=stm32
########################################################################
export CC             = arm-none-eabi-gcc
export AS             = arm-none-eabi-as
export LD             = arm-none-eabi-ld
export OBJCOPY            = arm-none-eabi-objcopy

DEBUG_FLAGS= -O0 -g
COMMONFLAGS=-mcpu=cortex-m3 -mthumb -march=armv7-m 
COMMONFLAGSlib=$(COMMONFLAGS)
TOP=$(shell pwd)
OUT_DIR=$(TOP)/out


LIBDIR=$(TOP)/libs
#================================根据你的lib,config the lib here, you can read the note in yinxiang bi ji stm32标准外设库使用详解===================
#cmsis:
INC_FLAGS+= -I $(TOP)/libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries/CMSIS/CM3/CoreSupport/
C_SRC+= $(TOP)/libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries/CMSIS/CM3/CoreSupport/core_cm3.c
INC_FLAGS+= -I $(TOP)/libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x
C_SRC+= $(TOP)/libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/system_stm32f10x.c

#soc driver:
INC_FLAGS+= -I $(TOP)/libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries/STM32F10x_StdPeriph_Driver/inc
PERIPH_SRC_PATH=$(TOP)/libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries/STM32F10x_StdPeriph_Driver/src
#C_SRC+= $(shell find  $(TOP)/libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries/STM32F10x_StdPeriph_Driver/src -name '*.c')
C_SRC+= $(PERIPH_SRC_PATH)/stm32f10x_rcc.c
C_SRC+= $(PERIPH_SRC_PATH)/stm32f10x_gpio.c
C_SRC+= $(PERIPH_SRC_PATH)/stm32f10x_usart.c
C_SRC+= $(PERIPH_SRC_PATH)/misc.c
CFLAGS+= -D USE_STDPERIPH_DRIVER

#=========add by embbnux  根据你的stm32芯片型号容量不同,修改这个地方的TypeOfMCU=======#
#see CMSIS file "stm32f10x.h" ,search STM32F10X_MD ...
CFLAGS+= -D STM32F10X_MD
ASM_SRC+= $(TOP)/libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Libraries/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/arm/startup_stm32f10x_md.s
#=========== ld file 
#MY_LD_FILE_NAME=stm32f103rbt6.ld
MY_LD_FILE_NAME=libs/STSW-STM32054/STM32F10x_StdPeriph_Lib_V3.5.0/Project/STM32F10x_StdPeriph_Template/TrueSTUDIO/STM3210B-EVAL/stm32_flash.ld
#======================================================================

#my src
INC_FLAGS+= -I $(TOP)/src    
C_SRC+= $(shell find $(TOP)/src -name '*.c')


CFLAGS+=$(COMMONFLAGS) -W -Wall $(INC_FLAGS) -fno-common -fno-builtin -ffreestanding
CFLAGS+= -nostdlib
CFLAGS+= $(DEBUG_FLAGS)
CFLAGS+= -Wl,--whole-archive

#LDFLAGS=$(COMMONFLAGS) ${DEBUG_FLAGS} -nostartfiles -L$(LIBDIR) -nostartfiles -Wl,--gc-sections,-T$(MY_LD_FILE_NAME)
#LDLIBS+= -lm -lc

LDFLAGS+=${DEBUG_FLAGS}
LDFLAGS+= -nostartfiles -T $(MY_LD_FILE_NAME)


#CFLAGS+=-D VECT_TAB_FLASH
#CFLAGSlib+=-c
#CFLAGS+=-lc




########################################################################
#C_SRC=$(shell find ./ -name '*.c')
C_OBJ=$(C_SRC:%.c=%.o)
C_DEP=$(C_SRC:%.c=%.cdep)

#ASM_SRC=$(shell find ./ -name '*.s')
ASM_OBJ=$(ASM_SRC:%.s=%.o)
ASM_DEP=$(ASM_SRC:%.s=%.adep)

########################################################################
.PHONY: all clean
all:$(C_DEP) $(ASM_DEP) $(C_OBJ) $(ASM_OBJ)
	@for i in $(shell find $(OUT_DIR) -name '*.*');do if [ -e $${i} ];then rm $${i};fi;done
	$(CC) $(C_OBJ) $(ASM_OBJ) -o $(OUT_DIR)/$(TARGET).elf $(LDFLAGS)
	$(OBJCOPY) $(OUT_DIR)/$(TARGET).elf  $(OUT_DIR)/$(TARGET).bin -Obinary 
	$(OBJCOPY) $(OUT_DIR)/$(TARGET).elf  $(OUT_DIR)/$(TARGET).hex -Oihex
###################################
%.cdep:%.c
	$(CC) -MM $< > $@ $(CFLAGS)
sinclude $(C_DEP)
$(C_OBJ):%.o:%.c
	$(CC) -c $< -o $@ $(CFLAGS)
####################################
%.adep:%.s
	$(CC) -MM $< > $@ $(ASFLAGS)
sinclude $(ASM_DEP)
$(ASM_OBJ):%.o:%.s
	$(AS) -c $@ -o $@ $(ASFLAGS)
####################################    
clean:
	@for i in $(shell find ./ -name '*.o');do if [ -e $${i} ];then rm $${i};fi;done
	@for i in $(shell find ./ -name '*.cdep');do if [ -e $${i} ];then rm $${i};fi;done
	@for i in $(shell find ./ -name '*.adep');do if [ -e $${i} ];then rm $${i};fi;done
