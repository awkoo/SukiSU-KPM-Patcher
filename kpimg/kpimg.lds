ENTRY(start)
OUTPUT_ARCH(aarch64)

/* 定义基础地址和内存布局 */
_link_base = 64k - 3 * 4k;

/* 显式定义段权限 */
PHDRS {
    text PT_LOAD FLAGS(5); /* R-X (0x1 | 0x4) */
    data PT_LOAD FLAGS(6); /* RW- (0x2 | 0x4) */
    rodata PT_LOAD FLAGS(4); /* R-- (0x4) */
}

SECTIONS 
{
    /* 丢弃不需要的段 */
    /DISCARD/ : { 
        *(.discard) 
        *(.discard.*)
        *(.interp .dynamic)
        *(.dynsym .dynstr .hash .gnu.hash)
    }
    
    . = _link_base;
    _link_base = .;

    /* 设置段：包含初始化和预设数据 */
    .setup.data : {
        _setup_start = .;
        base/setup.o(.setup.header)
        . = _setup_start + 64;
        base/setup.o(.setup.preset)
        base/setup.o(.setup.data)
        . = _setup_start + 4K;
    } :rodata

    /* 设置代码段 */
    .setup.text : {
        base/setup1.o(.entry.text)
        base/setup1.o(.text)
        base/setup.o(.text)
        _setup_end = .;
    } :text

    . = ALIGN(16);
    
    /* 内存映射处理段 */
    .setup.map : {
        _map_start = .;
        base/map.o(.map.data)
        base/map.o(.map.text)
        base/map.o(.text)
        base/map1.o(.text)
        . = ALIGN(16);
        _map_end = .;
    } :text
    
    /* 确保映射段不会过大 */
    ASSERT(SIZEOF(.setup.map) < 0xa00, "Size too large of .setup.map!")

    /* ================ 内核补丁主区域 ================ */
    . = ALIGN(64K);
    _kp_start = .;
    
    /* 内核补丁代码段 (只读可执行) */
    .kp.text : {
        _kp_text_start = .;

        base/start.o(.start.text)
        base/start.o(.text)
        
        /* Hook 跳转代码 */
        base/hook.o(.transit0.text);
        _transit0_end = .;
        base/hook.o(.transit4.text);
        _transit4_end = .;
        base/hook.o(.transit8.text);
        _transit8_end = .;
        base/hook.o(.transit12.text);
        _transit12_end = .;

        /* FP Hook 跳转代码 */
        base/fphook.o(.fp.transit0.text);
        _fp_transit0_end = .;
        base/fphook.o(.fp.transit4.text);
        _fp_transit4_end = .;
        base/fphook.o(.fp.transit8.text);
        _fp_transit8_end = .;
        base/fphook.o(.fp.transit12.text);
        _fp_transit12_end = .;

        /* 主代码区域 */
        base/*(.text .text.*)
        base/*(.rodata .rodata.*)
        *(.text .text.*)
        *(.rodata .rodata.*)

        . = ALIGN(16);
        _kp_text_end = .;
    } :text

    /* 内核补丁数据段 (读写) */
    . = ALIGN(64K);
    .kp.data : {
        _kp_data_start = .;
        base/start.o(.start.data)
        base/*(.data .data.*)
        base/*(.bss .bss.*)
        *(.data .data.*)
        *(.bss .bss.*)
        
        . = ALIGN(16);
        _kp_symbol_start = .;
        *(.kp.symbol)
        _kp_symbol_end = .;
        
        _kp_data_end = .;
    } :data

    /* ================ 完整性检查 ================ */
    .got.plt : { *(.got.plt) } :text
    ASSERT(SIZEOF(.got.plt) == 0, "Unexpected GOT/PLT entries detected!")

    .got : { *(.got) } :text
    ASSERT(SIZEOF(.got) == 0, "Unexpected GOT detected!")
    
    .plt : {
        *(.plt) *(.plt.*) *(.iplt) *(.igot .igot.plt)
    } :text
    ASSERT(SIZEOF(.plt) == 0, "Unexpected run-time procedure linkages detected!")

    .data.rel.ro : { *(.data.rel.ro) } :data
    ASSERT(SIZEOF(.data.rel.ro) == 0, "Unexpected RELRO detected!")
    
    .rela.dyn : {
        *(.rela .rela*)
    } :text
    ASSERT(SIZEOF(.rela.dyn) == 0, "Unexpected RELRDYN detected!")

    /* ================ 结束区域 ================ */
    . = ALIGN(64k);
    _kp_end = .;
    _link_end = .;

    /* 输出段大小信息便于调试 */
    _kp_text_size = _kp_text_end - _kp_text_start;
    _kp_data_size = _kp_data_end - _kp_data_start;
    _total_size = _link_end - _link_base;
}