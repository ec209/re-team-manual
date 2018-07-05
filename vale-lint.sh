#!/usr/bin/env bash

set -e

ROOT_DIR="$(dirname "$0")"
cd "$ROOT_DIR"

if [ -z "$(command -v vale)" ]; then
    echo -n "vale not found; "
    if [ "$(uname)" == "Darwin" ]; then
        echo "installing it from Homebrew..."
        brew tap ValeLint/vale
        brew install vale
    else
        echo "install it"
        exit 1
    fi
fi

vale "$@"
