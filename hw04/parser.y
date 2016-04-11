/* ====================================================================== */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

/* ====================================================================== */

extern FILE *yyin;
extern char *yytext;

/* ====================================================================== */

int yyerror(char *message);

%}

/* ====================================================================== */

%start program

%token VOID INT
...

%%

/* ====================================================================== */

program
  : var_declaration_list fun_declaration_list
;

var_declaration_list
  : var_declaration_list var_declaration
  | empty
;

...


%%

/* ====================================================================== */

int yyerror(char *message)
{
  fprintf(stderr, "line %d: %s at \"%s\"\n", source_line_no, message, yytext);
}

/* ====================================================================== */

int main(int argc, char *argv[])
{
  if(argc != 2) {
    fprintf(stderr, "usage: parser file\n");
    exit(1);
  }
  yyin = fopen(argv[1], "r");
  if(yyin == NULL) {
    fprintf(stderr, "%s: %s\n", argv[1], strerror(errno));
    exit(1);
  }
  yyparse();

  return 0;
}

/* ====================================================================== */
