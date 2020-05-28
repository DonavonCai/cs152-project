%{
// for errors, @1, @2 for location
#include <iostream>
#include <stdio.h>
#include <cstdlib>
#include<vector>
#include "y.tab.h"

extern FILE *yyin;
void yyerror(const char* msg);
//int yylex();
extern int currLine;
extern int currPos;

bool no_error = true;

yy::parser::symbol_type yylex();
%}


%error-verbose

%code requires {
    #include<vector>
    #include<string>
    struct dec_type {
        std::string *code;
        enum types{SCALAR, ARR, ARRARR} type;
    };
}

%union yylval{
    std::string *st;
    dec_type *dec;
    std::vector<std::string*> *idList;
}

%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY 
%token INT IF ARRAY OF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE 
%token READ WRITE TRUE FALSE RETURN
%token SEMICOLON COMMA
%token COLON <st>NUMBER <st>IDENT

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

%type<st> program functions
%type<st> function ident declarations statements statement 
%type<st> arr number
%type<idList> ids
%type<dec> declaration

%%

start_program: program
                 {if(no_error) std::cout << *$1 << std::endl;}
             ;

program:      functions 
                {$$ = new std::string();
                 *$$ = *$1;
                }
         ;
functions:    /*epsilon*/
                {$$ = new std::string();
                 *$$ = "";
                } 
         |    function functions
                {$$ = new std::string();
                 *$$ = *$1 + " " + *$2;
                 if(*$2 != "")
                    *$$ += "\n";
                }
         |    error functions
                {no_error = false; yyerrok;}
         ;
function:     FUNCTION ident SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY
                {$$ = new std::string();
                 *$$ = "func ";
                 *$$ += *$2;
                 *$$ += "\n";
                 *$$ += *$5;
                 *$$ += *$8;
                 // *$$ += *$11;
                }
        ;
declarations: /* eps */
                {$$ = new std::string();
                 *$$ = "";
                }
            | declaration SEMICOLON declarations
                {$$ = new std::string();
                 if ($1 != NULL)
                   *$$ = *($1->code);

                 *$$ += *$3;
                }
            | declaration error declarations
                {no_error = false; yyerrok;}
            | error SEMICOLON declarations
                {no_error = false; yyerrok;}
            | error '\n' declarations 
                {no_error = false; yyerrok;}
            ;
declaration:  ids INT
                {$$ = (dec_type*)malloc(sizeof(dec_type));
                 $$->code = new std::string();
                 *$$->code = "";
                 // iterate through id list
                 for (int i = 0; i < $1->size(); i++) {
                    *$$->code += ". " + *($1->at(i)) + "\n";
                 }
                 $$->type = dec_type::SCALAR;
                }
              | ids ARRAY arr OF INT
                {$$ = (dec_type*)malloc(sizeof(dec_type));
                 $$->code = new std::string();
                 *$$->code = "";
                 for (int i = 0; i < $1->size(); i++) {
                    *$$->code += ".[] " + *($1->at(i)) + ", " + *$3 + "\n";
                 }
                 $$->type = dec_type::ARR;
                }
              | ids ARRAY arr arr OF INT
                {$$ = (dec_type*)malloc(sizeof(dec_type)); // TODO: implement 2d array
                 $$->type = dec_type::ARRARR;
                }
              ;
arr :       LBRACKET number RBRACKET
                {$$ = new std::string();
                 *$$ = *$2;
                }
    ;
ids:        ident COLON
                {$$ = new std::vector<std::string*>;
                 std::string *s = new std::string();
                 *s = *$1;
                 $$->push_back(s);
                }
   |        ident COMMA ids
                {$$ = new std::vector<std::string*>;
                 std::string*s = new std::string();
                 *s = *$1;
                 $$->push_back(s);
                 for (int i = 0; i < $3->size(); i++) {
                    $$->push_back($3->at(i));
                 }
                }
   ;
statements: statement SEMICOLON
                {
                }
          |  statement SEMICOLON statements
                {
                }
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
                {}
        |   IF bool_expr THEN statements ENDIF
                {}
        |   IF bool_expr THEN statements ELSE statements ENDIF
                {}
        |   WHILE bool_expr BEGINLOOP statements ENDLOOP
                {}
        |   DO BEGINLOOP statements ENDLOOP WHILE bool_expr
                {}
        |   FOR var ASSIGN number SEMICOLON bool_expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP
                {}
        |   READ vars
                {}
        |   WRITE vars
                {}
        |   CONTINUE
                {}
        |   RETURN expression
                {}
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
                        {}
           |         nonempty_expressions
                        {}
           ;

expression:          multiplicative_expr
                        {}
          |          multiplicative_expr PLUS expression
                       {}
          |          multiplicative_expr MINUS expression
                        {}
          ;
multiplicative_expr:       term
                                {}
                   |       term MULT multiplicative_expr
                                {}
                   |       term DIV multiplicative_expr
                                {}
                   |       term MOD multiplicative_expr
                                {}
                   ;
term:       num_term
                {}
    |       id_term
                {}
    ;
num_term:     var
                {}
        |     MINUS var %prec UMINUS
                {}
        |     number
                {}
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

nonempty_expressions: expression
                        {}
                    | expression COMMA nonempty_expressions
                        {}
                    ;
vars:       var
                {}
    |       var COMMA vars
                {}
    ;
var:       ident
                {}
   |       ident brack_expr
                {}
   |       ident brack_expr brack_expr
                {}
   ;
brack_expr: LBRACKET expression RBRACKET
                {}
          ;

ident: IDENT
        {$$ = new std::string();
         *$$ = *$1;
        }
     ;

number: NUMBER
          {$$ = new std::string();
           *$$ = *$1;
          }
      ;

%%

int main(int argc, char** argv) {
    if (argc >= 2) {
        yyin = fopen(argv[1], "r");    
        if (yyin == NULL) {
           yyin = stdin; 
        }
    }
    else {
        yyin = stdin;
    }

    yyparse();

    return 1;
}

void yyerror(const char* msg) {
    printf("Error in line %d: column %d: %s\n", currLine, currPos, msg);
}
