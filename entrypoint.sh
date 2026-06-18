#!/bin/sh
set -eu

# Pennsieve runs this container as a NON-ROOT user, so /app and the default
# HOME (/) are NOT writable at runtime. Redirect all writes to a writable
# location so the generated config and the dandi/joblib/fscacher cache succeed.
WORK_DIR="${TMPDIR:-/tmp}"
export HOME="$WORK_DIR"
export XDG_CACHE_HOME="$WORK_DIR/.cache"
mkdir -p "$XDG_CACHE_HOME"

EDF_FILE=$(find "$INPUT_DIR" -maxdepth 1 -type f -iname '*.edf' | head -n 1)

if [ -n "$EDF_FILE" ]; then
    export INPUT_FILE=$(basename "$EDF_FILE")
    echo "INPUT_FILE=${INPUT_FILE}"
else
    echo "No EDF files found in INPUT_DIR=$INPUT_DIR" >&2
    exit 1
fi

BASE_NAME="${INPUT_FILE%.*}"
export OUTPUT_FILE="${BASE_NAME}.nwb"
echo "OUTPUT_FILE=${OUTPUT_FILE}"

# Write the rendered config to a writable dir instead of /app.
CONFIG_FILE="$WORK_DIR/neuroconv_edf.yml"
envsubst < /app/neuroconv_edf.template.yml > "$CONFIG_FILE"

neuroconv "$CONFIG_FILE" --overwrite \
    --data-folder-path "$INPUT_DIR" \
    --output-folder-path "$OUTPUT_DIR"
