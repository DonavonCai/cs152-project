%token FUNCTION SEMICOLON IDENT NUMBER

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
