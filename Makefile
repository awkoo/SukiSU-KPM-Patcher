# ======================
# 全局配置
# ======================
TARGET         := sukisu-kpm-patcher
TARGET_COMPILE ?=

HOSTCXX        := g++
TARGETCXX      := $(TARGET_COMPILE)g++
OPTIMIZE       = -O3
LDFLAGS        = -static -static-libgcc -static-libstdc++

# ======================
# 伪目标声明
# ======================
.PHONY: all clean kpimg kptools generate_headers

# ======================
# 主构建目标
# ======================
all: $(TARGET)

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
encrypter: encrypt.cpp
	@$(HOSTCXX) $(CXXFLAGS) -o $@ $<

kpimg.enc: encrypter kpimg
	@./$< kpimg/kpimg $@

# ======================
# 头文件生成
# ======================
kpimg_enc.h: kpimg.enc
	@xxd -i $< > $@

kptools.h: kptools
	@xxd -i kptools/kptools > $@

generate_headers: kpimg_enc.h kptools.h

# ======================
# 主程序构建
# ======================
$(TARGET): main.cpp generate_headers
	@$(TARGETCXX) $(CXXFLAGS) $< -o $@ $(LDFLAGS)

# ======================
# 清理规则
# ======================
clean:
	@rm -f $(TARGET) encrypter kpimg.enc kpimg_enc.h kptools.h
	@$(MAKE) -C kpimg/ clean
	@$(MAKE) -C kptools/ clean