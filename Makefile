output: lex.yy.c
	gcc -o lexer lex.yy.c -lfl
lex.yy.c:
	flex mini_l.lex
