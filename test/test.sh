#!/bin/bash

testfile="testprog.min"
outputfile="out.mil"

printf 'Running test: %s\n' "$testfile"
cat $testfile | ../parser > $outputfile 2>&1
printf 'MIL code has been output to %s\n' "$outputfile"

