%{ // definition
    int currLine = 1; int currPos = 1;
%}
    
DIGIT   [0-9]
LETTER  [a-zA-Z]
ID      {LETTER}({LETTER}|{DIGIT}|"_"+({LETTER}|{DIGIT}))*
    
%%

"##".*          {/* do nothing. flex will not match newline with . */ }

"function"      {currPos += yyleng;}
"beginparams"   {currPos += yyleng;}
"endparams"     {currPos += yyleng;}
"beginlocals"   {currPos += yyleng;}
"endlocals"     {currPos += yyleng;}
"beginbody"     {currPos += yyleng;}
"endbody"       {currPos += yyleng;}
"integer"       {currPos += yyleng;}
"array"         {currPos += yyleng;}
"of"            {currPos += yyleng;}
"if"            {currPos += yyleng;}
"then"          {currPos += yyleng;}
"endif"         {currPos += yyleng;}
"else"          {currPos += yyleng;}
"while"         {currPos += yyleng;}
"do"            {currPos += yyleng;}
"for"           {currPos += yyleng;}
"beginloop"     {currPos += yyleng;}
"endloop"       {currPos += yyleng;}
"continue"      {currPos += yyleng;}
"read"          {currPos += yyleng;}
"write"         {currPos += yyleng;}
"and"           {currPos += yyleng;}
"or"            {currPos += yyleng;}
"not"           {currPos += yyleng;}
"true"          {currPos += yyleng;}
"false"         {currPos += yyleng;}
"return"        {currPos += yyleng;}
    
"-"     {currPos += yyleng;}
"+"     {currPos += yyleng;}
"*"     {currPos += yyleng;}
"/"     {currPos += yyleng;}
"%"     {currPos += yyleng;}

"=="    {currPos += yyleng;}
"<>"    {currPos += yyleng;}
"<="    {currPos += yyleng;}
">="    {currPos += yyleng;}
"<"     {currPos += yyleng;}
">"     {currPos += yyleng;}

";"     {currPos += yyleng;}
","     {currPos += yyleng;}
"("     {currPos += yyleng;}
")"     {currPos += yyleng;}
"["     {currPos += yyleng;}
"]"     {currPos += yyleng;}
":="    {currPos += yyleng;}
":"     {currPos += yyleng;}

({DIGIT}+|"_"+){ID}   {printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(0);}
{ID}"_"+                   {printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); exit(0);}

{DIGIT}+                  {printf("NUMBER %s\n", yytext); currPos += yyleng;}
{ID}                      {printf("IDENT %s\n", yytext); currPos += yyleng;}
    
"\n"    {currLine++; currPos = 1;}
    
[ \t]   {currPos += yyleng;}
    
.       {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}
    
%%
    
void main(int argc, char** argv) {
    if (argc >= 2) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            yyin = stdin;
        }
    }
    else {
        yyin = stdin;
    }
    yylex();
}
