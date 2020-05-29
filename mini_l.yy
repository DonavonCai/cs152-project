%{
%}

%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose
%locations


%code requires
{
	/* you may need these header files 
	 * add more header file if you need more
	 */
#include <vector>
#include <string>
#include <functional>
	/* define the sturctures using as types for non-terminals */
struct dec_type {
    std::string code;
    enum type{SCALAR, ARR, ARRARR} type;
};
	/* end the structures for non-terminal types */
}


%code
{
#include "parser.tab.hh"

	/* you may need these header files 
	 * add more header file if you need more
	 */
#include <sstream>
#include <map>
#include <regex>
#include <set>
yy::parser::symbol_type yylex();

	/* define your symbol table, global variables,
	 * list of keywords or any function you may need here */
bool no_error = true;
enum symbol{INT, ARRAY, MATRIX, FUNC, KEYWORD};

/* symbol tables */

/* 0 = scalar, 1 = array name, 2 = function name */
std::map<std::string, int> symbol_table;

/* table of 2d arrays, goes from id to row size 
   used for calculating indices when array is accessed */
std::map<std::string, int> array_table;

/* take in coords [n][m] for matrix, return a single index for array stored in row major order
   idx is the nth entry in the mth row  */
int row_major(std::string a, int n, int m) {
    int idx = 0;
    int rsz = array_table[a];

    for(int i = 0; i < m; i++) {
        idx += rsz;
    }
    idx += n;

    return idx;
}
	/* end of your code */
}

%token END 0 "end of file";

	/* specify tokens, type of non-terminals and terminals here */
%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY 
%token INT IF ARRAY OF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE 
%token READ WRITE TRUE FALSE RETURN
%token SEMICOLON COMMA
%token COLON <int>NUMBER <std::string>IDENT

%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LE GT GE EQ NEQ
%left PLUS MINUS
%left MULT DIV MOD
%right UMINUS
%left LBRACKET RBRACKET
%left LPAREN RPAREN

%start start_program

%type<std::string> program functions function
%type<std::string> ident declarations statements statement
%type<std::string> expressions expression nonempty_expressions multiplicative_expr
%type<std::string> vars var term num_term
%type<int> number arr
%type<std::vector<std::string>> ids
%type<dec_type> declaration
	/* end of token specifications */

%%

start_program: program
                 { // TODO: errors to catch:
                 // 1. using undeclared var
                 // 2. calling undeclared function
                 // 3. not defining main function
                 // 4. defining var more than once
                 // 5. name a var a reserved keyword
                 // 6. forgetting to specify array index when using array var
                 // 7. specify array index when using regular int
                 // 8. declare array size <= 0
                 // 9. use continue outside of loop
                 if(no_error) std::cout << $1 << std::endl;}
             ;

program:      functions 
                {$$ = $1;
                }
         ;
functions:    /*epsilon*/
                {$$ = "";
                } 
         |    function functions
                {$$ = $1 + " " + $2;
                 $$ = $1 + " " + $2;
                 if($2 != "")
                    $$ += "\n";
                }
         |    error functions
                {no_error = false; yyerrok;}
         ;
function:     FUNCTION ident SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY
                { $$ = "func ";
                 $$ += $2;
                 if ($5 != "")
                    $$ += "\n";
                 $$ += $5;

                 if ($8 != "")
                    $$ += "\n";
                 $$ += $8;
                 $$ += "\n";
                 $$ += $11;
                 $$ += "\n";
                 $$ += "endfunc\n";
                }
        ;
declarations: /* eps */
                {$$ = "";
                }
            | declaration SEMICOLON declarations
                {$$ = $1.code;
                 $$ += $3;
                }
            | declaration error declarations
                {no_error = false; yyerrok;}
            | error SEMICOLON declarations
                {no_error = false; yyerrok;}
            | error '\n' declarations 
                {no_error = false; yyerrok;}
            ;
declaration:  ids INT
                {$$.code = "";
                 // iterate through id list
                 for (int i = 0; i < $1.size(); i++) {
                    $$.code += ". " + $1.at(i);
                    symbol_table[$1.at(i)] = INT;
                 }
                 $$.type = dec_type::SCALAR;
                }
              | ids ARRAY arr OF INT
                {$$.code = "";
                 for (int i = 0; i < $1.size(); i++) {
                    $$.code += ".[] " + $1.at(i) + ", " + std::to_string($3);
                    symbol_table[$1.at(i)] = ARRAY;
                 }
                 $$.type = dec_type::ARR;
                }
              | ids ARRAY arr arr OF INT
                {$$.type = dec_type::ARRARR;
                 $$.code = "";
                 for(int i = 0; i < $1.size(); i++) {
                    $$.code += ".[] " + $1.at(i) + ", " + std::to_string($3 * $4);
                    symbol_table[$1.at(i)] = MATRIX;
                    array_table[$1.at(i)] = ($3); // pass id and row size to array table
                 }
                }
              ;
