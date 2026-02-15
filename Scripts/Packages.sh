#!/bin/bash

# 安装和更新软件包
UPDATE_PACKAGE() {
    local PKG_NAME=$1
    local PKG_REPO=$2
    local PKG_BRANCH=$3
    local PKG_SPECIAL=$4
    local PKG_LIST=("$PKG_NAME" $5)  # 第5个参数：子目录(仅dir模式) + 自定义删除名称列表
    local REPO_NAME=${PKG_REPO#*/}

    echo "=================================================="
    echo "Processing package: $PKG_NAME"
    echo "=================================================="

    # 删除本地可能存在的同名/自定义名称软件包（精确匹配目录名，避免误删）
    for NAME in "${PKG_LIST[@]}"; do
        # 跳过空值（避免循环到空参数）
        if [ -z "$NAME" ]; then
            continue
        fi
        echo "Searching for directory to delete: $NAME"
        local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -name "$NAME" 2>/dev/null)

        # 删除找到的目录
        if [ -n "$FOUND_DIRS" ]; then
            while read -r DIR; do
                rm -rf "$DIR"
                echo "Deleted directory: $DIR"
            done <<< "$FOUND_DIRS"
        else
            echo "No directory found for deletion: $NAME"
        fi
    done

    # 克隆 GitHub 仓库到临时目录（避免仓库名冲突）
    local TMP_REPO_DIR="./tmp_$REPO_NAME"
    echo "Cloning repo: https://github.com/$PKG_REPO.git (branch: $PKG_BRANCH)"
    if ! git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git" "$TMP_REPO_DIR"; then
        echo "ERROR: Failed to clone repository $PKG_REPO"
        return 1
    fi

    # 根据不同模式处理克隆的仓库
    if [[ "$PKG_SPECIAL" == "pkg" ]]; then
        # 模式1：从大杂烩仓库中提取指定包名的目录
        echo "Extracting package directory matching: $PKG_NAME"
        find "$TMP_REPO_DIR"/*/ -maxdepth 3 -type d -name "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
        rm -rf "$TMP_REPO_DIR"
    elif [[ "$PKG_SPECIAL" == "name" ]]; then
        # 模式2：重命名仓库目录为指定包名
        echo "Renaming repo directory to: $PKG_NAME"
        mv -f "$TMP_REPO_DIR" "$PKG_NAME"
    elif [[ "$PKG_SPECIAL" == "dir" ]]; then
        # 模式3：提取仓库内指定子目录（PKG_LIST[1]为子目录路径，后续为删除列表）
        local SUB_DIR=${PKG_LIST[1]}
        if [ -z "$SUB_DIR" ] || [ ! -d "$TMP_REPO_DIR/$SUB_DIR" ]; then
            echo "ERROR: Subdirectory $SUB_DIR not found in repo $PKG_REPO"
            rm -rf "$TMP_REPO_DIR"
            return 1
        fi
        echo "Copying subdirectory: $TMP_REPO_DIR/$SUB_DIR -> current directory"
        cp -rf "$TMP_REPO_DIR/$SUB_DIR"/* ./
        rm -rf "$TMP_REPO_DIR"
    else
        # 默认模式：直接移动仓库目录为包名
        echo "Moving repo to current directory as: $PKG_NAME"
        mv -f "$TMP_REPO_DIR" "$PKG_NAME"
    fi

    echo "Package $PKG_NAME processed successfully!"
    echo ""
}

# 调用示例
# UPDATE_PACKAGE "OpenAppFilter" "destan19/OpenAppFilter" "master" "" "custom_name1 custom_name2"
# UPDATE_PACKAGE "open-app-filter" "destan19/OpenAppFilter" "master" "" "luci-app-appfilter oaf" 这样会把原有的open-app-filter，luci-app-appfilter，oaf相关组件删除，不会出现coremark错误。

# 主题类
UPDATE_PACKAGE "argon" "sbwml/luci-theme-argon" "openwrt-25.12" "" ""
UPDATE_PACKAGE "aurora" "eamonxg/luci-theme-aurora" "master" "" ""
UPDATE_PACKAGE "aurora-config" "eamonxg/luci-app-aurora-config" "master" "" ""
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "master" "" ""
UPDATE_PACKAGE "kucat-config" "sirpdboy/luci-app-kucat-config" "master" "" ""

# 代理类
UPDATE_PACKAGE "homeproxy" "VIKINGYFY/homeproxy" "main" "" ""
UPDATE_PACKAGE "momo" "nikkinikki-org/OpenWrt-momo" "main" "" ""
UPDATE_PACKAGE "nikki" "nikkinikki-org/OpenWrt-nikki" "main" "" ""
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg" ""
UPDATE_PACKAGE "passwall" "Openwrt-Passwall/openwrt-passwall" "main" "pkg" ""
UPDATE_PACKAGE "passwall2" "Openwrt-Passwall/openwrt-passwall2" "main" "pkg" ""

# 工具类
UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main" "" ""
UPDATE_PACKAGE "ddns-go" "sirpdboy/luci-app-ddns-go" "main" "" ""
UPDATE_PACKAGE "luci-app-lucky" "sirpdboy/luci-app-lucky" "main" "" ""
UPDATE_PACKAGE "lucky" "sirpdboy/luci-app-lucky" "main" "" ""
UPDATE_PACKAGE "diskman" "lisaac/luci-app-diskman" "master" "" ""
UPDATE_PACKAGE "easytier" "EasyTier/luci-app-easytier" "main" "" ""
UPDATE_PACKAGE "fancontrol" "rockjake/luci-app-fancontrol" "main" "" ""
UPDATE_PACKAGE "gecoosac" "lwb1978/openwrt-gecoosac" "main" "" ""
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5" "" "v2dat"
UPDATE_PACKAGE "netspeedtest" "sirpdboy/luci-app-netspeedtest" "master" "" "homebox speedtest"
UPDATE_PACKAGE "openlist2" "sbwml/luci-app-openlist2" "main" "" ""
UPDATE_PACKAGE "partexp" "sirpdboy/luci-app-partexp" "main" "" ""
UPDATE_PACKAGE "qbittorrent" "sbwml/luci-app-qbittorrent" "master" "" "qt6base qt6tools rblibtorrent"
UPDATE_PACKAGE "qmodem" "FUjr/QModem" "main" "" ""
UPDATE_PACKAGE "quickfile" "sbwml/luci-app-quickfile" "main" "" ""
UPDATE_PACKAGE "viking" "VIKINGYFY/packages" "main" "" "luci-app-timewol luci-app-wolplus"
UPDATE_PACKAGE "vnt" "lmq8267/luci-app-vnt" "main" "" ""

UPDATE_PACKAGE "rtp2httpd" "stackia/rtp2httpd" "main" "dir" "openwrt-support rtp2httpd luci-app-rtp2httpd"

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_MARK=${2:-false}
	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

	if [ -z "$PKG_FILES" ]; then
		echo "$PKG_NAME not found!"
		return
	fi

	echo -e "\n$PKG_NAME version update has started!"

	for PKG_FILE in $PKG_FILES; do
		local PKG_REPO=$(grep -Po "PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)" $PKG_FILE)
		local PKG_TAG=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease == $PKG_MARK)) | first | .tag_name")

		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")
		local OLD_URL=$(grep -Po "PKG_SOURCE_URL:=\K.*" "$PKG_FILE")
		local OLD_FILE=$(grep -Po "PKG_SOURCE:=\K.*" "$PKG_FILE")
		local OLD_HASH=$(grep -Po "PKG_HASH:=\K.*" "$PKG_FILE")

		local PKG_URL=$([[ "$OLD_URL" == *"releases"* ]] && echo "${OLD_URL%/}/$OLD_FILE" || echo "${OLD_URL%/}")

		local NEW_VER=$(echo $PKG_TAG | sed -E 's/[^0-9]+/\./g; s/^\.|\.$//g')
		local NEW_URL=$(echo $PKG_URL | sed "s/\$(PKG_VERSION)/$NEW_VER/g; s/\$(PKG_NAME)/$PKG_NAME/g")
		local NEW_HASH=$(curl -sL "$NEW_URL" | sha256sum | cut -d ' ' -f 1)

		echo "old version: $OLD_VER $OLD_HASH"
		echo "new version: $NEW_VER $NEW_HASH"

		if [[ "$NEW_VER" =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
			echo "$PKG_FILE version has been updated!"
		else
			echo "$PKG_FILE version is already the latest!"
		fi
	done
}

#UPDATE_VERSION "软件包名" "测试版，true，可选，默认为否"
UPDATE_VERSION "sing-box"
#UPDATE_VERSION "tailscale"
