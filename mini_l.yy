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
    std::string local_code;
    std::string param_code;
    enum types{SCALAR, ARR, ARRARR} type;
};

struct temporary {
    std::string temp;
    std::string eval;
    enum types{INT, ARRAY, MATRIX} type;
    std::string array_name;
    std::string idx;
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

/* 0 = scalar, 1 = array name, 2 = function name, (id, type) pairs */
std::map<std::string, int> symbol_table;

/* table of 2d arrays, (id, rowsize) pairs 
   used for calculating indices when array is accessed */
std::map<std::string, int> array_table;

/* table of function names*/
std::vector<std::string> func_table;

/* list of labels */
std::vector<std::string> labels;

/* take in coords [n][m] for matrix, return the corresponding row-major order index for existing matrix a
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

int numParams = 0;
int numTemps = 0;
std::string new_temp() {
    numTemps++;
    std::string temp = "__temp__";
    temp += std::to_string(numTemps);
    symbol_table[temp] = 0;

    return temp;
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
%type<std::string> ident statements statement

%type<temporary> expression multiplicative_expr term num_term id_term var brack_expr
%type<int> number arr
%type<std::vector<std::string>> ids
%type<std::vector<temporary>> vars expressions nonempty_expressions
%type<dec_type> declaration declarations
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
                {$$ = $1;}
         ;
functions:    /*epsilon*/
                {$$ = "";} 
         |    function functions
                {$$ = $1;
                 $$ += $2;
                }
         |    error functions
                {no_error = false; yyerrok;}
         ;
function:     FUNCTION ident SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY
                {func_table.push_back($2);
                 $$ = "func ";
                 $$ += $2 + "\n";
                 $$ += $5.local_code;
                 $$ += $5.param_code;
                 numParams = 0; // reset number of params after compiling param code for this function
                 $$ += $8.local_code;
                 $$ += $11;
                 $$ += "endfunc\n";
                }
        ;
declarations: /* eps */
                {$$.local_code = $$.param_code  = "";}
            | declaration SEMICOLON declarations
                {$$.local_code = $1.local_code;
                 $$.param_code = $1.param_code;
                 $$.local_code += $3.local_code;
                 $$.param_code += $3.param_code;
                }
            | declaration error declarations
                {no_error = false; yyerrok;}
            | error SEMICOLON declarations
                {no_error = false; yyerrok;}
            | error '\n' declarations 
                {no_error = false; yyerrok;}
            ;
declaration:  ids INT
                {$$.local_code = "";
                 $$.param_code = "";
                 // iterate through id list
                 for (int i = 0; i < $1.size(); i++) {
                    $$.local_code += ". " + $1.at(i) + "\n";
                    $$.param_code += "= " + $1.at(i) + ", $" + std::to_string(numParams) + "\n"; // FIXME: multiple declarations in params is wrong
                    numParams++;
                    symbol_table[$1.at(i)] = INT;
                 }
                 $$.type = dec_type::SCALAR;
                }
              | ids ARRAY arr OF INT
                {$$.local_code = "";
                 for (int i = 0; i < $1.size(); i++) {
                    $$.local_code += ".[] " + $1.at(i) + ", " + std::to_string($3) + "\n";
                    symbol_table[$1.at(i)] = ARRAY;
                 }
                 $$.type = dec_type::ARR;
                }
              | ids ARRAY arr arr OF INT
                {$$.type = dec_type::ARRARR;
                 $$.local_code = "";
                 for(int i = 0; i < $1.size(); i++) {
                    $$.local_code += ".[] " + $1.at(i) + ", " + std::to_string($3 * $4) + "\n";
                    symbol_table[$1.at(i)] = MATRIX;
                    array_table[$1.at(i)] = ($3); // pass id and row size to array table
                 }
                }
              ;
arr :       LBRACKET number RBRACKET
                {$$ = $2;}
    ;
ids:        ident COLON
                {$$.push_back($1);}
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
                {$$ = $1 + $3;}
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
                {$$ = "";
                 if ($1.type == temporary::INT)
                    $$ += $1.eval; // first evaluate var

                 $$ += $3.eval; // and expression
                 if($1.type == temporary::INT) { // note: if expression is an array access (dst = src[i]), then expression evaluates to a temp. All array accessing in this case is done in eval.
                    $$ += "= " + $1.temp + ", " + $3.temp + "\n"; // if var is an int, then var.temp is the id of the var
                 }
                 else if ($1.type != temporary::INT){ // dst[i] = something. Again, if expression is an array access, a temp will be used.
                    $$ += "[]= " + $1.array_name + ", " + $1.idx + ", " + $3.temp + "\n";
                 }
                }
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
                {$$ = "";
                 for (int i = 0; i < $2.size(); i++) {
                    $$ += $2.at(i).eval; // evaluate var
                    $$ += ".< " + $2.at(i).temp + "\n"; // use var
                 }
                }
        |   WRITE vars
                {$$ = "";
                 for (int i = 0; i < $2.size(); i++) {
                    $$ += $2.at(i).eval;// evaluate var
                    $$ += ".> " + $2.at(i).temp + "\n"; // use var
                 }
                }
        |   CONTINUE
                {$$ = "";}
        |   RETURN expression
                {$$ = $2.eval;
                 $$ += "ret " + $2.temp + "\n";
                }
        ;
bool_expr:  relation_and_expr
                { }
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

comp: EQ
        {} 
    | NEQ
        {} 
    | LT
        {} 
    | GT
        {} 
    | LE
        {} 
    | GE
        {}
    ;

expressions:         /* eps */
                        {}
           |         nonempty_expressions
                        {$$ = $1;}
           ;

nonempty_expressions: expression
                        {$$.push_back($1);}
                    | expression COMMA nonempty_expressions
                        {$$.push_back($1);
                         for(int i = 0; i < $3.size(); i++) {
                            $$.push_back($3.at(i));
                         }
                        }
                    ;

expression:          multiplicative_expr
                       {$$ = $1;}
          |          multiplicative_expr PLUS expression
                       {$$.temp = new_temp();

                        $$.eval = $1.eval; // evaluate multiplicative_expr
                        $$.eval += $3.eval; // evaluate expression

                        $$.eval += ". " + $$.temp + "\n"; // declare new temp
                        $$.eval += "+ " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
          |          multiplicative_expr MINUS expression
                       {$$.temp = new_temp();
                        $$.eval = $1.eval;
                        $$.eval += $3.eval;
                        $$.eval += ". " + $$.temp + "\n"; // symbol table is updated in new_temp();
                        $$.eval += "- " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
          ;
multiplicative_expr: term
                       {$$.temp = $1.temp;
                        $$.eval = $1.eval;
                       }
                   | term MULT multiplicative_expr
                       {$$.temp = new_temp();
                        $$.eval = $3.eval; // evaluate multiplicative_expr
                        $$.eval += ". " + $$.temp + "\n"; // declare new temp
                        $$.eval += "* " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
                   | term DIV multiplicative_expr
                       {$$.temp = new_temp();
                        $$.eval = $3.eval; // evaluate multiplicative_expr
                        $$.eval += ". " + $$.temp + "\n"; // declare new temp
                        $$.eval += "/ " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
                   | term MOD multiplicative_expr
                       {$$.temp = new_temp();
                        $$.eval = $3.eval; // evaluate multiplicative_expr
                        $$.eval += ". " + $$.temp + "\n"; // declare new temp
                        $$.eval += "% " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
                   ;
term:       num_term
                {$$ = $1;}
    |       id_term
                {$$ = $1;}
    ;
num_term:     var
                {$$ = $1;}
        |     MINUS var %prec UMINUS
                {$$.temp = new_temp();
                 $$.type = $2.type;
                 $$.eval = $2.eval; // evaluate var
                 $$.eval += ". " + $$.temp + "\n"; // declare new temp
                 $$.eval += "- " + $$.temp + ", 0, " + $2.temp + "\n"; // create instruction
                }
        |     number
                {$$.temp = std::to_string($1);
                 $$.eval = "";
                }
        |     MINUS number %prec UMINUS
                {$$.temp = new_temp();
                 $$.eval = ". " + $$.temp + "\n";
                 $$.eval += "- " + $$.temp + ", 0, " + std::to_string($2) + "\n";
                }
        |     LPAREN expression RPAREN
                {$$ = $2;}
        |     MINUS LPAREN expression RPAREN %prec UMINUS
                {$$.temp = new_temp();
                 $$.type = $3.type;
                 $$.eval = $3.eval; // first evaluate the expression
                 $$.eval += ". " + $$.temp + "\n"; // then declare a new temp
                 $$.eval += "- " + $$.temp + ", 0, " + $3.temp + "\n"; // then do 0 - expression and store it in the new temp
                }
        ;
id_term:      ident LPAREN expressions RPAREN
                {$$.temp = new_temp();// function call
                 $$.eval = ". " + $$.temp + "\n";
                 for (int i = 0; i < $3.size(); i++) {
                    $$.eval += $3.at(i).eval; // first evaluate expressions
                    $$.eval += "param " + $3.at(i).temp + "\n"; // add all evaluated expressions to queue of params
                 }
                 $$.eval += "call " + $1 + ", " + $$.temp + "\n"; // call the function and store it in temp
                }
       ;

vars:       var
               {$$.push_back($1);}
    |       var COMMA vars
               {$$.push_back($1);
                for (int i = 0; i < $3.size(); i++) {
                    $$.push_back($3.at(i));
                }
               }
    ;
var:       ident
               {$$.type = temporary::INT;
                $$.temp = $1;
                $$.eval = "";
               }
   |       ident brack_expr
               {$$.type = temporary::ARRAY;
                $$.temp = new_temp();// 1d array access
                $$.array_name = $1;
                $$.idx = $2.temp;

                $$.eval = $2.eval; // evaluation of an array access is to create a new temporary
                
                $$.eval += ". " + $$.temp + "\n";
                $$.eval += "=[] " + $$.temp + ", " + $1 + ", " + $$.idx + "\n";
               }
   |       ident brack_expr brack_expr
               {$$.type = temporary::MATRIX;// 2d array access
                int n = std::stoi($2.temp);
                int m = std::stoi($3.temp);

                $$.temp = new_temp();
                $$.array_name = $1;
                $$.idx = std::to_string(row_major($1, n, m));

                $$.eval = $2.eval + $3.eval; // first evaluate bracket expression

                $$.eval += ". " + $$.temp + "\n";
                $$.eval += "=[] " + $$.temp + ", " + $1 + ", " + $$.idx + "\n";
               }
   ;
brack_expr: LBRACKET expression RBRACKET
                {$$ = $2;}
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
