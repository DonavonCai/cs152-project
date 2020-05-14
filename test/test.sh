#!/bin/bash

testfile="incorrect2.min"
outputfile="out.txt"

printf 'Running test: %s\n' "$testfile"
cat $testfile | ../parser > out.txt

