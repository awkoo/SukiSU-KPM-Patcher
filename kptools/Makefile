# ======================
# 工具链配置
# ======================
TARGET = kptools
TARGET_COMPILE ?= 
CC = $(TARGET_COMPILE)gcc

# ======================
# 编译选项
# ======================
CFLAGS = -std=c11 -Wall -Wextra -Wno-unused -Wno-unused-parameter
LDFLAGS = -static -lz

ifdef DEBUG
CFLAGS += -DDEBUG -g
endif

# ======================
# 源文件集合
# ======================
SRCS := image.c kallsym.c kptools.c order.c insn.c patch.c symbol.c kpm.c common.c sha256.c
OBJS = $(SRCS:.c=.o)

# ======================
# 构建目标
# ======================
.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o : %.c
	$(CC) -c $(CFLAGS) $< -o $@

# ======================
# 清理
# ======================
clean:
	rm -f $(TARGET) $(OBJS)