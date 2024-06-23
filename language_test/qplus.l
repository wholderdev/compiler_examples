%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "qplus.tab.h"

%}

%%

[ \t]+	;
\n		{ return T_NEWLINE; }
"task"		{ return T_TASK; }
[a-z]+		{ yylval.sval = strdup(yytext); return T_ID; }

%%
