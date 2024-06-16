%{
#include "example.tab.h"
%}

%%
[0-9]+		{ yylval.num = atoi(yytext); return NUMBER; }
[ \t]+		{ /* Whitespace Skip */ }
\n		{ return yytext[0]; }
.		{ return yytext[0]; }
%%
