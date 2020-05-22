%{
#include <stdio.h>
#include <memory.h>
#include <cstdlib>
#include<vector>
extern FILE *yyin;
void yyerror(const char* msg);
int yylex();
extern int currLine;
extern int currPos;

bool no_error = true;

struct dec_type {
    char* code;
    std::vector<char*> idList;
};

/*
struct idents {
    char* code;
    list<char*> l;
}
*/
%}

%error-verbose

%union yylval{
    char *s;
    struct dec_type *dec;
}

%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY 
%token INT IF ARRAY OF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE 
%token READ WRITE TRUE FALSE RETURN
%token SEMICOLON COMMA
%token COLON NUMBER <s>IDENT

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

%type<s> program functions function ident declaration statements statement 
%type<s> arr number ids
%type<dec> declarations

%%

start_program: program
                 {if(no_error) printf("%s\n", $1);}
             ;

program:      functions 
                {$$ = (char*)malloc(1 + strlen($1));
                 $$ = $1;
                }
         ;
functions:    /*epsilon*/
                {$$ = strdup("");
                }
         |    function functions
                {$$ = (char*)malloc(1 + strlen($1) + strlen($2));
                 strcpy($$, $1);
                 strncat($$, $2, strlen($2));
                }
         |    error functions
                {no_error = false; yyerrok;}
         ;
function:     FUNCTION ident SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY
                {$$ = (char*)malloc(1 + 5 + strlen($2) + 1 /* + strlen($5->code) + strlen($8->code) + strlen($11) */);
                 strcpy($$, "func ");
                 strncat($$, $2, strlen($2));
                 strncat($$, "\n", 1);
                 //strncat($$, $5->code, strlen($5->code));
                 //strncat($$, $8->code, strlen($8->code));
                 //strncat($$, $11, strlen($11));
                }
        ;
declarations: /* eps */
                {// $$->code = strdup(""); // FIXME: segfault???
                }
            | declaration SEMICOLON declarations
                {//$$->code = (char*)malloc(1 + strlen($1) /*+ 1 + strlen($3->code) + 1*/);
                 //strcpy($$->code, $1);
                 //strncat($$->code, "\n", 1);
                 //strncat($$->code, $3->code, strlen($3->code));
                 //strncat($$->code, "\n", 1);
                 //$$->code = "blah1";
                }
            | declaration error declarations
                {no_error = false; yyerrok;}
            | error SEMICOLON declarations
                {no_error = false; yyerrok;}
            | error '\n' declarations 
                {no_error = false; yyerrok;}
            ;
declaration:  ids INT
                {//$$ = (char*)malloc(3 + strlen($1) + 1);
                 //strcpy($$, ". ");
                 //strcat($$, $1);
                 //$$ = "blah";
                }
              | ids ARRAY arr OF INT
                {//$$ = (char*)malloc(4 + strlen($1) + 2 + strlen($3));
                 //strcpy($$, "[] ");
                 //strcat($$, $1);
                 //strcat($$, ", ");
                 //strcat($$, $3);
                }
              | ids ARRAY arr arr OF INT
                {//$$ = (char*)malloc(11);
                 //strcpy($$, "dec 2d arr");
                }
              ;
arr :       LBRACKET number RBRACKET
                {//$$ = "";
                }
    ;
ids:        ident COLON
                {$$ = strdup($1);}
   |        ident COMMA ids
                {//$$ = (char*)malloc(1 + strlen($1));
                 //strcpy($$, $1);
                }
   ;
statements: statement SEMICOLON
                {$$ = (char*)malloc(12);
                 $$ = strdup("statements\n");
                }
          |  statement SEMICOLON statements
                {$$ = (char*)malloc(22);
                 $$ = strdup("statement statements\n");}
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
        {$$ = $1;}
     ;

number: NUMBER
          {/*$$ = $1;*/}
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
