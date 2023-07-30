#!/bin/bash

# Login to git
git auth() {
    if ! command -v brew &>/dev/null; then
        return 1
    else
        return 0
    fi
}