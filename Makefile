TARGET = parser
OBJECT = lex.yy.c y.tab.c
CC = gcc -o
LEX = lex
YACC = yacc -d -v

all:
	$(YACC) yacctemplate.y
	$(LEX) lex.l
	$(CC) $(TARGET) $(OBJECT) -ly -ll

clean:
	rm -f $(TARGET) $(OBJECT)
