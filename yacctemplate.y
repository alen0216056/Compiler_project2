%{
#include <stdio.h>
#include <stdlib.h>

extern int linenum;             /* declared in lex.l */
extern FILE *yyin;              /* declared by lex */
extern char *yytext;            /* declared by lex */
extern char buf[256];           /* declared in lex.l */
%}


%token COMMA SEMICOLON COLON  ASSIGN ARRAY MYBEGIN BOOLEAN DEF DO ELSE END FALSE FOR INTEGER IF OF PRINT READ REAL STRING THEN TO TRUE RETURN VAR WHILE STRING_VALUE OCTAL_NUM INTEGER_NUM FLOAT_NUM SCIENTIFIC_NUM IDENTIFIER
%left RIGHT_PARENTHESE LEFT_PARENTHESE LEFT_BRACKET RIGHT_BRACKET
%left MULTIPLY DIVIDE MOD 
%left SUBTRACT PLUS
%left LESS LESS_EQUAL NON_EQUAL LARGER_EQUAL LARGER EQUAL
%right NOT
%left AND
%left OR


%%

program		: IDENTIFIER SEMICOLON variables functions compound_statement END IDENTIFIER
		;

identifier_list	: COMMA IDENTIFIER identifier_list
				| /*empty*/
		;

/*function*/

functions	: function functions
			| /*empty*/
		;

function	: IDENTIFIER LEFT_PARENTHESE first_argument RIGHT_PARENTHESE function_return SEMICOLON compound_statement END IDENTIFIER
		;

first_argument	: argument arguments
				| /*empty*/
		;

arguments	: SEMICOLON argument arguments
			| /*empty*/
		;

argument	: IDENTIFIER identifier_list COLON type
		;

function_return	: COLON type 
				| /*empty*/
		;

/*variable*/

variables	: variable variables
			| /*empty*/
		;

variable	: VAR IDENTIFIER identifier_list COLON type SEMICOLON	
			| VAR IDENTIFIER identifier_list COLON literal_constant SEMICOLON
		;

array		: ARRAY integer_constant TO integer_constant OF type
		;
type		: scalar_type
			| array
		;

scalar_type	: INTEGER | REAL | STRING | BOOLEAN
		;

integer_constant	: INTEGER_NUM | OCTAL_NUM
		;
		
literal_constant	: FLOAT_NUM | SCIENTIFIC_NUM | integer_constant | STRING_VALUE | TRUE | FALSE
		;

/*statement*/

statements	: statement statements
			| /*empty*/
		;

statement	: compound_statement | simple_statement | conditional_statement | while_statement | for_statement 
			| return_statement | procedure_call
		;

compound_statement	: MYBEGIN variables statements END
		;

simple_statement	: variable_reference ASSIGN single_expression SEMICOLON 
					| PRINT single_expression SEMICOLON
					| READ variable_reference SEMICOLON
		;

variable_reference	: IDENTIFIER brackets
		;

brackets	: LEFT_BRACKET single_expression RIGHT_BRACKET brackets
			: /*empty*/
		;

single_expression	: LEFT_PARENTHESE single_expression RIGHT_PARENTHESE
					| SUBTRACT single_expression
					| NOT single_expression
					| single_expression MULTIPLY single_expression
					| single_expression DIVIDE single_expression
					| single_expression MOD single_expression
					| single_expression PLUS single_expression
					| single_expression SUBTRACT single_expression
					| single_expression LESS single_expression
					| single_expression LESS_EQUAL single_expression
					| single_expression EQUAL single_expression
					| single_expression LARGER single_expression
					| single_expression LARGER_EQUAL single_expression
					| single_expression NON_EQUAL single_expression
					| single_expression AND single_expression
					| single_expression OR single_expression
					| component
		;

first_expression	: single_expression expressions
					| /*empty*/
		;
expressions	: COMMA single_expression expressions
			| /*empty*/
		;

component	: literal_constant | variable_reference | function_invocation
		;

function_invocation	: IDENTIFIER LEFT_PARENTHESE first_expression RIGHT_PARENTHESE 
		;

conditional_statement	: IF single_expression THEN statements ELSE statements END IF
						| IF single_expression THEN statements END IF
		;

while_statement		: WHILE single_expression DO statements END DO
		;

for_statement		: FOR IDENTIFIER ASSIGN integer_constant TO integer_constant DO statements END DO
		;

return_statement	: RETURN single_expression SEMICOLON
		;

procedure_call 		: function_invocation SEMICOLON
		;

%%		

int yyerror( char *msg )
{
    fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
	fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
	fprintf( stderr, "|\n" );
	fprintf( stderr, "| Unmatched token: %s\n", yytext );
    fprintf( stderr, "|--------------------------------------------------------------------------\n" );
    exit(-1);
}

int  main( int argc, char **argv )
{
	setbuf(stdout, NULL);
	
	if( argc != 2 ) {
		fprintf(  stdout,  "Usage:  ./parser  [filename]\n"  );
		exit(0);
	}

	FILE *fp = fopen( argv[1], "r" );
	
	if( fp == NULL )  {
		fprintf( stdout, "Open  file  error\n" );
		exit(-1);
	}
	
	yyin = fp;
	yyparse();

	fprintf( stdout, "\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	fprintf( stdout, "|  There is no syntactic error!  |\n" );
	fprintf( stdout, "|--------------------------------|\n" );
	exit(0);
}
