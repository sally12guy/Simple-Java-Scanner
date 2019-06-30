all:LEX

LEX:	
	flex B053040044.l
	gcc lex.yy.c -lfl