#!/usr/bin/env bash

set -euo pipefail

KUSTOMIZE_PATH=""
KUSTOMIZE_TMP=""
KUSTOMIZE_HELM_OUT=""

function cleanup {
    [ -n "$KUSTOMIZE_TMP" ] && rm -rf "$KUSTOMIZE_TMP"
    exit
}

function init {
    [ $# -ne 1 ] && exit 127
    KUSTOMIZE_PATH="$1"
    KUSTOMIZE_TMP=$(mktemp -d -t tmp.kustomize.XXXXXXXXXX)
    KUSTOMIZE_HELM_OUT="$KUSTOMIZE_TMP/helm.out.yaml"
    trap cleanup 1 2 3 6
}

function process {
    cp -rT "$KUSTOMIZE_PATH" "$KUSTOMIZE_TMP"
    cat <&0 >"$KUSTOMIZE_HELM_OUT"
    kubectl kustomize "$KUSTOMIZE_TMP"
}

function main {
    init "$@"
    process
}

main "$@"
