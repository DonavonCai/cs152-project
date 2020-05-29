%{
#include <iostream>
#define YY_DECL yy::parser::symbol_type yylex()
#include "parser.tab.hh"

static yy::location loc;
%}

%option noyywrap 

%{
#define YY_USER_ACTION loc.columns(yyleng);
%}

	/* your definitions here */
DIGIT   [0-9]
LETTER  [a-zA-Z]
ID      {LETTER}({LETTER}|{DIGIT}|"_"+({LETTER}|{DIGIT}))*
 
	/* your definitions end */

%%

%{
loc.step(); 
%}

	/* your rules here */
"##".*          {/* do nothing. flex will not match newline with . */ }

	/* use this structure to pass the Token :
	 * return yy::parser::make_TokenName(loc)
	 * if the token has a type you can pass it's value
	 * as the first argument. as an example we put
	 * the rule to return token function.
	 */
"function"      {  return yy::parser::make_FUNCTION(loc);}
"beginparams"   {  return yy::parser::make_BEGINPARAMS(loc);}
"endparams"     {  return yy::parser::make_ENDPARAMS(loc);}
"beginlocals"   {  return yy::parser::make_BEGINLOCALS(loc);}
"endlocals"     {  return yy::parser::make_ENDLOCALS(loc);}
"beginbody"     {  return yy::parser::make_BEGINBODY(loc);}
"endbody"       {  return yy::parser::make_ENDBODY(loc);}
"integer"       {  return yy::parser::make_INT(loc);}
"array"         {  return yy::parser::make_ARRAY(loc);}
"of"            {  return yy::parser::make_OF(loc);}
"if"            {  return yy::parser::make_IF(loc);}
"then"          {  return yy::parser::make_THEN(loc);}
"endif"         {  return yy::parser::make_ENDIF(loc);}
"else"          {  return yy::parser::make_ELSE(loc);}
"while"         {  return yy::parser::make_WHILE(loc);}
"do"            {  return yy::parser::make_DO(loc);}
"for"           {  return yy::parser::make_FOR(loc);}
"beginloop"     {  return yy::parser::make_BEGINLOOP(loc);}
"endloop"       {  return yy::parser::make_ENDLOOP(loc);}
"continue"      {  return yy::parser::make_CONTINUE(loc);}
"read"          {  return yy::parser::make_READ(loc);}
"write"         {  return yy::parser::make_WRITE(loc);}
"and"           {  return yy::parser::make_AND(loc);}
"or"            {  return yy::parser::make_OR(loc);}
"not"           {  return yy::parser::make_NOT(loc);}
"true"          {  return yy::parser::make_TRUE(loc);}
"false"         {  return yy::parser::make_FALSE(loc);}
"return"        {  return yy::parser::make_RETURN(loc);}
    
"-"     {  return yy::parser::make_MINUS(loc);}
"+"     {  return yy::parser::make_PLUS(loc);}
"*"     {  return yy::parser::make_MULT(loc);}
"/"     {  return yy::parser::make_DIV(loc);}
"%"     {  return yy::parser::make_MOD(loc);}

"=="    {  return yy::parser::make_EQ(loc);}
"<>"    {  return yy::parser::make_NEQ(loc);}
"<="    {  return yy::parser::make_LE(loc);}
">="    {  return yy::parser::make_GE(loc);}
"<"     {  return yy::parser::make_LT(loc);}
">"     {  return yy::parser::make_GT(loc);}

";"     {  return yy::parser::make_SEMICOLON(loc);}
","     {  return yy::parser::make_COMMA(loc);}
"("     {  return yy::parser::make_LPAREN(loc);}
")"     {  return yy::parser::make_RPAREN(loc);}
"["     {  return yy::parser::make_LBRACKET(loc);}
"]"     {  return yy::parser::make_RBRACKET(loc);}
":="    {  return yy::parser::make_ASSIGN(loc);}
":"     {  return yy::parser::make_COLON(loc);}

{DIGIT}+                  {return yy::parser::make_NUMBER(atoi(yytext), loc);}
{ID}                      {return yy::parser::make_IDENT(yytext, loc);}
   
"\n"    {}
    
[ \t]   { }

 <<EOF>>	{return yy::parser::make_END(loc);}
	/* your rules end */

%%
