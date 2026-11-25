#!/bin/bash
# === Claude origin ===
# Created/placed by Anthropic Claude Code at: 2026-11-25-202000
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 lz-editor-macos-patch contributors
#
# LZ Editor を fresh clone → 固定 commit を checkout → 本リポジトリのパッチを適用 → テスト → ビルドし、
# build/LZ Editor.app を作る (/Applications へのコピーはしない)。途中で失敗したら停止する。
#
# 署名: 環境変数 LZ_SIGN_IDENTITY に証明書名を渡すとその証明書、無ければ ad-hoc
# 動作環境: macOS, git, Rust (cargo), Xcode Command Line Tools
# ====================
set -euo pipefail

UPSTREAM_URL=https://github.com/TouryuTamane/lz-editor.git
UPSTREAM_COMMIT=adab5d2b9cf97fb468be8c7661bcca8fd0c246c4

cd "$(dirname "${BASH_SOURCE[0]}")/.."

rm -rf build
mkdir build
git clone --quiet "$UPSTREAM_URL" build/lz-editor
git -C build/lz-editor checkout --quiet "$UPSTREAM_COMMIT"

for patch in lz-font-set.patch lz-macos-app.patch; do
    echo "Applying: $patch"
    git -C build/lz-editor apply --whitespace=nowarn "../../$patch"
done

(cd build/lz-editor && cargo test --locked && cargo build --release --locked)

VERSION=$(sed -n 's/^version = "\(.*\)"/\1/p' build/lz-editor/Cargo.toml | head -1)
mkdir -p "build/LZ Editor.app/Contents/MacOS" "build/LZ Editor.app/Contents/Resources"
cp build/lz-editor/target/release/lz "build/LZ Editor.app/Contents/MacOS/lz"
cp macos/lz-editor.icns "build/LZ Editor.app/Contents/Resources/lz-editor.icns"
cp LICENSE "build/LZ Editor.app/Contents/Resources/LICENSE"
sed "s/@VERSION@/$VERSION/g" macos/Info.plist.in > "build/LZ Editor.app/Contents/Info.plist"
plutil -lint "build/LZ Editor.app/Contents/Info.plist" >/dev/null

codesign --force --sign "${LZ_SIGN_IDENTITY:--}" "build/LZ Editor.app"
codesign --verify --strict "build/LZ Editor.app"
echo "OK: build/LZ Editor.app ($VERSION)"
