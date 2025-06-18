#!/bin/bash

set -euo pipefail

source dependencies.sh

if [ -f "$HOME/.byond/bin/libauxmos.so" ] && grep -Fxq "${AUXMOS_VERSION}" $HOME/.byond/bin/auxmos-version.txt;
then
  echo "Using cached directory."
else
  echo "Installing Auxmos"
  mkdir -p ~/.byond/bin
  wget -O ~/.byond/bin/libauxmos.so "https://github.com/Putnam3145/auxmos/releases/download/$AUXMOS_VERSION/libauxmos.so"
  chmod +x ~/.byond/bin/libauxmos.so
  ldd ~/.byond/bin/librust_g.so
  echo "Finished installing Auxmos"
  cd ..
fi
