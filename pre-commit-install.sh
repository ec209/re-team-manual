#!/usr/bin/env bash

set -e

ROOT_DIR="$(dirname "$0")"
cd "$ROOT_DIR"

if [ -z "$(command -v pre-commit)" ]; then
    echo -n "pre-commit not found; "
    if [ "$(uname)" == "Darwin" ]; then
        echo "installing it from Homebrew..."
        brew install pre-commit
    else
        echo "install it"
        exit 1
    fi
fi

pre-commit install
