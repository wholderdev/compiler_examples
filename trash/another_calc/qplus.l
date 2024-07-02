%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "qplus.tab.h"

void general_print(const char *s);

%}

%%

[ \t]+	;
[0-9]+		{ general_print(yytext); yylval.ival = atoi(yytext); return T_INT; }
\n		{ general_print(yytext); return T_NEWLINE; }
"+"		{ general_print(yytext); return T_PLUS; }
"-"		{ general_print(yytext); return T_MINUS; }
"*"		{ general_print(yytext); return T_MULTIPLY; }
"/"		{ general_print(yytext); return T_DIVIDE; }
"("		{ general_print(yytext); return T_LEFT; }
")"		{ general_print(yytext); return T_RIGHT; }
"exit"		{ general_print(yytext); return T_QUIT; }
"quit"		{ general_print(yytext); return T_QUIT; }

%%

void general_print(const char *s) {
	//printf("%s\n", s);
}
