output: lexer
	gcc -o lexer lex.yy.c -lfl
lexer: lex.yy.c
	flex mini_l.lex
