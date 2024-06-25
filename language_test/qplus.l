%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "qplus.tab.h"

%}

%%

[ \t\n]+	;
"BEGIN"			{ return T_BEGIN; }
"TASK"			{ return T_TASK; }
\^			{ return T_START_BLOCK; }
\$			{ return T_END_BLOCK; }
";"			{ return T_END_OP; }
"+"			{ return T_PLUS_OP; }
"<"			{ return T_START_PARAM; }
">"			{ return T_END_PARAM; }
[a-zA-Z_]+		{ yylval.sval = strdup(yytext); return T_STRING; }
[0-9]+			{ yylval.ival = atoi(yytext); return T_INT; }

%%
