all:LEX

LEX:	
	flex a.l
	gcc lex.yy.c -lfl