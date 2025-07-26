# ======================
# 工具链配置
# ======================
TARGET := kptools
TARGET_COMPILE ?= 
CC := $(TARGET_COMPILE)gcc

# ======================
# 编译选项
# ======================
CFLAGS = -Izlib/ -Wall -Wextra -Wno-unused -Wno-unused-parameter
LDFLAGS = -Lzlib/ -static -lz -static-libgcc -static-libstdc++

ifdef DEBUG
CFLAGS += -DDEBUG -g
endif

# ======================
# 源文件集合
# ======================
SRCS := $(wildcard *.c)
OBJS = $(SRCS:.c=.o)

# ======================
# 构建目标
# ======================
.PHONY: all zlib clean

all: zlib $(TARGET)

zlib:
	@cd zlib && CROSS_PREFIX=$(TARGET_COMPILE) ./configure
	@$(MAKE) -C zlib/

$(TARGET): $(OBJS)
	@$(CC) -o $@ $^ $(LDFLAGS)

%.o : %.c
	@$(CC) -c $(CFLAGS) $< -o $@

# ======================
# 清理
# ======================
clean:
	@rm -f $(TARGET) $(OBJS)
	@$(MAKE) -C zlib/ -f Makefile.in clean