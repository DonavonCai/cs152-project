#!/bin/bash

testfile="incorrect.min"
outputfile="out.txt"

printf 'Running test: %s\n' "$testfile"
cat $testfile | ../parser > out.txt

