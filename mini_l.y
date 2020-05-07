%{

%}

%token FUNCTION SEMICOLON IDENT BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY COMMA COLON INT ARRAY LBRACKET RBRACKET OF ASSIGN IF THEN ELSE ENDIF WHILE BEGINLOOP ENDLOOP DO FOR READ WRITE CONTINUE RETURN OR AND NOT TRUE FALSE LPAREN RPAREN EQ NEQ LE GE LT GT PLUS MINUS MULT DIV MOD

%start program

%%

program: functions 
            {printf("program->functions\n");}
functions: /*epsilon*/
            {printf("program->functions\n");}
        |   function functions

%%

int main(int argc, char** argv) {
    if (argc >= 2) {
        yyin = fopen(argv[1], "r");    
        if (yyin == NULL) {
            
        }
    }
}
