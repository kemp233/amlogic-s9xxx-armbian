#!/bin/bash
# 修正仓库模板中的引导路径，确保 lb2004 顺利启动

BUILD_DIR="./build-armbian"

echo "正在修正引导模板路径..."

# 1. 修正 armbianEnv.txt 模板
# 关键：fdtfile 必须包含 rockchip/ 前缀
ENV_FILE="${BUILD_DIR}/armbian-files/platform-files/rockchip/bootfs/armbianEnv.txt"
if [ -f "$ENV_FILE" ]; then
    sed -i 's|^fdtfile=.*|fdtfile=rockchip/rk3566-lb2004.dtb|g' "$ENV_FILE"
    echo "✅ 已修正 armbianEnv.txt 中的 fdtfile 变量"
fi

# 2. 修正 extlinux.conf 模板
# 关键：FDT 路径必须是 /dtb/rockchip/rk3566-lb2004.dtb
EXT_FILE="${BUILD_DIR}/armbian-files/platform-files/rockchip/bootfs/extlinux/extlinux.conf"
if [ ! -f "$EXT_FILE" ]; then
    # 如果正式文件不存在，尝试修正 .bak 文件
    EXT_FILE="${BUILD_DIR}/armbian-files/platform-files/rockchip/bootfs/extlinux/extlinux.conf.bak"
fi

if [ -f "$EXT_FILE" ]; then
    # 统一替换逻辑，防止/dtb/rk3566 或 /dtb/rockchip/rockchip
    # 先把路径全部重置为正确格式
    sed -i 's|FDT /dtb/.*|FDT /dtb/rockchip/rk3566-lb2004.dtb|g' "$EXT_FILE"
    echo "✅ 已修正 extlinux 模板中的 FDT 绝对路径"
fi

# 3. 检查是否有错误的 Amlogic 引用
# 你的 Commit a74a981 修改了 Amlogic 目录下的安装脚本，这其实对 Rockchip 启动没帮助
# 我们需要确保 rockchip 专属目录下的脚本是对的
RK_INSTALL="${BUILD_DIR}/armbian-files/platform-files/rockchip/rootfs/usr/sbin/armbian-install"
if [ -f "$RK_INSTALL" ]; then
    sed -i 's|FDTFILE=.*|FDTFILE="rockchip/rk3566-lb2004.dtb"|g' "$RK_INSTALL"
    echo "✅ 已修正 rockchip "
fi

echo "修正完成！请执行以下命令提交并 Push:"
echo "git add ."
echo "git commit -m 'Fix: absolute DTB paths for lb2004'"
echo "git push"
