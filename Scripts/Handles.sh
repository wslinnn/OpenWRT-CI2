#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修改argon主题字体和颜色
if [ -d "$PACKAGE_PATH/luci-theme-argon" ]; then
	echo " "
	if sed -i "s/primary '.*'/primary '#31a1a1'/g; s/'0.2'/'0.5'/g; s/'none'/'bing'/g; s/'600'/'normal'/g" \
		"$PACKAGE_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"; then
		echo "theme-argon has been fixed!"
	else
		echo "theme-argon fix failed; continuing!"
	fi
fi

#修改aurora菜单式样
if [ -d "$PACKAGE_PATH/luci-app-aurora-config" ]; then
	echo " "
	if find "$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec \
		sed -i "s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +; then
		echo "theme-aurora has been fixed!"
	else
		echo "theme-aurora fix failed; continuing!"
	fi
fi

#修改mini-diskmanager菜单位置
if [ -d "$PACKAGE_PATH/luci-app-mini-diskmanager" ]; then
	echo " "
	if sed -i "s/services/system/g" \
		"$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"; then
		echo "mini-diskmanager has been fixed!"
	else
		echo "mini-diskmanager fix failed; continuing!"
	fi
fi

#修改natmapt菜单位置
if [ -d "$PACKAGE_PATH/luci-app-natmapt" ]; then
	echo " "
	if sed -i "s/network/services/g" \
		"$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json"; then
		echo "natmapt has been fixed!"
	else
		echo "natmapt fix failed; continuing!"
	fi
fi

#修复QModem依赖循环
if [ -d "$PACKAGE_PATH/QModem" ]; then
	echo " "
	if sed -i 's/@!PACKAGE_luci-app-qmodem //g; s/+luci-app-qmodem-next/luci-app-qmodem-next/g' \
		"$PACKAGE_PATH/QModem/luci/luci-app-qmodem-next/Makefile"; then
		echo "QModem has been fixed!"
	else
		echo "QModem fix failed; continuing!"
	fi
fi

#修复Rust编译失败
if [ -d "$FEEDS_PATH/packages/lang/rust" ]; then
	echo " "
	if sed -i 's/ci-llvm=true/ci-llvm=false/g' \
		"$FEEDS_PATH/packages/lang/rust/Makefile"; then
		echo "rust has been fixed!"
	else
		echo "rust fix failed; continuing!"
	fi
fi

#去掉dae/daed默认的v2ray-geoip、v2ray-geosite依赖，节省闪存空间
#（内置dat约7MB，装完本来就要换成新文件；LuCI里用update-geo.sh在线下载即可）
if [ -f "$PACKAGE_PATH/openwrt-daede/daed/Makefile" ]; then
	echo " "
	if sed -i 's/ +v2ray-geoip//g; s/ +v2ray-geosite//g' \
		"$PACKAGE_PATH/openwrt-daede/dae/Makefile" \
		"$PACKAGE_PATH/openwrt-daede/daed/Makefile"; then
		echo "daede geoip/geosite deps have been removed!"
	else
		echo "daede geoip/geosite fix failed; continuing!"
	fi
fi
