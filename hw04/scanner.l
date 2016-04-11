/* ====================================================================== */

%{

#include "parser.h"
#include <string.h>

/* ====================================================================== */

#define	ACCEPT(x) return(x)
#define	ACCEPT_LEX(x) \
{ \
  yytext[yyleng] = '\0'; \
  lex = malloc(yyleng + 1); \
  strcpy(lex, yytext); \
  return(x); \
}

/* ====================================================================== */

char *lex;			/* current lexeme of ID or NUM */

/* ====================================================================== */

%}

digit				[0-9]
letter				[a-zA-Z]

%%

"void"				ACCEPT(VOID);

...

%%

/* ====================================================================== */