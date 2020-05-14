%{
#include <stdio.h>
extern FILE *yyin;
void yyerror(const char* msg);
int yylex();
extern int currLine;
extern int currPos;
%}

%error-verbose

%token FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INT ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN MINUS PLUS MULT DIV MOD EQ NEQ LE GE LT GT SEMICOLON COMMA LPAREN RPAREN LBRACKET RBRACKET ASSIGN COLON NUMBER IDENT

%start program

%%

program:      functions 
                {printf("program -> functions\n");}
       ;
functions:    /*epsilon*/
                {printf("functions -> epsilon\n");}
         |    function functions
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
   |        IDENT COMMA ids
                {printf("ids -> IDENT COMMA ids\n");}
   ;
statements: statement SEMICOLON
                {printf("statements -> statement SEMICOLON\n");}
          |  statement SEMICOLON statements
                {printf("statements -> statement SEMICOLON statements\n");}
          ;
statement:  var ASSIGN expression
                {printf("statement -> var ASSIGN expression\n");}
        |   IF bool_expr THEN statements ENDIF
                {printf("statement -> IF bool-expr THEN statements endif\n");}
        |   IF bool_expr THEN statements ELSE statements ENDIF
                {printf("statement -> IF bool-expr THEN statements ELSE statements endif\n");}
        |   WHILE bool_expr BEGINLOOP statements ENDLOOP
                {printf("statement -> WHILE bool_expr BEGINLOOP statements ENDLOOP\n");}
        |   DO BEGINLOOP statements ENDLOOP WHILE bool_expr
                {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_expr\n");}
        |   FOR var ASSIGN NUMBER SEMICOLON bool_expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP
                {printf("statement -> FOR var ASSIGN NUMBER SEMICOLON bool_expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP\n");}
        |   READ vars
                {printf("statement -> READ vars\n");}
        |   WRITE vars
                {printf("statement -> WRITE vars\n");}
        |   CONTINUE
                {printf("statement -> CONTINUE\n");}
        |   RETURN expression
                {printf("statement -> RETURN expression\n");}
        ;
bool_expr:  relation_and_expr
         |  relation_and_expr OR bool_expr
                {printf("bool_expr -> relation_and_expr OR bool_expr\n");}
         ;
relation_and_expr:  relation_expr
                        {printf("relation_and_expr -> relation_expr\n");}
                 |  relation_expr AND relation_and_expr
                        {printf("relation_and_expr -> relation_expr AND relation-and-expr\n");}
                 ;
relation_expr:       expression comp expression
                        {printf("relation_expr -> optional_not expression comp expression\n");}
             |       NOT expression comp expression
                        {printf("relation_expr -> NOT expression comp expression\n");}
             |       TRUE
                        {printf("relation_expr -> TRUE\n");}
             |       NOT TRUE
                        {printf("relation_expr -> NOT TRUE\n");}            
             |       FALSE
                        {printf("relation_expr -> FALSE\n");}
             |       NOT FALSE
                        {printf("relation_expr -> NOT FALSE\n");}
             |       LPAREN bool_expr RPAREN
                        {printf("relation_expr -> LPAREN bool_expr RPAREN\n");}
             |       NOT LPAREN bool_expr RPAREN
                        {printf("relation_expr -> NOT LPAREN bool_expr RPAREN\n");}
             ;

comp:                EQ
                       {printf("comp -> EQ\n");} 
    |                NEQ
                       {printf("comp -> NEQ\n");} 
    |                LT
                       {printf("comp -> LT\n");} 
    |                GT
                       {printf("comp -> GT\n");} 
    |                LE
                       {printf("comp -> LE\n");} 
    |                GE
                       {printf("comp -> GE\n");}
    ;
expression:          multiplicative_expr
                        {printf("expression -> multiplicative_expr\n");}
          |          multiplicative_expr PLUS expression
                       {printf("expression -> multiplicative_expr PLUS expression\n");}
          |          multiplicative_expr MINUS expression
                        {printf("expression -> multiplicative_expr MINUS expression\n");}
          ;
multiplicative_expr:       term
                                {printf("multiplicative_expr -> term\n");}
                   |       term MULT multiplicative_expr
                                {printf("multiplicative_expr -> term MULT multiplicative_expr\n");}
                   |       term DIV multiplicative_expr
                                {printf("multiplicative_expr -> term DIV multiplicative_expr\n");}
                   |       term MOD multiplicative_expr
                                {printf("multiplicative_expr -> term MOD multiplicative_expr\n");}
                   ;
term:       num_term
                {printf("term -> optional_neg num_term\n");}
    |       id_term
                {printf("term -> id_term\n");}
    ;
num_term:     var
                {printf("num_term -> var\n");}
        |     MINUS var
                {printf("num_term -> MINUS var\n");}
        |     NUMBER
                {printf("num_term -> NUMBER\n");}
        |     MINUS NUMBER
                {printf("num_term -> MINUS NUMBER\n");}
        |     LPAREN expression RPAREN
                {printf("num_term -> LPAREN expression RPAREN\n");}
        |     MINUS LPAREN expression RPAREN
                {printf("num->term MINUS LPAREN expression RPAREN\n");}
        ;
id_term:      IDENT LPAREN expressions RPAREN
                {printf("id_term -> IDENT LPAREN expressions RPAREN\n");}
       ;
expressions:         /* eps */
                        {printf("expressions -> epsilon\n");}
           |         nonempty_expressions
                        {printf("expressions -> nonempty_expressions\n");}
           ;
nonempty_expressions: expression
                        {printf("nonempty-expressions -> expression\n");}
                    | expression COMMA nonempty_expressions
                        {printf("more_expressions -> COMMA expression more_expressions\n");}
                    ;
vars:       var
                {printf("vars -> var\n");}
    |       var COMMA vars
                {printf("vars -> var COMMA vars\n");}
    ;
var:       IDENT
                {printf("var -> IDENT\n");}
   |       IDENT brack_expr
                {printf("var -> IDENT brack_expr\n");}
   |       IDENT brack_expr brack_expr
                {printf("var -> IDENT brack_expr brack_expr\n");}
   ;
brack_expr: LBRACKET expression RBRACKET
                {printf("brack_expr -> LBRACKET expression RBRACKET\n");}
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
    printf("Error in line %d: %s, column %d\n", currLine, currPos, msg);
}
