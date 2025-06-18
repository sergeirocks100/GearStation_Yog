#!/bin/bash

set -euo pipefail

source dependencies.sh

if [ -f "$HOME/.byond/bin/libauxmos.so" ] && grep -Fxq "${AUXMOS_VERSION}" $HOME/.byond/bin/auxmos-version.txt;
then
  echo "Using cached directory."
else
  echo "Installing Auxmos"
  curl "https://github.com/Putnam3145/auxmos/releases/download/${AUXMOS_VERSION}/libauxmos.so"
  mkdir -p ~/.byond/bin
  cp libauxmos.so ~/.byond/bin/libauxmos.so
  echo "$AUXMOS_VERSION" > "$HOME/.byond/bin/auxmos-version.txt"
  ldd ~/.byond/bin/libauxmos.so
  echo "Finished installing Auxmos"
  cd ..
fi
