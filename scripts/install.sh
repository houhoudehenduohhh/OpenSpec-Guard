#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"
SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "============================================="
echo " OpenSpec-Guard: Project Injection Utility   "
echo "============================================="
echo "Target Project: $TARGET_DIR"

mkdir -p "$TARGET_DIR/.agents/workflows"
mkdir -p "$TARGET_DIR/.agents/skills"
mkdir -p "$TARGET_DIR/openspec/changes/archive"
mkdir -p "$TARGET_DIR/openspec/specs"

cp -R "$SOURCE_ROOT/.agents/workflows/"* "$TARGET_DIR/.agents/workflows/"
cp -R "$SOURCE_ROOT/.agents/skills/"* "$TARGET_DIR/.agents/skills/"

if [ ! -f "$TARGET_DIR/openspec/config.yaml" ]; then
    cp "$SOURCE_ROOT/openspec/config.yaml" "$TARGET_DIR/openspec/config.yaml"
    echo "[OK] Created baseline openspec/config.yaml"
else
    echo "[INFO] Existing openspec/config.yaml preserved"
fi

touch "$TARGET_DIR/openspec/changes/archive/.gitkeep"
touch "$TARGET_DIR/openspec/specs/.gitkeep"

echo "============================================="
echo " OpenSpec-Guard installed successfully!      "
echo " Available commands: /opsx-propose, /opsx-apply, /opsx-audit, /opsx-archive "
echo "============================================="
