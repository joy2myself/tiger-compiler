a.out: main.o y.tab.o lex.yy.o errormsg.o util.o table.o symbol.o semant.o absyn.o env.o types.o
	cc -g main.o y.tab.o lex.yy.o errormsg.o util.o table.o symbol.o semant.o absyn.o env.o types.o

main.o: main.c
	cc -g -c main.c

types.o: types.c types.h
	cc -g -c types.c

env.o: env.c env.h
	cc -g -c env.c

absyn.o: absyn.c absyn.h util.h symbol.h
	cc -g -c absyn.c

semant.o: semant.c semant.h
	cc -g -c semant.c

symbol.o: symbol.c symbol.h util.h symbol.h table.h
	cc -g -c symbol.c

table.o: table.c table.h util.h
	cc -g -c table.c

y.tab.o: y.tab.c
	cc -g -c y.tab.c

y.tab.c: tiger.grm
	yacc -dv tiger.grm

y.tab.h: y.tab.c
	echo "y.tab.h was created at the same time as y.tab.c"

errormsg.o: errormsg.c errormsg.h util.h
	cc -g -c errormsg.c

lex.yy.o: lex.yy.c y.tab.h errormsg.h util.h
	cc -g -c lex.yy.c

lex.yy.c: tiger.lex
	lex tiger.lex

util.o: util.c util.h
	cc -g -c util.c

clean: 
	rm -f a.out util.o parse.o lex.yy.o errormsg.o y.tab.c y.tab.h y.tab.o
