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
    std::string declare;
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

int numParams = 0; // number of parameters in the current function
int numTemps = 0;
std::string new_temp() {
    numTemps++;
    std::string temp = "__temp__" + std::to_string(numTemps);

    return temp;
}

int numLabels = 0;
std::string new_label() {
    numLabels++;
    std::string label = "__label__" + std::to_string(numLabels);

    return label;
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
%type<std::string> ident statements statement comp

%type<temporary> expression multiplicative_expr term num_term id_term var brack_expr
%type<temporary> bool_expr relation_expr relation_and_expr
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
                    $$.param_code += "= " + $1.at(i) + ", $" + std::to_string(numParams) + "\n";
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
                 if ($1.type == temporary::INT) { // the declaration and eval for an array creates a new temp. Not what we want if the array is the lhs of the operation.
                    $$ += $1.declare; // only need to declare, nothing to evaluate
                 }

                 $$ += $3.declare;
                 $$ += $3.eval;
                 if($1.type == temporary::INT) { // note: int = expression. $3.temp can be either an int or an array access temp
                    $$ += "= " + $1.temp + ", " + $3.temp + "\n";
                 }
                 else if ($1.type != temporary::INT){ // dst[i] = expression. Again, if expression is an array access, a temp will be used.
                    $$ += "[]= " + $1.array_name + ", " + $1.idx + ", " + $3.temp + "\n";
                 }
                }
        |   IF bool_expr THEN statements ENDIF
                {$$ = "";
                 std::string begin = new_label();
                 std::string end = new_label();

                 $$ += $2.declare;
                 $$ += ": " + begin + "\n";
                 $$ += $2.eval;
                 $$ += "! " + $2.temp + ", " + $2.temp + "\n"; // logical not to make sure that goto end if predicate is NOT true
                 $$ += "?:= " + end + ", " + $2.temp  + "\n";// if bool_expr == 0 GOTO end
                 $$ += $4;
                 $$ += ": " + end + "\n";
                }
        |   IF bool_expr THEN statements ELSE statements ENDIF
                {$$ = "";
                 // bool_expr temp declare
                 // begin
                 // bool_expr eval
                 // if bool_expr == 0 goto else
                 // statements1.code
                 // goto end
                 // else
                 // statements2.code
                 // end
                }
        |   WHILE bool_expr BEGINLOOP statements ENDLOOP
                {$$ = "";
                 // bool_expr temp declare
                 // begin
                 // bool_expr eval
                 // if bool_expr == 0 goto end
                 // statements.code
                 // goto begin
                 // end
                }
        |   DO BEGINLOOP statements ENDLOOP WHILE bool_expr
                {$$ = "";
                 // bool_expr temp declare
                 // begin
                 // statements.code
                 // bool_expr.eval
                 // if bool_expr == 1 goto begin
                 // end
                }
        |   FOR var ASSIGN number SEMICOLON bool_expr SEMICOLON var ASSIGN expression BEGINLOOP statements ENDLOOP
                {$$ = "";}
        |   READ vars
                {$$ = "";
                 for (int i = 0; i < $2.size(); i++) {
                    $$ += $2.at(i).declare;
                    $$ += $2.at(i).eval; // evaluate var
                    $$ += ".< " + $2.at(i).temp + "\n"; // use var
                 }
                }
        |   WRITE vars
                {$$ = "";
                 for (int i = 0; i < $2.size(); i++) {
                    $$ += $2.at(i).declare;
                    $$ += $2.at(i).eval;
                    $$ += ".> " + $2.at(i).temp + "\n";
                 }
                }
        |   CONTINUE
                {$$ = "";}
        |   RETURN expression
                {$$ = $2.declare;
                 $$ += $2.eval;
                 $$ += "ret " + $2.temp + "\n";
                }
        ;
bool_expr:  relation_and_expr
                {$$ = $1;}
         |  relation_and_expr OR bool_expr
                {$$.temp = new_temp();
                 $$.declare = $1.declare + $3.declare;
                 $$.declare += ". " + $$.temp + "\n";

                 $$.eval = $1.eval + $3.eval;
                 $$.eval += "|| " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                }
         ;
relation_and_expr:  relation_expr
                        {$$ = $1;}
                 |  relation_expr AND relation_and_expr
                        {$$.temp = new_temp();
                         $$.declare = $1.declare + $3.declare;
                         $$.declare += ". " + $$.temp + "\n";

                         $$.eval = $1.eval + $3.eval;
                         $$.eval += "&& " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                        }
                 ;
relation_expr:       expression comp expression
                        {$$.temp = new_temp();
                         $$.declare = $1.declare + $3.declare;
                         $$.declare += ". " + $$.temp + "\n";

                         $$.eval = $1.eval + $3.eval;
                         $$.eval += $2 + " " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n"; 
                        }
             |       NOT expression comp expression
                        {$$.temp = new_temp();
                         $$.declare = $2.declare + $4.declare;
                         $$.declare += ". " + $$.temp + "\n";

                         $$.eval = $2.eval + $4.eval;
                         $$.eval += $3 + " " + $$.temp + ", " + $2.temp + ", " + $4.temp + "\n"; 
                         $$.eval += "! " + $$.temp + ", " + $$.temp + "\n";
                        }
             |       TRUE
                        {$$.temp = new_temp();;
                         $$.declare = ". " + $$.temp + "\n";
                         $$.eval = "= " + $$.temp + ", 1\n" ;
                        }
             |       NOT TRUE
                        {$$.temp = new_temp();
                         $$.declare = ". " + $$.temp + "\n";
                         $$.eval = "= " + $$.temp + ", 0\n";
                        }            
             |       FALSE
                        {$$.temp = new_temp();
                         $$.declare = ". " + $$.temp + "\n";
                         $$.eval = "= " + $$.temp + ", 0\n";
                        }
             |       NOT FALSE
                        {$$.temp = new_temp();
                         $$.declare = ". " + $$.temp + "\n";
                         $$.eval = "= " + $$.temp + ", 1\n";
                        }
             |       LPAREN bool_expr RPAREN
                        {$$ = $2;}
             |       NOT LPAREN bool_expr RPAREN
                        {$$.temp = new_temp();
                         $$.declare = $3.declare;
                         $$.eval = $3.eval;

                         $$.declare += ". " + $$.temp + "\n";
                         $$.eval += "! " + $$.temp + ", " + $3.temp + "\n";
                        }
             ;

