# ======================
# 工具链配置
# ======================
TARGET = kpimg
TARGET_COMPILE = aarch64-linux-gnu-
CC  = $(TARGET_COMPILE)gcc
LD  = $(TARGET_COMPILE)ld
AS  = $(TARGET_COMPILE)as
OBJCOPY = $(TARGET_COMPILE)objcopy

# ======================
# 编译选项
# ======================
CFLAGS += -Wall -fno-builtin -nostdinc -g
CFLAGS += -Wno-unused-function
CFLAGS += -fno-PIC -fno-stack-protector -fno-common
CFLAGS += -U_FORTIFY_SOURCE -fno-asynchronous-unwind-tables
CFLAGS += -fno-unwind-tables -fno-semantic-interposition

ifdef DEBUG
CFLAGS += -DDEBUG -DMAP_DEBUG
endif

CFLAGS += -DANDROID

# ======================
# 包含路径
# ======================
INCLUDE := -I. -Iinclude -Ipatch/include -Ilinux 
INCLUDE += -Ilinux/include -Ilinux/arch/arm64/include 
INCLUDE += -Ilinux/tools/arch/arm64/include -Ikernel-source

# ======================
# 源文件集合
# ======================
BASE_SRCS := $(wildcard base/*.c base/*.S)
BASE_SRCS += $(wildcard patch/*.c patch/common/*.c patch/module/*.c)
BASE_SRCS += $(wildcard patch/ksyms/*.c patch/sukisu/*.c)
BASE_SRCS += patch/android/sepolicy_flags.c

SRCS = $(BASE_SRCS)
OBJS = $(patsubst %.c,%.o,$(patsubst %.S,%.o,$(SRCS)))

# ======================
# 链接选项
# ======================
LDFLAGS += -Tkpimg.lds --no-relax -nostdlib -static -no-pie

# ======================
# 构建目标
# ======================
all: $(TARGET)

$(TARGET): $(TARGET).elf
	@$(OBJCOPY) -O binary -S $^ $@

$(TARGET).elf: $(OBJS)
	@$(LD) $(LDFLAGS) -e start -o $@ $^

%.o: %.c
	@$(CC) $(CFLAGS) $(INCLUDE) -c -O2 -o $@ $<

%.o: %.S
	@$(CC) $(CFLAGS) $(INCLUDE) -c -o $@ $<

# ======================
# 清理
# ======================
.PHONY: clean
clean:
	rm -f *.elf $(TARGET)
	find . -name '*.o' -exec rm -f {} +