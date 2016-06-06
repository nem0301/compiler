/* ====================================================================== */

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "symbol.c"

/* ====================================================================== */
//error type
#define WRONG_VOID_VAR 0
#define WRONG_VOID_ARR 1
#define WRONG_VOID_ARG 2
#define WRONG_VOID_ARR_ARG 3
#define REDEFINE_VAR 10
#define REDEFINE_ARR 11
#define REDEFINE_FUNC 12
#define REDEFINE_ARG 13
#define REDEFINE_ARR_ARG 14
#define UNDEFINE_VAR 20
#define UNDEFINE_ARR 21
#define UNDEFINE_FUNC_CALL 22
#define TYPE_ERROR_VAR 30
#define TYPE_ERROR_ARR 31
#define TYPE_ERROR_FUNC 32
#define WRONG_NO_ARG_FUNC 40

/* ====================================================================== */

extern FILE *yyin;
extern char *yytext;

extern char *lex;
extern int source_line_no;

/* ====================================================================== */
int position;

int global_offset;
int local_offset;
int *current_offset;

int farg_count;
int aarg_count;

unsigned int ip = 0;

/* ====================================================================== */

typedef struct l_type_struct {  /* lex attribute for var and num */
	  char *lex;
} l_type;

typedef struct t_type_struct {  /* type attribute for type_specifier */
	  unsigned char type;
} t_type;


/* ====================================================================== */

int yyerror(char *message);
int error(char *fmt, char *s1, char *s2, char *s3, char *s4);
int check_error(unsigned char error_type, char *str, unsigned char type);

%}

/* ====================================================================== */

%start program

%union {
	l_type lval;
	t_type tval;
}

%token VOID INT
%token IF ELSE
%token WHILE
%token RETURN
%token INPUT OUTPUT

%token PLUS MINUS MULTIPLY DIVIDE
%token LT LE GT GE EQ NE
%token ASSIGN COMMA SEMICOLON
%token LPAR RPAR LBRACE RBRACE LBRACKET RBRACKET

%token NUM ID
%token UNDEFINED

%type <lval> var num
%type <tval> type_specifier;

%%

/* ====================================================================== */

program
    : 
	{
		position = GLOBAL;
		current_table = global_table = create_table("_global");
		current_offset = &global_offset;
		*current_offset = 0;
		fprintf(stdout, 
			"---------- ---------- ---------- ---------- ---------- ----------\n");

		fprintf(stdout, 
			"%-10s %-10s %-10s %-10s %10s %10s\n", "table", "symbol", "kind", "type", "size", "offset");

		fprintf(stdout, 
			"---------- ---------- ---------- ---------- ---------- ----------\n");
	}
	var_declaration_list fun_declaration_list
	{
		print_table(global_table);
	  	fprintf(stdout,
		"---------- ---------- ---------- ---------- ---------- ----------\n");
	}
;

var_declaration_list
    : var_declaration_list var_declaration
    | empty
;

fun_declaration_list
    : fun_declaration_list fun_declaration
    | fun_declaration
;

var_declaration
    : type_specifier var SEMICOLON
	{
		check_error(WRONG_VOID_VAR, $<lval>2.lex, $<tval>1.type);
		check_error(REDEFINE_VAR, $<lval>2.lex, $<tval>1.type);
		add_symbol (current_table, 
					$<lval>2.lex,
					position, 
					$<tval>1.type,
					1, 
					*current_offset);
		*current_offset = *current_offset + 1;
					
	}
    | type_specifier var LBRACKET num RBRACKET SEMICOLON
	{
		check_error(WRONG_VOID_ARR, $<lval>2.lex, $<tval>1.type);
		check_error(REDEFINE_ARR, $<lval>2.lex, $<tval>1.type);
		int n = atoi($<lval>4.lex);

		add_symbol (current_table, 
					$<lval>2.lex,
					position, 
					INT_ARRAY_TYPE,
					n,
					*current_offset + n - 1);
		*current_offset = *current_offset + n;
					
	}
;

type_specifier
    : INT
	{
		$<tval>$.type = INT_TYPE;
	}
    | VOID
	{
		$<tval>$.type = VOID_TYPE;
	}
;

var
    : ID
	{
		$<lval>$.lex = lex;
	}
;

num
    : NUM
	{
		$<lval>$.lex = lex;
	}
;

