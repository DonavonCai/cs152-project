output: lex.yy.c y.tab.c
	gcc -o parser y.tab.c lex.yy.c -lfl -DYYDEBUG=1
lex.yy.c:
	flex -d mini_l.lex
y.tab.c:
	bison -v -d -t --file-prefix=y mini_l.y
