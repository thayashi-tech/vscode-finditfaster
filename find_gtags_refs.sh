#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="${SCRIPT_DIR}/find_gtags_base.sh"
sh ${SCRIPT} "$@" -rx