fun_declaration
    : type_specifier var 
	{
		check_error(REDEFINE_FUNC, $<lval>2.lex, 0);
		position = ARGUMENT;
		current_table = local_table = create_table($<lval>2.lex);
		current_offset = &local_offset;
		*current_offset = 0;
		farg_count = 0;
	}
	LPAR params RPAR 
	{
		add_symbol ( global_table, $<lval>2.lex, FUNCTION, $<tval>1.type, farg_count, ip);
		position=LOCAL;
	}
	LBRACE local_declarations statement_list RBRACE
	{
		print_table(current_table);
	  	fprintf(stdout,
		"---------- ---------- ---------- ---------- ---------- ----------\n");

		current_table = global_table;
	}
;

params
    : param_list
    | VOID
;

param_list
    : param_list COMMA param
	{
		farg_count++;
	}
    | param
	{
		farg_count = 1;
	}
;

param
    : type_specifier var
	{
		check_error(WRONG_VOID_ARG, $<lval>2.lex, $<tval>1.type);
		check_error(REDEFINE_ARG, $<lval>2.lex, 0);
		add_symbol (current_table,
					$<lval>2.lex,
					position,
					$<tval>1.type,
					1,
					*current_offset);
		*current_offset = *current_offset + 1;
	}
    | type_specifier var LBRACKET RBRACKET
	{
		check_error(WRONG_VOID_ARR_ARG, $<lval>2.lex, $<tval>1.type);
		check_error(REDEFINE_ARR_ARG, $<lval>2.lex, 0);
		add_symbol (current_table,
					$<lval>2.lex,
					position,
					INT_P_TYPE,
					1,
					*current_offset);
		*current_offset = *current_offset + 1;
	}
;

local_declarations
    : local_declarations var_declaration
    | empty
;

statement_list
    : statement_list statement
    | empty
;

statement
    : compound_stmt
    | expression_stmt
    | selection_stmt
    | iteration_stmt
    | funcall_stmt
    | return_stmt
    | input_stmt
    | output_stmt
;

compound_stmt
    : LBRACE statement_list RBRACE
;

expression_stmt
    : expression SEMICOLON
    | SEMICOLON
;

expression
    : var ASSIGN expression
	{
		check_error(UNDEFINE_VAR, $<lval>1.lex, 0);
		check_error(TYPE_ERROR_VAR, $<lval>1.lex, 0);
	}
    | var LBRACKET expression RBRACKET ASSIGN expression
	{
		check_error(UNDEFINE_ARR, $<lval>1.lex, 0);
		check_error(TYPE_ERROR_ARR, $<lval>1.lex, 0);
	}
    | simple_expression
;

simple_expression
    : additive_expression relop additive_expression
    | additive_expression
;

relop
    : LT
    | LE
    | GT
    | GE
    | EQ
    | NE
;

additive_expression
    : additive_expression addop term
    | term
;

addop
    : PLUS
    | MINUS
;

 term
    : term mulop factor
    | factor
;

mulop
    : MULTIPLY
    | DIVIDE
;

factor
    : LPAR expression RPAR
    | var
	{
		check_error(UNDEFINE_VAR, $<lval>1.lex, 0);
	}
    | var LBRACKET expression RBRACKET
	{
		check_error(UNDEFINE_ARR, $<lval>1.lex, 0);
	}
    | num
    | PLUS num
    | MINUS num
;

selection_stmt
    : IF LPAR expression RPAR statement ELSE statement
;

iteration_stmt
    : WHILE LPAR expression RPAR statement
;

funcall_stmt
    : var ASSIGN call
	{
		check_error(UNDEFINE_VAR, $<lval>1.lex, 0);
	}
    | var LBRACKET expression RBRACKET ASSIGN call
	{
		check_error(UNDEFINE_ARR, $<lval>1.lex, 0);
	}
    | call
;

call
    : var 
	{
		check_error(UNDEFINE_FUNC_CALL, $<lval>1.lex, 0);
		check_error(TYPE_ERROR_FUNC, $<lval>1.lex, 0);
		aarg_count = 0;
	}
	LPAR args RPAR
	{
		check_error(WRONG_NO_ARG_FUNC, $<lval>1.lex, 0);
	}
;

args
    : arg_list
    | empty
;

arg_list
    : arg_list COMMA expression
	{
		aarg_count++;
	}
    | expression
	{
		aarg_count = 1;
	}
;

return_stmt
	: RETURN SEMICOLON
    | RETURN expression SEMICOLON
;

