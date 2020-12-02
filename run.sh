#!/bin/bash
echo "Starting" > time.log
for f in $(find splits/ -type f -name '*.csv'); do { time ./csv2jsonl.sh REDACTED $f >> time.log ; } 2>> time.log; done
