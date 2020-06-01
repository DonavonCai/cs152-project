#!/bin/bash

testfile="testprog.min"
outputfile="out.mil"

printf 'Running test on input: %s\n' "$testfile"
cat $testfile | ../parser > $outputfile 2>&1
printf '\nMIL code has been output to %s\n' "$outputfile"
printf '\nNow running mil_run %s:\n\n' "$outputfile"
mil_run $outputfile
printf '\nIf there is no output make sure that the test program has a write instruction and there are no errors in %s.\n' "$outputfile"
