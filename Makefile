parser: mini_l.lex mini_l.y
	bison -v -d --file-prefix=y mini_l.y
	flex mini_l.lex
	g++ -std=c++11 -o parser y.tab.c lex.yy.c -lfl
clean:
	rm -f y.tab.* lex.yy.c y.output parser
