#!/bin/bash

testfile="id_begin_with_num.min"
file1="out.txt"
file2="id_begin_with_num.tokens"
diff_file="diff.txt"

printf 'Running test: %s\n' "$testfile"
cat $testfile | ../lexer > $file1

if cmp -s "$file1" "$file2"; then
    printf 'Test passed: The file "%s" is the same as "%s"\n' "$file1" "$file2"
else
    printf 'TEST FAILED: The file "%s" is different from "%s". Diff output to %s\n' "$file1" "$file2" "$diff_file"
    diff -u "$file1" "$file2" > $diff_file
fi
