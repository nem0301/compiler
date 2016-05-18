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

#define LINE_COUNT() line_count() 
/* ====================================================================== */

char *lex;			/* current lexeme of ID or NUM */
int source_line_no = 1;

void line_count()
{
	int i = 0;
	char c;

	while ( (c = *(yytext + i)) != '\0' )
	{
		if ( c == '\n' )
		{
			source_line_no++;
		}
		i++;
	}
}

/* ====================================================================== */

%}

digit				[0-9]
letter				[a-zA-Z]

whitespace          [\t\r\n ]
comments            "/*"([^*]|(\*[^/]))*"*/"|(\/\/.*\n) 


%%
"void"                              ACCEPT(VOID);
"int"                               ACCEPT(INT);
"if"                                ACCEPT(IF);
"else"                              ACCEPT(ELSE);
"while"                             ACCEPT(WHILE);
"return"                            ACCEPT(RETURN);
"input"                             ACCEPT(INPUT);
"output"                            ACCEPT(OUTPUT);

"+"                                 ACCEPT(PLUS);
"-"                                 ACCEPT(MINUS);
"*"                                 ACCEPT(MULTIPLY);
"/"                                 ACCEPT(DIVIDE);
"<"                                 ACCEPT(LT);
"<="                                ACCEPT(LE);
">"                                 ACCEPT(GT);
">="                                ACCEPT(GE);
"=="                                ACCEPT(EQ);
"!="                                ACCEPT(NE);
"="                                 ACCEPT(ASSIGN);
","                                 ACCEPT(COMMA);
";"                                 ACCEPT(SEMICOLON);
"("                                 ACCEPT(LPAR);
")"                                 ACCEPT(RPAR);
"{"                                 ACCEPT(LBRACE);
"}"                                 ACCEPT(RBRACE);
"["                                 ACCEPT(LBRACKET);
"]"                                 ACCEPT(RBRACKET);

{digit}{digit}*                         ACCEPT_LEX(NUM);
("_"|{letter})({digit}|{letter}|"_")*   ACCEPT_LEX(ID);

{comments}                          LINE_COUNT();
{whitespace}                        LINE_COUNT();

.                   ACCEPT(UNDEFINED);

%%

/* ====================================================================== */
