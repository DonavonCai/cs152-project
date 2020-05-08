output: lex.yy.c y.tab.c
	gcc -o parser y.tab.c lex.yy.c -lfl
lex.yy.c:
	flex mini_l.lex
y.tab.c:
	bison -v -d --file-prefix=y mini_l.y
