/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    FUNCTION = 258,
    SEMICOLON = 259,
    IDENT = 260,
    NUMBER = 261,
    BEGINPARAMS = 262,
    ENDPARAMS = 263,
    BEGINLOCALS = 264,
    ENDLOCALS = 265,
    BEGINBODY = 266,
    ENDBODY = 267,
    COMMA = 268,
    COLON = 269,
    INT = 270,
    ARRAY = 271,
    LBRACKET = 272,
    RBRACKET = 273,
    OF = 274,
    ASSIGN = 275,
    IF = 276,
    THEN = 277,
    ELSE = 278,
    ENDIF = 279,
    WHILE = 280,
    BEGINLOOP = 281,
    ENDLOOP = 282,
    DO = 283,
    FOR = 284,
    READ = 285,
    WRITE = 286,
    CONTINUE = 287,
    RETURN = 288,
    OR = 289,
    AND = 290,
    NOT = 291,
    TRUE = 292,
    FALSE = 293,
    LPAREN = 294,
    RPAREN = 295,
    EQ = 296,
    NEQ = 297,
    LE = 298,
    GE = 299,
    LT = 300,
    GT = 301,
    PLUS = 302,
    MINUS = 303,
    MULT = 304,
    DIV = 305,
    MOD = 306
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
