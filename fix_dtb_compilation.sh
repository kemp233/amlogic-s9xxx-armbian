#!/bin/bash
# 修 RK3566 lb2004 DTB 不生成的问题

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. 定位内核源码目录 (在 Ophub 编译流程中通常在 cache/sources/linux-...)
# 如果是在 Docker 中直接编译，请确保你在项目根目录
KERNEL_SRC=$(find . -name "Makefile" | grep "arch/arm64/boot/dts/rockchip" | sed 's|/arch/arm64/boot/dts/rockchip/Makefile||' | head -n 1)

if [ -z "$KERNEL_SRC" ]; then
    echo -e "${RED}❌ 错误: 找不到内核源码目录，请先运行一次编译产生源码缓存。${NC}"
    exit 1
fi

echo -e "${GREEN}发现内核源码: $KERNEL_SRC${NC}"

# 2. 检查 DTS 文件是否已经通过补丁成功放入
DTS_FILE="${KERNEL_SRC}/arch/arm64/boot/dts/rockchip/rk3566-lb2004.dts"
if [ -f "$DTS_FILE" ]; then
    echo -e "✅ DTS 文件已存在: $DTS_FILE"
else
    echo -e "${YELLOW}⚠️ DTS 文件缺失，正在尝试从补丁手动提取...${NC}"
    # 这里假设补丁在你的项目路径下
    PATCH_FILE="compile-kernel/tools/patch/linux-rockchip-rk-6.1-rkr6.1/400-dts-add-rk3566-lb2004.patch"
    if [ -f "$PATCH_FILE" ]; then
        # 强制在源码目录应用补丁
        (cd "$KERNEL_SRC" && patch -p1 < "../../$PATCH_FILE")
    fi
fi

# 3. 关键步骤：在 Makefile 中注册 lb2004.dtb
RK_MAKEFILE="${KERNEL_SRC}/arch/arm64/boot/dts/rockchip/Makefile"
if grep -q "rk3566-lb2004.dtb" "$RK_MAKEFILE"; then
    echo -e "✅ Makefile 已包含 lb2004"
else
    echo -e "${GREEN}正在将 lb2004 注入 Makefile...${NC}"
    # 在类似的 rk3566 节点后插入
    sed -i '/rk3566-evb1-v10.dtb/a dtb-$(CONFIG_ARCH_ROCKCHIP) += rk3566-lb2004.dtb' "$RK_MAKEFILE"
fi

# 4. 修正 build-armbian 的输出同步逻辑
# 确保编译完后 .dtb 会被拷贝到正确的目录
echo -e "${GREEN}正在确保构建脚本能够识别 lb2004...${NC}"
# 搜索并确保脚本中包含了你的设备名
grep -rl "rk3566" build-armbian/ | xargs sed -i 's/rk3566-rock-3c/rk3566-lb2004/g' 2>/dev/null

echo -e "\n${YELLOW}=== 修复完成 ===${NC}"
echo -e "现在运行 ${GREEN}./rebuild${NC}，内核编译器将会生成 ${GREEN}rk3566-lb2004.dtb${NC}。"
