# lz-editor-macos-patch

**macOS 向けの** [LZ Editor](https://github.com/TouryuTamane/lz-editor) 非公式パッチ。LZ Editor は Touryu Tamane 氏による VZ Editor 風のテキストエディタ兼 2 画面ファイラー（Rust + egui、Linux 向け）。本リポジトリは原作者とは無関係で、パッチは [Claude Code](https://claude.com/claude-code) で作成した。

LZ Editor 本体は macOS でも無改造でビルド・起動できる。本パッチは次の 2 点を補う。

1. **フォントセットの選択** — 英数字と日本語のフォントの組を画面から選び、保存する
2. **macOS アプリ化** — `.app` として Finder から起動できるようにする

## ファイル

| ファイル | 内容 |
|---|---|
| `lz-font-set.patch` | フォント設定画面（`Ctrl+K Ctrl+F`）と設定の保存。Finder から起動した時に日本語が「□」になる問題も解消 |
| `lz-macos-app.patch` | `.app` 起動時の初期フォルダをホームにし、Dock アイコンをバンドルの `.icns` に任せる |
| `macos/Info.plist.in`, `macos/lz-editor.icns` | アプリバンドルの材料（アイコンは本家の `assets/lz-editor.svg` から変換） |
| `scripts/build_macos.sh` | fresh clone → パッチ適用 → テスト → ビルド → `build/LZ Editor.app` 作成 |

2 つのパッチは互いに独立しており、片方だけでも適用できる。

## 適用手順

Rust（`cargo`）と Xcode Command Line Tools が入っていれば:

```sh
git clone https://github.com/soresore19xx/lz-editor-macos-patch.git
cd lz-editor-macos-patch
bash scripts/build_macos.sh
cp -R "build/LZ Editor.app" /Applications/
```

署名は既定で ad-hoc。手元の証明書を使うなら `LZ_SIGN_IDENTITY="Apple Development" bash scripts/build_macos.sh`。

手動で当てるなら、LZ Editor の `adab5d2`（v0.2.0）で `git apply --whitespace=nowarn <patch>` を実行し、`cargo build --release` する。

## フォント設定

`Ctrl+K Ctrl+F` またはメニュー「ツール」の「フォント設定...」。選ぶとすぐ画面に反映される。

| キー | 機能 |
|---|---|
| `↑` / `↓`（`Ctrl+E` / `Ctrl+X`）、`PageUp` / `PageDown`、`Home` / `End` | フォントの選択 |
| `←` / `→`（`Ctrl+S` / `Ctrl+D`）、`Tab` | 英数字 / 日本語の切替 |
| `Space` | 半角:全角=1:2 の切替（英数字を縮めて桁をそろえる） |
| `M` | 等幅の日本語だけ表示 |
| `Enter` / `ESC` | 決定して保存 / 取消 |

設定は `~/Library/Application Support/LZ Editor/settings.conf`（Linux は `$XDG_CONFIG_HOME/lz-editor/`、既定 `~/.config/lz-editor/`）に保存する。環境変数 `LZ_CONFIG_DIR` で変更できる。

## 動作確認

macOS 27 / Apple Silicon で、ビルド・起動・日本語 IME の変換入力・UTF-8 保存・フォントの選択と復元を確認。Linux でのビルドは未確認。

## 既知の限界

- 未保存のままウィンドウの赤ボタンや `Cmd+Q` で閉じた時の確認は未対応。`ESC` でファイラーに移ってから `F10` で終了する
- `Cmd+X` は切り取りではなくカーソル下移動になる
- 開く / 保存はファイル選択画面が出ず、パスの手入力になる
- Finder の「このアプリケーションで開く」は未対応
- Shift_JIS / EUC-JP のファイルは開けない（本家と同じ）

## ライセンス

MIT（LZ Editor 本体の MIT を継承）。全文は [`LICENSE`](LICENSE) を参照。原作の著作権は Touryu Tamane 氏に帰属する。
