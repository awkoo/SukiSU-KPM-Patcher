# ======================
# 全局配置
# ======================
TARGET_COMPILE ?= 

CC             = $(TARGET_COMPILE)gcc
CXX            = $(TARGET_COMPILE)g++
CXXFLAGS       = -Iinclude
OPTIMIZE       = -O3

# ======================
# 目录结构
# ======================
ENCRYPT_BIN    = encrypt
KPIMG_ENC      = kpimg.enc
KPIMG_HEADER   = include/kpimg_enc.h
KPTOOLS_HEADER     = include/kptools.h
PATCHER_BIN    = patcher

# ======================
# 伪目标声明
# ======================
.PHONY: all clean kpimg kptools generate_headers

# ======================
# 主构建目标
# ======================
all: $(PATCHER_BIN)

# ======================
# 子项目构建
# ======================
kpimg:
	@$(MAKE) -C kpimg/

kptools:
	@$(MAKE) -C kptools/ TARGET_COMPILE="$(TARGET_COMPILE)"

# ======================
# 加密工具和加密镜像
# ======================
$(ENCRYPT_BIN): encrypt.cpp
	$(CXX) $(OPTIMIZE) $(CXXFLAGS) -o $@

$(KPIMG_ENC): $(ENCRYPT_BIN) kpimg
	./$< kpimg/kpimg $@

# ======================
# 头文件生成
# ======================
$(KPIMG_HEADER): $(KPIMG_ENC) | include
	xxd -i $< > $@

$(KPTOOLS_HEADER): kptools | include
	xxd -i kptools/kptools > $@

generate_headers: $(KPIMG_HEADER) $(KPTOOLS_HEADER)

# ======================
# 主程序构建
# ======================
$(PATCHER_BIN): main.cpp generate_headers
	$(CXX) $(CXXFLAGS) $< -o $@

# ======================
# 目录创建规则
# ======================
  include:
	@mkdir -p $@

# ======================
# 清理规则
# ======================
clean:
	rm -rf encrypt patcher kpimg.enc include/
	@$(MAKE) -C kpimg/ clean
	@$(MAKE) -C kptools/ clean