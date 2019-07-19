%{

/*
Author:         ZhangYin, zhangyin2018@iscas.ac.cn
Version:        1.0.3
Date:           May 29, 2019
Description:    Tiger compiler chap2, Lexical analyzer of TIGER in lex
 */

#include <string.h>
#include "util.h"
#include "absyn.h"
#include "symbol.h"
//#include "tokens.h"
#include "y.tab.h"
#include "errormsg.h"

int charPos=1;

int yywrap(void){
	charPos=1;
	return 1;
}


void adjust(void){
	EM_tokPos=charPos;
	charPos+=yyleng;
}


int nestingCount;
int stringPos;
char s[80];
%}

%x CMT STR

%%


"/*" {
	adjust();
	nestingCount = 1;
	BEGIN(CMT);
}
<CMT>{
	"/*" {
		adjust();
		nestingCount += 1;
		continue;
	}
	"*/" {
		adjust();
		nestingCount -= 1;
		if(nestingCount == 0){
			BEGIN(INITIAL);
			continue;
		}
	}
	\n {
		adjust();
		EM_newline();
		continue;
	}
	<<EOF>> {
		EM_error(EM_tokPos, "Encounter EOF in Comment");
		yyterminate();
	}
	. {
		adjust();
		continue;
	}
}


\" {
	stringPos = charPos;
	adjust();
	BEGIN(STR);
}
<STR>{
	\" {
		adjust();
		EM_tokPos = stringPos;
		yylval.sval = String(s);
		s[0] = '\0';
		BEGIN(INITIAL);
		return STRING;
	}
	\\[ \n\r\t\f]+\\ {
		adjust();
		continue;
	}
	\\n {
		adjust();
		strcat(s, "\n");
	}
	\\t {
		adjust();
		strcat(s, "\t");
	}
	\\^[a-zA-Z] {
		adjust();
		continue;
	}
	\\(3[2-9]|[4-9][0-9]|1[01][0-9]|12[0-6]) {
		adjust();
		char c = atoi(yytext+1);
		strcat(s, &c);
		s[strlen(s) - 1] = 0;
	}
	\\\" {
		adjust();
		strcat(s, "\"");
	}
	\\\\ {
		adjust();
		strcat(s, "\\");
	}
	\\. {
		adjust();
		EM_error(EM_tokPos, "Illegal Character in String");
        yyterminate();
	}
	<<EOF>> {
		EM_error(EM_tokPos, "Encounter EOF in String");
		yyterminate();
	}
	. {
		adjust();
		strcat(s, yytext);
	}
}


[ \r\t]		{adjust(); continue;}
\n			{adjust(); EM_newline(); continue;}


while 		{adjust(); return WHILE;}
for       	{adjust(); return FOR;}
to        	{adjust(); return TO;}
break     	{adjust(); return BREAK;}
let       	{adjust(); return LET;}
in        	{adjust(); return IN;}
end       	{adjust(); return END;}
function  	{adjust(); return FUNCTION;}
var       	{adjust(); return VAR;}
type      	{adjust(); return TYPE;}
array     	{adjust(); return ARRAY;}
if       	{adjust(); return IF;}
then      	{adjust(); return THEN;}
else      	{adjust(); return ELSE;}
do        	{adjust(); return DO;}
of        	{adjust(); return OF;}
nil       	{adjust(); return NIL;}


","   		{adjust(); return COMMA;}
":"   		{adjust(); return COLON;}
";"   		{adjust(); return SEMICOLON;}
"("   		{adjust(); return LPAREN;}
")"   		{adjust(); return RPAREN;}
"["   		{adjust(); return LBRACK;}
"]"   		{adjust(); return RBRACK;}
"{"   		{adjust(); return LBRACE;}
"}"   		{adjust(); return RBRACE;}
"."   		{adjust(); return DOT;}
"+"   		{adjust(); return PLUS;}
"-"   		{adjust(); return MINUS;}
"*"   		{adjust(); return TIMES;}
"/"   		{adjust(); return DIVIDE;}
"="   		{adjust(); return EQ;}
"<>"  		{adjust(); return NEQ;}
"<"   		{adjust(); return LT;}
"<="  		{adjust(); return LE;}
">"   		{adjust(); return GT;}
">="  		{adjust(); return GE;}
"&"   		{adjust(); return AND;}
"|"   		{adjust(); return OR;}
":="  		{adjust(); return ASSIGN;}


[a-zA-Z]+[a-zA-Z0-9_]* {
	adjust();
	yylval.sval = String(yytext);
	return ID;
}


[0-9]+ {
	adjust();
	yylval.ival=atoi(yytext);
	return INT;
}


. {
	adjust();
	EM_error(EM_tokPos, "Illegal Token");
}
