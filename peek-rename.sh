#!/bin/bash

set -e

# -----------------------------
# Defaults
# -----------------------------
INC=false
APPEND=false
COPY=false
GUI=false
COUNTER=1
DIR="."

# -----------------------------
# Parse arguments
# -----------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i|--inc) INC=true ;;
    -a|--append) APPEND=true ;;
    -c|--copy) COPY=true ;;
    -g|--gui) GUI=true ;;
    *) DIR="$1" ;;
  esac
  shift
done

# -----------------------------
# Helper: GUI input
# -----------------------------
gui_prompt() {
  sleep 0.4
  osascript <<EOF
tell application "System Events"
  activate
end tell
display dialog "Describe this file:" default answer ""
text returned of result
EOF
}


# -----------------------------
# Main loop
# -----------------------------
for file in "$DIR"/*; do
  [ -f "$file" ] || continue

  base="$(basename "$file")"
  name="${base%.*}"
  ext="${base##*.}"
  dir="$(dirname "$file")"

  echo "Previewing: $base"

  # Quick Look preview (Finder-style Space)
  qlmanage -p "$file" >/dev/null 2>&1 &
  QLPID=$!

  # Input
  if $GUI; then
    desc=$(gui_prompt)
  else
    read -p "Enter description (empty = skip, q = quit): " desc
  fi

  # Close Quick Look
  kill "$QLPID" >/dev/null 2>&1 || true

  [[ "$desc" == "q" ]] && echo "Exiting." && exit 0
  [[ -z "$desc" ]] && echo "Skipped." && echo && continue

  # Sanitize
  safe_desc=$(echo "$desc" | tr ' ' '_' | tr -cd '[:alnum:]_-')

  # Auto-numbering
  prefix=""
  if $INC; then
    prefix=$(printf "%02d_" "$COUNTER")
  fi

  # Filename logic
  if $APPEND; then
    newname="${prefix}${name}_${safe_desc}.${ext}"
  else
    newname="${prefix}${safe_desc}.${ext}"
  fi

  target="$dir/$newname"

  # Copy or rename
  if $COPY; then
    cp -n "$file" "$target"
    echo "Copied → $newname"
  else
    mv -n "$file" "$target"
    echo "Renamed → $newname"
  fi

  ((COUNTER++))
  echo
done

