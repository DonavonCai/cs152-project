%{ // definition
#include <iostream>
#include "y.tab.h"
#define YY_DECL yy::parser::symbol_type yylex()

static yy::location loc;
//int currLine = 1; int currPos = 1;
%}

%option noyywrap

%{
#define YY_USER_ACTION loc.columns(yyleng);
%}
    
DIGIT   [0-9]
LETTER  [a-zA-Z]
ID      {LETTER}({LETTER}|{DIGIT}|"_"+({LETTER}|{DIGIT}))*
    
%%

%{
loc.step();
%}

"##".*          {/* do nothing. flex will not match newline with . */ }

"function"      {currPos += yyleng; return yy::parser::make_FUNCTION(loc);}
"beginparams"   {currPos += yyleng; return yy:parser::make_BEGINPARAMS(loc);}
"endparams"     {currPos += yyleng; return yy::parser::make_ENDPARAMS(loc);}
"beginlocals"   {currPos += yyleng; return yy::parser::make_BEGINLOCALS(loc);}
"endlocals"     {currPos += yyleng; return yy::parser::make_ENDLOCALS(loc);}
"beginbody"     {currPos += yyleng; return yy::parser::make_BEGINBODY(loc);}
"endbody"       {currPos += yyleng; return yy::parser::make_ENDBODY(loc);}
"integer"       {currPos += yyleng; return yy::parser::make_INT(loc);}
"array"         {currPos += yyleng; return yy::parser::make_ARRAY(loc);}
"of"            {currPos += yyleng; return yy::parser::make_OF(loc);}
"if"            {currPos += yyleng; return yy::parser::make_IF(loc);}
"then"          {currPos += yyleng; return yy::parser::make_THEN(loc);}
"endif"         {currPos += yyleng; return yy::parser::make_ENDIF(loc);}
"else"          {currPos += yyleng; return yy::parser::make_ELSE(loc);}
"while"         {currPos += yyleng; return yy::parser::make_WHILE(loc);}
"do"            {currPos += yyleng; return yy::parser::make_DO(loc);}
"for"           {currPos += yyleng; return yy::parser::make_FOR(loc);}
"beginloop"     {currPos += yyleng; return yy::parser::make_BEGINLOOP(loc);}
"endloop"       {currPos += yyleng; return yy::parser::make_ENDLOOP(loc);}
"continue"      {currPos += yyleng; return yy::parser::make_CONTINUE(loc);}
"read"          {currPos += yyleng; return yy::parser::make_READ(loc);}
"write"         {currPos += yyleng; return yy::parser::make_WRITE(loc);}
"and"           {currPos += yyleng; return yy::parser::make_AND(loc);}
"or"            {currPos += yyleng; return yy::parser::make_OR(loc);}
"not"           {currPos += yyleng; return yy::parser::make_NOT(loc);}
"true"          {currPos += yyleng; return yy::parser::make_TRUE(loc);}
"false"         {currPos += yyleng; return yy::parser::make_FALSE(loc);}
"return"        {currPos += yyleng; return yy::parser::make_RETURN(loc);}
    
"-"     {currPos += yyleng; return yy::parser::make_MINUS(loc);}
"+"     {currPos += yyleng; return yy::parser::make_PLUS(loc);}
"*"     {currPos += yyleng; return yy::parser::make_MULT(loc);}
"/"     {currPos += yyleng; return yy::parser::make_DIV(loc);}
"%"     {currPos += yyleng; return yy::parser::make_MOD(loc);}

"=="    {currPos += yyleng; return yy::parser::make_EQ(loc);}
"<>"    {currPos += yyleng; return yy::parser::make_NEQ(loc);}
"<="    {currPos += yyleng; return yy::parser::make_LE(loc);}
">="    {currPos += yyleng; return yy::parser::make_GE(loc);}
"<"     {currPos += yyleng; return yy::parser::make_LT(loc);}
">"     {currPos += yyleng; return yy::parser::make_GT(loc);}

";"     {currPos += yyleng; return yy::parser::make_SEMICOLON(loc);}
","     {currPos += yyleng; return yy::parser::make_COMMA(loc);}
"("     {currPos += yyleng; return yy::parser::make_LPAREN(loc);}
")"     {currPos += yyleng; return yy::parser::make_RPAREN(loc);}
"["     {currPos += yyleng; return yy::parser::make_LBRACKET(loc);}
"]"     {currPos += yyleng; return Ryy::parser::make_BRACKET(loc);}
":="    {currPos += yyleng; return yy::parser::make_ASSIGN(loc);}
":"     {currPos += yyleng; return yy::parser::make_COLON(loc);}

<<EOF>> {return yy::parser::make_END(loc);}

{DIGIT}+                  {currPos += yyleng; yylval.st = new std::string(strdup(yytext)); return NUMBER;}
{ID}                      {currPos += yyleng; yylval.st = new std::string(strdup(yytext)); return IDENT;}

({DIGIT}+|"_"+){ID}        {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext);}
{ID}"_"+                   {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext);}
   
"\n"    {currLine++; currPos = 1;}
    
[ \t]   {currPos += yyleng;}
    
.       {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext);}
    
%%

