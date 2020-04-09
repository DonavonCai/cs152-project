#!/bin/bash

testfile="primes.min"
file1="out.txt"
file2="primes.tokens"

printf 'Running test:\n'
cat $testfile | ../lexer > $file1

if cmp -s "$file1" "$file2"; then
    printf 'The file "%s" is the same as "%s"\n' "$file1" "$file2"
else
    printf 'The file "%s" is different from "%s"\n' "$file1" "$file2"
    diff -u "$file1" "$file2" > out.diff
fi