arr :       LBRACKET number RBRACKET
                {$$ = $2;}
    ;
ids:        ident COLON
                {$$.push_back($1);
                }
   |        ident COMMA ids
                {$$.push_back($1);
                 for (int i = 0; i < $3.size(); i++) {
                    $$.push_back($3.at(i));
                 }
                }
   ;
statements: statement SEMICOLON
                {$$ = $1;}
          |  statement SEMICOLON statements
                {$$ = $1 + "\n" + $3;}
          |  statement error statements
                {no_error = false; yyerrok;}
          |  statement error
                {no_error = false; yyerrok;}
          |  error SEMICOLON statements
                {no_error = false; yyerrok;}
          |  error SEMICOLON
                {no_error = false; yyerrok;}
          |  error '\n' statements
                {no_error = false; yyerrok;}
          |  error '\n'
                {no_error = false; yyerrok;}
          ;
statement:  var ASSIGN expression
                {$$ = "= " + $1 + ", " + $3;}
        |   IF bool_expr THEN statements ENDIF
                {$$ = "";}
        |   IF bool_expr THEN statements ELSE statements ENDIF
                {$$ = "";}
        |   WHILE bool_expr BEGINLOOP statements ENDLOOP
                {$$ = "";}
        |   DO BEGINLOOP statements ENDLOOP WHILE bool_expr
                {$$ = "";}
        |   FOR var ASSIGN number SEMICOLON bool_expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP
                {$$ = "";}
        |   READ vars
                {$$ = "";}
        |   WRITE vars
                {$$ = "";}
        |   CONTINUE
                {$$ = "";}
        |   RETURN expression
                {$$ = "";}
        ;
bool_expr:  relation_and_expr
         |  relation_and_expr OR bool_expr
                { }
         ;
relation_and_expr:  relation_expr
                        {}
                 |  relation_expr AND relation_and_expr
                        {}
                 ;
relation_expr:       expression comp expression
                        {}
             |       NOT expression comp expression
                        {}
             |       TRUE
                        {}
             |       NOT TRUE
                        {}            
             |       FALSE
                        {}
             |       NOT FALSE
                        {}
             |       LPAREN bool_expr RPAREN
                        {}
             |       NOT LPAREN bool_expr RPAREN
                        {}
             ;

comp:                EQ
                       {} 
    |                NEQ
                       {} 
    |                LT
                       {} 
    |                GT
                       {} 
    |                LE
                       {} 
    |                GE
                       {}
    ;

expressions:         /* eps */
                        {$$ = "";}
           |         nonempty_expressions
                        {$$ = $1;}
           ;

nonempty_expressions: expression
                        {$$ = $1;}
                    | expression COMMA nonempty_expressions
                        {}
                    ;

expression:          multiplicative_expr
                       {$$ = $1;}
          |          multiplicative_expr PLUS expression
                       {}
          |          multiplicative_expr MINUS expression
                       {}
          ;
multiplicative_expr: term
                       {$$ = $1;}
                   | term MULT multiplicative_expr
                       {}
                   | term DIV multiplicative_expr
                       {}
                   | term MOD multiplicative_expr
                       {}
                   ;
term:       num_term
                {$$ = $1;}
    |       id_term
                {}
    ;
num_term:     var
                {$$ = $1;}
        |     MINUS var %prec UMINUS
                {}
        |     number
                {$$ = std::to_string($1);}
        |     MINUS number %prec UMINUS
                {}
        |     LPAREN expression RPAREN
                {}
        |     MINUS LPAREN expression RPAREN %prec UMINUS
                {}
        ;
id_term:      ident LPAREN expressions RPAREN
                {}
       ;

vars:       var
               {}
    |       var COMMA vars
               {}
    ;
var:       ident
               {$$ = $1;}
   |       ident brack_expr
               { // 1d array
               }
   |       ident brack_expr brack_expr
               { // 2d array
               }
   ;
brack_expr: LBRACKET expression RBRACKET
                {}
          ;

ident: IDENT
        {$$ = $1;}
     ;

number: NUMBER
          {$$ = $1;}
      ;


%%

int main(int argc, char *argv[])
{
	yy::parser p;
	return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m)
{
	std::cerr << l << ": " << m << std::endl;
}