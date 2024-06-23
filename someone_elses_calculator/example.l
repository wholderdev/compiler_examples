%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "example.tab.h"

%}

%%

[ \t]+	;
[0-9]+		{ printyy(yytext); yylval.ival = atoi(yytext); return T_INT; }
\n		{ printyy(yytext); return T_NEWLINE; }
"+"		{ printyy(yytext); return T_PLUS; }
"-"		{ printyy(yytext); return T_MINUS; }
"*"		{ printyy(yytext); return T_MULTIPLY; }
"/"		{ printyy(yytext); return T_DIVIDE; }
"("		{ printyy(yytext); return T_LEFT; }
")"		{ printyy(yytext); return T_RIGHT; }
"exit"		{ printyy(yytext); return T_QUIT; }
"quit"		{ printyy(yytext); return T_QUIT; }

%%

void printyy(const char *s) {
	printf("%s\n", s);
}
