#!/usr/bin/env bash

#set -e

GUI_DELAY=0.8 #0.4 works for most CLI, but some filetype load slow

INC=false
APPEND=false
COPY=false
GUI=false
COUNTER=1
DIR="."

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
# GUI prompt with buttons
# -----------------------------
gui_prompt() {
  sleep $GUI_DELAY
  osascript <<EOF
tell application "System Events"
  activate
end tell

try
  set dlg to display dialog "Describe this file:" ¬
    default answer "" ¬
    buttons {"Back", "Skip", "Rename"} ¬
    default button "Rename"
  return button returned of dlg & "|" & text returned of dlg
on error number -128
  return "Quit|"
end try
EOF
}

# -----------------------------
# Build file list (for BACK)
# -----------------------------
# in advanced bashes this can be done with
# mapfile -t FILES < <(find "$DIR" -maxdepth 1 -type f | sort)
# but for bash<=3 compatibility I switched to this iteration here
FILES=()
echo "Found the following files:"
while IFS= read -r f; do
  FILES+=("$f")
  echo "$f"
done < <(find "$DIR" -maxdepth 1 -type f | sort)


index=0
total=${#FILES[@]}
#echo "$total"

while [[ $index -lt $total ]]; do
  #echo "$index is smaller than $total"
  file="${FILES[$index]}"
  base="$(basename "$file")"
  name="${base%.*}"
  ext="${base##*.}"
  dir="$(dirname "$file")"

  echo "Previewing: $base"

  qlmanage -p "$file" >/dev/null 2>&1 &
  QLPID=$!

  if $GUI; then
    response=$(gui_prompt)
  else
    read -p "Enter description (empty = skip, q = quit): " response
    response="Rename|$response"
  fi

  kill "$QLPID" >/dev/null 2>&1 || true

  IFS="|" read -r action desc <<< "$response"

  case "$action" in
    Quit)
      echo "Exiting."
      exit 0
      ;;
    Skip)
      ((index++))
      continue
      ;;
    Back)
      ((index > 0)) && ((index--))
      continue
      ;;
    Rename)
      [[ -z "$desc" ]] && ((index++)) && continue
      ;;
  esac

  safe_desc=$(echo "$desc" | tr ' ' '_' | tr -cd '[:alnum:]_-')

  prefix=""
  $INC && prefix=$(printf "%02d_" "$COUNTER")

  if $APPEND; then
    newname="${prefix}${name}_${safe_desc}.${ext}"
  else
    newname="${prefix}${safe_desc}.${ext}"
  fi

  target="$dir/$newname"

  if $COPY; then
    cp -n "$file" "$target"
    echo "Copied → $newname"
  else
    mv -n "$file" "$target"
    echo "Renamed → $newname"
  fi
  #echo "$COUNTER"

  ((COUNTER++))
  ((index++))
  #echo "$COUNTER"
  #echo "$index"
done

