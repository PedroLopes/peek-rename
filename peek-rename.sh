#!/bin/bash

set -e

DIR="${1:-.}"

for file in "$DIR"/*; do
  [ -f "$file" ] || continue

  echo "Previewing: $(basename "$file")"

  # Open Quick Look preview (same as Finder spacebar)
  qlmanage -p "$file" >/dev/null 2>&1 &
  QLPID=$!

  # Prompt user
  echo -n "Enter description (empty = skip, q = quit): "
  read desc

  # Close Quick Look
  kill "$QLPID" >/dev/null 2>&1 || true

  # Quit entirely
  if [[ "$desc" == "q" ]]; then
    echo "Exiting."
    exit 0
  fi

  # Skip file
  if [[ -z "$desc" ]]; then
    echo "Skipped."
    continue
  fi

  ext="${file##*.}"
  dir="$(dirname "$file")"

  # Sanitize description
  safe_desc=$(echo "$desc" | tr ' ' '_' | tr -cd '[:alnum:]_-')

  newname="$dir/$safe_desc.$ext"

  mv -n "$file" "$newname"
  echo "Renamed → $(basename "$newname")"
  echo
done

