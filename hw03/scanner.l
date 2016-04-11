/* ====================================================================== */

%{

#define ACCEPT(x) \
{ \
	printf("line=%i, token=%s, lexeme=\"%s\"\n", source_line_no, (char*)x, yytext); \
	fflush(stdout); \
} 

#define LINE_COUNT() \
{ \
    int i=0; \
    char c; \
    while ( (c = *(yytext + i)) != '\0') \
    { \
        if (c == '\n'){ \
            source_line_no++; \
        } \
        i++; \
    } \
} 



int source_line_no = 1;


%}

digit				[0-9]
letter				[a-zA-Z]

whitespace          [\t\r\n ]
comments			"/*"([^*]|(\*[^/]))*"*/"|(\/\/.*\n) 


%%

"void"								ACCEPT("VOID");
"int"								ACCEPT("INT");
"if"								ACCEPT("IF");
"else"								ACCEPT("ELSE");
"while"								ACCEPT("WHILE");
"return"							ACCEPT("RETURN");
"input"								ACCEPT("INPUT");
"output"							ACCEPT("OUTPUT");

"+"									ACCEPT("PLUS");
"-"									ACCEPT("MINUS");
"*"									ACCEPT("MULTIPLY");
"/"									ACCEPT("DIVIDE");
"<"									ACCEPT("LT");
"<="								ACCEPT("LE");
">"									ACCEPT("GT");
">="								ACCEPT("GE");
"=="								ACCEPT("EQ");
"!="								ACCEPT("NE");
"="									ACCEPT("ASSIGN");
","									ACCEPT("COMMA");
";"									ACCEPT("SEMICOLON");
"("									ACCEPT("LPAR");
")"									ACCEPT("RPAR");
"{"									ACCEPT("LBRACE");
"}"									ACCEPT("RBRACE");
"["									ACCEPT("LBRACKET");
"]"									ACCEPT("RBRACKET");

{digit}{digit}*							ACCEPT("NUM");
("_"|{letter})({digit}|{letter}|"_")*	ACCEPT("ID");

{comments}							LINE_COUNT();
{whitespace}						LINE_COUNT();

.					ACCEPT("UNDEFINED");

%%

/* ====================================================================== */


int main(int argc, char *argv[])
{
  if(argc != 2) {
    fprintf(stderr, "usage: scanner file\n");
    exit(1);
  }
  yyin = fopen(argv[1], "r");
  if(yyin == NULL) {
    fprintf(stderr, "%s: %s\n", argv[1], strerror(errno));
    exit(1);
  }
  yylex();

  return 0;
}

/* ====================================================================== */
