#!/bin/bash
set -uo pipefail  # No -e to support write to canary file after cancel

. "$EXTENSION_PATH/shared.sh"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BAT="sh ${SCRIPT_DIR}/grep_bat.sh"

PREVIEW_ENABLED=${FIND_FILES_PREVIEW_ENABLED:-1}
PREVIEW_COMMAND=${FIND_FILES_PREVIEW_COMMAND:-"$BAT --decorations=always --color=always --plain {}"}
PREVIEW_WINDOW=${FIND_FILES_PREVIEW_WINDOW_CONFIG:-'right:50%:border-left'}
HAS_SELECTION=${HAS_SELECTION:-}
RESUME_SEARCH=${RESUME_SEARCH:-}
CANARY_FILE=${CANARY_FILE:-'/tmp/canaryFile'}
QUERY=''

# move to directory location which inclue current file path.
SYMBOL="$1"
DIR_PATH="$2"
OPTIONS="$3"

cd ${DIR_PATH}

# Some backwards compatibility stuff
if [[ $FZF_VER_PT1 == "0.2" && $FZF_VER_PT2 -lt 7 ]]; then
    PREVIEW_WINDOW='right:50%'
fi

PREVIEW_STR=()
if [[ "$PREVIEW_ENABLED" -eq 1 ]]; then
    PREVIEW_STR=(--preview "$PREVIEW_COMMAND" --preview-window "$PREVIEW_WINDOW")
fi

callfzf () {
    global ${OPTIONS} ${SYMBOL} --result=grep --abs \
        2> /dev/null \
    |cut -d: -f1,2
    | fzf \
        --cycle \
        --multi \
        --history $LAST_QUERY_FILE \
        --query "${QUERY}" \
        ${PREVIEW_STR[@]+"${PREVIEW_STR[@]}"}
}

VAL=$(callfzf)

if [[ -z "$VAL" ]]; then
    echo canceled
    echo "1" > "$CANARY_FILE"
    exit 1
else
    echo "$VAL" > "$CANARY_FILE"
fi