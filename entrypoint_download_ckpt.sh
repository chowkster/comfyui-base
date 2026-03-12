#!/usr/bin/env bash
set -e

CKPT_DIR="/workspace/runpod-slim/ComfyUI/models/checkpoints"
mkdir -p "$CKPT_DIR"

if [ -n "$CHECKPOINT_ID" ]; then
  CKPT_PATH="${CKPT_DIR}/model_${CHECKPOINT_ID}.safetensors"

  if [ ! -f "$CKPT_PATH" ]; then
    echo "Downloading checkpoint ${CHECKPOINT_ID}..."

    if [ -n "$CIVITAI_API_KEY" ]; then
      URL="https://civitai.com/api/download/models/${CHECKPOINT_ID}?token=${CIVITAI_API_KEY}"
    else
      URL="https://civitai.com/api/download/models/${CHECKPOINT_ID}"
    fi

    curl -L "$URL" -o "$CKPT_PATH"
  else
    echo "Checkpoint already exists at $CKPT_PATH, skipping download."
  fi
else
  echo "CHECKPOINT_ID not set, skipping checkpoint download."
fi

# start SSH in background if desired
if command -v /usr/sbin/sshd >/dev/null 2>&1; then
  /usr/sbin/sshd || true
fi

# start ComfyUI (adjust args as you like)
cd /workspace/runpod-slim/ComfyUI
exec /start.sh
