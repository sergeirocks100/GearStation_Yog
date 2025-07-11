#!/bin/bash
set -euo pipefail
EXIT_CODE=0
MAP=$1

tools/deploy.sh travis_test
mkdir travis_test/config
mkdir travis_test/data

#test config
cp tools/travis/travis_config.txt travis_test/config/config.txt

#set the map
cp _maps/$MAP.json travis_test/data/next_map.json

cd travis_test
DreamDaemon gearstation.dmb -close -trusted -verbose -params "test-run&log-directory=travis" || EXIT_CODE=$?

#We don't care if extools dies
if [ $EXIT_CODE != 134 ]; then
   if [ $EXIT_CODE != 0 ]; then
      exit $EXIT_CODE
   fi
fi

cd ..
cat travis_test/data/logs/travis/clean_run.lk