input_stmt
    : INPUT var SEMICOLON
    | INPUT var LBRACKET expression RBRACKET SEMICOLON
;

output_stmt
    : OUTPUT expression SEMICOLON
;

empty
    :
;


%%

/* ====================================================================== */

int yyerror(char *message)
{
  print_table(current_table);
  fprintf(stdout,
    "---------- ---------- ---------- ---------- ---------- ----------\n");
  print_table(global_table);
  fprintf(stdout,
    "---------- ---------- ---------- ---------- ---------- ----------\n");
  fprintf(stderr, "line %d: %s at \"%s\"\n", source_line_no, message,
      yytext);
}

/* ====================================================================== */

int error(char *fmt, char *s1, char *s2, char *s3, char *s4)
{
  print_table(current_table);
  fprintf(stdout,
    "---------- ---------- ---------- ---------- ---------- ----------\n");
  print_table(global_table);
  fprintf(stdout,
    "---------- ---------- ---------- ---------- ---------- ----------\n");
  fprintf(stdout, "line %d: ", source_line_no);
  fprintf(stdout, fmt, s1, s2, s3, s4);
  fprintf(stdout, "\n");
  fflush(stdout);
  exit(-1);
}

int check_error(unsigned char error_type, char *str, unsigned char type)
{
	struct symbol *symbolp = NULL; 
	struct symbol *cur_symbolp = NULL;
	symbolp = lookup_symbol(str);
	cur_symbolp = find_symbol(current_table, str);

	switch (error_type)
	{
		case WRONG_VOID_VAR:
			if (type == VOID_TYPE)
			{
				error("error %s: wrong void variable \"%s\"\n", "00", str, "", "");
			}
			break;
		case WRONG_VOID_ARR:
			if (type == VOID_TYPE)
			{
				error("error %s: wrong void array \"%s\"\n", "01", str, "", "");
			}
			break;
		case WRONG_VOID_ARG:
			if (type == VOID_TYPE)
			{
				error("error %s: wrong void argument \"%s\"\n", "02", str, "", "");
			}
			break;
		case WRONG_VOID_ARR_ARG:
			if (type == VOID_TYPE)
			{
				error("error %s: wrong void array argument \"%s\"\n", "03", str, "", "");
			}
			break;
		case REDEFINE_VAR:
			if (cur_symbolp != NULL)
			{
				error("error %s: redefined variable \"%s\"\n", "10", str, "", "");
			}
			break;
		case REDEFINE_ARR:
			if (cur_symbolp != NULL)
			{
				error("error %s: redefined array \"%s\"\n", "11", str, "", "");
			}
			break;
		case REDEFINE_FUNC:
			if (cur_symbolp != NULL)
			{
				current_table = NULL;
				error("error %s: redefined function \"%s\"\n", "12", str, "", "");
			}
			break;
		case REDEFINE_ARG:
			if (cur_symbolp != NULL)
			{
				error("error %s: redefined argument \"%s\"\n", "13", str, "", "");
			}
			break;
		case REDEFINE_ARR_ARG:
			if (cur_symbolp != NULL)
			{
				error("error %s: redefined array argument \"%s\"\n", "14", str, "", "");
			}
			break;
		case UNDEFINE_VAR:
			if (symbolp == NULL)
			{
				error("error %s: undefined variable \"%s\"\n", "20", str, "", "");
			}
			break;
		case UNDEFINE_ARR:
			if (symbolp == NULL)
			{
				error("error %s: undefined array \"%s\"\n", "21", str, "", "");
			}
			break;
		case UNDEFINE_FUNC_CALL:
			if (symbolp == NULL)
			{
				error("error %s: undefined function call \"%s\"\n", "22", str, "", "");
			}
			break;
		case TYPE_ERROR_VAR:
			if (symbolp->kind == FUNCTION)
			{
				error("error %s: type error variable \"%s\"\n", "30", str, "", "");
			}
			break;
		case TYPE_ERROR_ARR:
			if (symbolp->kind == FUNCTION)
			{
				error("error %s: type error array \"%s\"\n", "31", str, "", "");
			}
			break;
		case TYPE_ERROR_FUNC:
			if (symbolp->kind != FUNCTION)
			{
				error("error %s: type error function \"%s\"\n", "32", str, "", "");
			}
			break;
		case WRONG_NO_ARG_FUNC:
			if (symbolp->size != aarg_count)
			{
				error("error %s: wrong no argument function \"%s\"\n", "40", str, "", "");
			}
			break;

	}

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