comp: EQ
        {$$ = "==";} 
    | NEQ
        {$$ = "!=";} 
    | LT
        {$$ = "<";} 
    | GT
        {$$ = ">";} 
    | LE
        {$$ = "<=";} 
    | GE
        {$$ = ">=";}
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
                        $$.declare = $1.declare + $3.declare;
                        $$.declare += ". " + $$.temp + "\n"; // declare new temp

                        $$.eval = $1.eval + $3.eval;
                        $$.eval += "+ " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
          |          multiplicative_expr MINUS expression
                       {$$.temp = new_temp();
                        $$.declare = $1.declare + $3.declare;
                        $$.declare += ". " + $$.temp + "\n";

                        $$.eval = $1.eval + $3.eval;
                        $$.eval += "- " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
          ;
multiplicative_expr: term
                       {$$ = $1;}
                   | term MULT multiplicative_expr
                       {$$.temp = new_temp();
                        $$.declare = $1.declare + $3.declare; // evaluate terms and expression
                        $$.declare += ". " + $$.temp + "\n"; // declare new temp

                        $$.eval = $1.eval + $3.eval; // evaluate term and multiplicative_expr
                        $$.eval += "* " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
                   | term DIV multiplicative_expr
                       {$$.temp = new_temp();
                        $$.declare = $1.declare + $3.declare;
                        $$.declare += ". " + $$.temp + "\n"; // declare new temp

                        $$.eval = $1.eval + $3.eval; // evaluate multiplicative_expr 
                        $$.eval += "/ " + $$.temp + ", " + $1.temp + ", " + $3.temp + "\n";
                       }
                   | term MOD multiplicative_expr
                       {$$.temp = new_temp();
                        $$.declare = $1.declare + $3.declare;
                        $$.declare += ". " + $$.temp + "\n"; // declare new temp

                        $$.eval = $3.eval; // evaluate multiplicative_expr
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
                 $$.declare = $2.declare; // declare var temps
                 $$.declare += ". " + $$.temp + "\n"; // declare new temp

                 $$.eval = $2.eval; // evaluate var 
                 $$.eval += "- " + $$.temp + ", 0, " + $2.temp + "\n"; // create instruction
                }
        |     number
                {$$.temp = std::to_string($1);
                 $$.eval = $$.declare = "";
                }
        |     MINUS number %prec UMINUS
                {$$.temp = new_temp();
                 $$.declare = ". " + $$.temp + "\n";
                 $$.eval = "- " + $$.temp + ", 0, " + std::to_string($2) + "\n";
                }
        |     LPAREN expression RPAREN
                {$$ = $2;}
        |     MINUS LPAREN expression RPAREN %prec UMINUS
                {$$.temp = new_temp();
                 $$.type = $3.type;
                 $$.declare = $3.declare; // first declare temps for expression
                 $$.declare += ". " + $$.temp + "\n"; // then declare a new temp

                 $$.eval = $3.eval; // evaluate the expression
                 $$.eval += "- " + $$.temp + ", 0, " + $3.temp + "\n"; // then do 0 - expression and store it in the new temp
                }
        ;
id_term:      ident LPAREN expressions RPAREN
                {$$.temp = new_temp();// function call
                 $$.declare = "";
                 $$.eval = "";
                 for (int i = 0; i < $3.size(); i++) {
                    $$.declare += $3.at(i).declare;
                    $$.eval += $3.at(i).eval; // first evaluate expressions
                    $$.eval += "param " + $3.at(i).temp + "\n"; // add all evaluated expressions to queue of params
                 }
                 $$.declare += ". " + $$.temp + "\n";
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
                $$.eval = $$.declare = "";
               }
   |       ident brack_expr
               {$$.type = temporary::ARRAY;
                $$.temp = new_temp();// 1d array access
                $$.array_name = $1;
                $$.idx = $2.temp;

                $$.declare = $2.declare; // declare necessary temps for bracket expression
                $$.declare += ". " + $$.temp + "\n"; // also declare a new temp

                $$.eval = $2.eval; // evaluatte bracket expression
                $$.eval += "=[] " + $$.temp + ", " + $1 + ", " + $$.idx + "\n";
               }
   |       ident brack_expr brack_expr
               {$$.type = temporary::MATRIX;// 2d array access
                int n = std::stoi($2.temp);
                int m = std::stoi($3.temp);

                $$.temp = new_temp();
                $$.array_name = $1;
                $$.idx = std::to_string(row_major($1, n, m));

                $$.declare = $2.declare + $3.declare; // declare necessary temps for bracket expressions
                $$.declare += ". " + $$.temp + "\n"; // declare temp

                $$.eval = $2.eval + $3.eval; // evaluate bracket expression
                $$.eval += "=[] " + $$.temp + ", " + $1 + ", " + $$.idx + "\n"; // store in temp
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
