%{ // definition
#include "y.tab.h"
    int currLine = 1; int currPos = 1;
%}
    
DIGIT   [0-9]
LETTER  [a-zA-Z]
ID      {LETTER}({LETTER}|{DIGIT}|"_"+({LETTER}|{DIGIT}))*
    
%%

"##".*          {/* do nothing. flex will not match newline with . */ }

"function"      {currPos += yyleng; return FUNCTION;}
"beginparams"   {currPos += yyleng; return BEGINPARAMS;}
"endparams"     {currPos += yyleng; return ENDPARAMS;}
"beginlocals"   {currPos += yyleng; return BEGINLOCALS;}
"endlocals"     {currPos += yyleng; return ENDLOCALS;}
"beginbody"     {currPos += yyleng; return BEGINBODY;}
"endbody"       {currPos += yyleng; return ENDBODY;}
"integer"       {currPos += yyleng; return INT;}
"array"         {currPos += yyleng; return ARRAY;}
"of"            {currPos += yyleng; return OF;}
"if"            {currPos += yyleng; return IF;}
"then"          {currPos += yyleng; return THEN;}
"endif"         {currPos += yyleng; return ENDIF;}
"else"          {currPos += yyleng; return ELSE;}
"while"         {currPos += yyleng; return WHILE;}
"do"            {currPos += yyleng; return DO;}
"for"           {currPos += yyleng; return FOR;}
"beginloop"     {currPos += yyleng; return BEGINLOOP;}
"endloop"       {currPos += yyleng; return ENDLOOP;}
"continue"      {currPos += yyleng; return CONTINUE;}
"read"          {currPos += yyleng; return READ;}
"write"         {currPos += yyleng; return WRITE;}
"and"           {currPos += yyleng; return AND;}
"or"            {currPos += yyleng; return OR;}
"not"           {currPos += yyleng; return NOT;}
"true"          {currPos += yyleng; return TRUE;}
"false"         {currPos += yyleng; return FALSE;}
"return"        {currPos += yyleng; return RETURN;}
    
"-"     {currPos += yyleng; return MINUS;}
"+"     {currPos += yyleng; return PLUS;}
"*"     {currPos += yyleng; return MULT;}
"/"     {currPos += yyleng; return DIV;}
"%"     {currPos += yyleng; return MOD;}

"=="    {currPos += yyleng; return EQ;}
"<>"    {currPos += yyleng; return NEQ;}
"<="    {currPos += yyleng; return LE;}
">="    {currPos += yyleng; return GE;}
"<"     {currPos += yyleng; return LT;}
">"     {currPos += yyleng; return GT;}

";"     {currPos += yyleng; return SEMICOLON;}
","     {currPos += yyleng; return COMMA;}
"("     {currPos += yyleng; return LPAREN;}
")"     {currPos += yyleng; return RPAREN;}
"["     {currPos += yyleng; return LBRACKET;}
"]"     {currPos += yyleng; return RBRACKET;}
":="    {currPos += yyleng; return ASSIGN;}
":"     {currPos += yyleng; return COLON;}

{DIGIT}+                  {currPos += yyleng; return NUMBER;}
{ID}                      {currPos += yyleng; return IDENT;}

({DIGIT}+|"_"+){ID}   {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(0);}
{ID}"_"+                   {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); exit(0);}
   
"\n"    {currLine++; currPos = 1;}
    
[ \t]   {currPos += yyleng;}
    
.       {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}
    
%%

