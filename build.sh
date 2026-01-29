#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
export THEOS="${THEOS:-/Users/yousuername/theos}"
export THEOS_SDKS="${THEOS_SDKS:-$THEOS/sdks}"
# Change this to match the SDK you have installed, e.g.:
# export SDKROOT="$THEOS/sdks/iPhoneOS17.0.sdk"
export SDKROOT="${SDKROOT:-$THEOS/sdks/iPhoneOS26.3.sdk}"

if [[ ! -d "$THEOS" ]]; then
  echo "THEOS not found at $THEOS"
  exit 1
fi

format="${1:-deb}"
clean="${2:---clean}"

if [[ "$clean" == "--no-clean" ]]; then
  clean_cmd=()
else
  clean_cmd=(clean)
fi

if [[ -n "$format" ]]; then
  echo "Building with THEOS_PACKAGE_FORMAT=$format"
  make -C "$ROOT" "${clean_cmd[@]}" package THEOS_PACKAGE_FORMAT="$format"
else
  echo "Building with default package format"
  make -C "$ROOT" "${clean_cmd[@]}" package
fi
