#!/bin/sh
# bat wrapper script for grep result format
#
# grep_bat.sh $options /path/to/file:lineno:
# --> bat $options --line-range n:m /path/to/file
#
OPTIONS=()
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -*)
      OPTIONS+=("$1")
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

arg=${POSITIONAL[0]}
# remove last ':'
arg="${arg%:}"

# separate path and lineno
path="${arg%:*}"
line="${arg##*:}"

prev_line=$((line - 3))
prev_line=$((prev_line < 0 ? 0 : prev_line)) 

next_line=$((line + 3))

bat ${OPTIONS[@]} --line-range "${prev_line}:${next_line}" $path
