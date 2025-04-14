#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="${SCRIPT_DIR}/find_gtags_defs.sh"

# search all symbols
callfzf () {
    global -c \
        2> /dev/null \
    | fzf \
        --cycle \
        --multi
}
SYMBOL=$(callfzf)
if [[ -z "$SYMBOL" ]]; then
    echo canceled
    echo "1" > "$CANARY_FILE"
    exit 1
else
    # search symbol location
    sh ${SCRIPT} ${SYMBOL} "$@" -x
fi