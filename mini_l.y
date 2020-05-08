%{
#include <stdio.h>
%}

%token FUNCTION SEMICOLON IDENT NUMBER BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY COMMA COLON INT ARRAY LBRACKET RBRACKET OF ASSIGN IF THEN ELSE ENDIF WHILE BEGINLOOP ENDLOOP DO FOR READ WRITE CONTINUE RETURN OR AND NOT TRUE FALSE LPAREN RPAREN EQ NEQ LE GE LT GT PLUS MINUS MULT DIV MOD

%start program

%%

program:      functions 
                {printf("program -> functions\n");}
;
functions:    /*epsilon*/
                {printf("functions -> epsilon\n");}
              | function functions
                {printf("functions -> function functions\n");}
;
function:     FUNCTION IDENT SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY
                {printf("functions -> FUNCTION IDENT SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY\n");}
;
declarations: /* eps */
                {printf("declarations -> epsilon\n");}
              | declaration SEMICOLON declarations
                {printf("declarations -> declaration SEMICOLON declarations\n");}
;
declaration:  ids COLON INT
                {printf("declaration -> ids COLON INT\n");}
              | ids COLON ARRAY arr OF INT
                {printf("declaration -> ids ARRAY arr OF INT\n");}
              | ids COLON ARRAY arr arr OF INT
                {printf("declaration -> ids ARRAY arr arr OF INT\n");}
;
arr :       LBRACKET NUMBER RBRACKET
                {printf("arr -> LBRACKET NUMBER RBRACKET\n");}
;
ids:        IDENT
                {printf("ids -> IDENT\n");}
            | IDENT COMMA ids
                {printf("ids -> IDENT COMMA ids\n");}
;

statements: statement SEMICOLON
                {printf("statements -> statement SEMICOLON\n");}
            | statement SEMICOLON statements
                {printf("statements -> statement SEMICOLON statements\n");}
;
statement:  var ASSIGN expression
                {printf("statement -> var ASSIGN expression\n");}
            | IF bool-expr THEN statements ENDIF
                {printf("statement -> IF bool-expr THEN statements endif\n");}
            | IF bool-expr THEN statements ELSE statements ENDIF
                {printf("statement -> IF bool-expr THEN statements ELSE statements endif\n");}
            | WHILE bool-expr BEGINLOOP statements ENDLOOP
                {printf"statement -> WHILE bool-expr BEGINLOOP statements ENDLOOP\n");}
            | DO BEGINLOOP statements ENDLOOP WHILE bool-expr
                {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool-expr\n");}
            | FOR var ASSIGN NUMBER SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP
                {printf("statement -> FOR var ASSIGN NUMBER SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP\n");}
            | READ vars
                {printf("statement -> READ vars\n");}
            | WRITE vars
                {printf("statement -> WRITE vars\n");}
            | CONTINUE
                {printf("statement -> CONTINUE\n");}
            | RETURN expression
                {printf("statement -> RETURN expression\n");}
;
bool-expr:  relation-and-expr
            | relation-and-expr OR bool-expr
                {printf("bool-expr -> relation-and-expr OR bool-expr\n");}
;

relation-and-expr:  relation-expr
                    | relation-expr AND relation-and-expr
                        {printf("relation-and-expr -> relation-expr AND relation-and-expr\n");}
;

relation-expr:       optional-not expression comp expression
                        {printf("relation-expr -> optional-not expression comp expression\n");}
                     | optional-not TRUE
                        {printf("relation-expr -> optional-not TRUE\n");}
                     | optional-not FALSE
                        {printf("relation-expr -> optional-not FALSE\n");}
                     | optional-not LPAREN bool-expr RPAREN
                        {printf("relation-expr -> optional-not LPAREN bool-expr RPAREN\n");}
;

optional-not:        /* eps */
                        {printf("optional-not -> epsilon\n");}
                     NOT
                        {printf("optional-not -> NOT\n");}
;

comp:                EQ
                       {printf("comp -> EQ\n");} 
                     | NEQ
                       {printf("comp -> NEQ\n");} 
                     | LT
                       {printf("comp -> LT\n");} 
                     | GT
                       {printf("comp -> GT\n");} 
                     | LE
                       {printf("comp -> LE\n");} 
                     | GE
                       {printf("comp -> GE\n");}
;
expression:          multiplicative-expr
                        {printf("expression -> multiplicative-expr\n");}
                     | multiplicative-expr PLUS expression
                        {printf("expression -> multiplicative-expr PLUS expression\n");}
                     | multiplicative-expr MINUS expression
                        {printf("expression -> multiplicative-expr MINUS expression\n");}
;

multiplicative-expr:       term
                                {printf("multiplicative-expr -> term\n");}
                           | term MULT multiplicative-expr
                                {printf("multiplicative-expr -> term MULT multiplicative-expr\n");}
                           | term DIV multiplicative-expr
                                {printf("multiplicative-expr -> term DIV multiplicative-expr\n");}
                           | term MOD multiplicative-expr
                                {printf("multiplicative-expr -> term MOD multiplicative-expr\n");}
;

term:       num-term
                {printf("term -> optional-neg num-term\n");}
            | id-term
                {printf("term -> id-term\n");}
;

num-term:     var
                {printf("num-term -> var\n");}
              | MINUS var
                {printf("num-term -> MINUS var\n");}
              | NUMBER
                {printf("num-term -> NUMBER\n");}
              | MINUS NUMBER
                {printf("num-term -> MINUS NUMBER\n");}
              | LPAREN expression RPAREN
                {printf("num-term -> LPAREN expression RPAREN\n");}
              | MINUS LPAREN expression RPAREN
                {printf("num->term MINUS LPAREN expression RPAREN\n");}
;
id-term:      IDENT LPAREN expressions RPAREN
                {printf("id-term -> IDENT LPAREN expressions RPAREN\n");}
;
expressions:         /* eps */
                        {printf("expressions -> epsilon\n");}
                     | nonempty-expressions
                        {printf("expressions -> nonempty-expressions\n");}
;

nonempty-expressions: expression
                        {printf("nonempty-expressions -> expression\n");}
                      | expression COMMA nonempty-expressions
                        {printf("more-expressions -> COMMA expression more-expressions\n");}
;
vars:       var
            | var COMMA vars
                {printf("vars -> var COMMA vars\n");}
;

var:       IDENT
                {printf("var -> IDENT\n");}
           | IDENT brack-expr
                {printf("var -> IDENT brack-expr\n");}
           | IDENT brack-expr brack-expr
                {printf("var -> IDENT brack-expr brack-expr\n");}
;
brack-expr: LBRACKET expression RBRACKET
                {printf("brack-expr -> LBRACKET expression RBRACKET\n");}
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
