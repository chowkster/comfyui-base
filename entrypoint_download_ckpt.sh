#!/usr/bin/env bash
set -euo pipefail   # -u treats unset variables as error, -o pipefail catches pipeline failures

CKPT_DIR="/workspace/runpod-slim/ComfyUI/models/checkpoints"
mkdir -p "$CKPT_DIR"

if [ -n "${CHECKPOINT_ID:-}" ]; then
  CKPT_PATH="${CKPT_DIR}/model_${CHECKPOINT_ID}.safetensors"
  
  if [ ! -f "$CKPT_PATH" ]; then
    echo "Downloading checkpoint ${CHECKPOINT_ID} from Civitai..."
    
    if [ -n "${CIVITAI_API_KEY:-}" ]; then
      URL="https://civitai.com/api/download/models/${CHECKPOINT_ID}?token=${CIVITAI_API_KEY}"
    else
      URL="https://civitai.com/api/download/models/${CHECKPOINT_ID}"
      echo "Warning: No CIVITAI_API_KEY set — download may fail for gated models."
    fi
    
    # Add progress bar + better error handling
    curl --progress-bar -L --fail --retry 5 --retry-delay 3 "$URL" -o "$CKPT_PATH" || {
      echo "Download failed. Cleaning up partial file..."
      rm -f "$CKPT_PATH"
      exit 1
    }
    
    echo "Download complete: ${CKPT_PATH}"
  else
    echo "Checkpoint already exists: ${CKPT_PATH} — skipping download."
  fi
else
  echo "CHECKPOINT_ID not set — no checkpoint will be downloaded."
fi

# Optional: Start SSH only if explicitly enabled (via env var)
if [ "${ENABLE_SSH:-false}" = "true" ] && command -v /usr/sbin/sshd >/dev/null 2>&1; then
  echo "Starting SSH server in background..."
  /usr/sbin/sshd || echo "SSH failed to start (non-fatal)."
fi

# Change to ComfyUI dir and exec the real start script
cd /workspace/runpod-slim/ComfyUI || { echo "Cannot cd to ComfyUI directory"; exit 1; }

echo "Starting ComfyUI..."
exec /start.sh "$@"
