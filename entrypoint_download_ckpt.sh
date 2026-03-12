#!/usr/bin/env bash
set -e

CKPT_DIR="/workspace/runpod-slim/ComfyUI/models/checkpoints"
mkdir -p "$CKPT_DIR"

# Only download if CHECKPOINT_ID is provided
if [ -n "$CHECKPOINT_ID" ]; then
  CKPT_PATH="${CKPT_DIR}/model_${CHECKPOINT_ID}.safetensors"

  if [ ! -f "$CKPT_PATH" ]; then
    echo "Downloading checkpoint ${CHECKPOINT_ID} to $CKPT_PATH..."

    # If CIVITAI_API_KEY is provided, include token
    if [ -n "$CIVITAI_API_KEY" ]; then
      URL="https://civitai.com/api/download/models/${CHECKPOINT_ID}?token=${CIVITAI_API_KEY}"
    else
      URL="https://civitai.com/api/download/models/${CHECKPOINT_ID}"
    fi

    curl -L "$URL" -o "$CKPT_PATH"
  else
    echo "Checkpoint already present at $CKPT_PATH, skipping download."
  fi
else
  echo "CHECKPOINT_ID not set, skipping checkpoint download."
fi

# Now start your original startup script
exec /start.sh
