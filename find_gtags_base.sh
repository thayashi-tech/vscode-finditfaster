#!/bin/bash
set -uo pipefail  # No -e to support write to canary file after cancel

. "$EXTENSION_PATH/shared.sh"

PREVIEW_ENABLED=${FIND_FILES_PREVIEW_ENABLED:-1}
PREVIEW_COMMAND=${FIND_FILES_PREVIEW_COMMAND:-'bat --decorations=always --color=always --plain {}'}
PREVIEW_WINDOW=${FIND_FILES_PREVIEW_WINDOW_CONFIG:-'right:50%:border-left'}
HAS_SELECTION=${HAS_SELECTION:-}
RESUME_SEARCH=${RESUME_SEARCH:-}
CANARY_FILE=${CANARY_FILE:-'/tmp/canaryFile'}
QUERY=''

# move to directory location which inclue current file path.
DIR_PATH="$1"
SYMBOL="$2"
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
    global ${OPTIONS} ${SYMBOL} \
        2> /dev/null \
    | fzf \
        --cycle \
        --multi \
        --history $LAST_QUERY_FILE \
        --query "${QUERY}" \
        ${PREVIEW_STR[@]+"${PREVIEW_STR[@]}"}
}

VAL=$(callfzf)
TOKENS=
# --- GNU Global Output format ---
# SYMBOL LINENO PATH CODE
#
# --- find-it-faster openFile format ---
# FILE:LINENO:CHARNO

if [[ -z "$VAL" ]]; then
    echo canceled
    echo "1" > "$CANARY_FILE"
    exit 1
else
    read -ra TOKENS <<< "$VAL"
    FILEPATH=`realpath "${DIR_PATH}/${TOKENS[2]}"`
    VAL="${FILEPATH}:${TOKENS[1]}:1"
    if [[ -n "$SINGLE_DIR_ROOT" ]]; then
        TMP=$(mktemp)
        echo "$VAL" > "$TMP"
        sed "s|^|$SINGLE_DIR_ROOT/|" "$TMP" > "$CANARY_FILE"
        rm "$TMP"
    else
        echo "$VAL" > "$CANARY_FILE"
    fi
fi