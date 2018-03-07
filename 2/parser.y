%{
#include <iostream>
#include <map>
#include <vector>
#include <algorithm>
#include "parser.hpp"

using namespace std;
vector<string> symb;
vector<string> opt;

void yyerror(YYLTYPE* loc, const char* err);
extern int yylex();
extern int yylineno;
%}

%union {
  std::string* str;
  int token;
}

%locations
%define api.pure full
%define api.push-pull push

%define parse.error verbose

%token <str> IDENTIFIER  FLOAT NUMBER TRUE FALSE
%token <token> EQUALS PLUS MINUS TIMES DIVIDEDBY NEWLINE
%token <token> LPAREN RPAREN COMMA COLON SEMICOLON
%token <token> EQ NEQ GT GTE LT LTE
%token <token> AND BREAK DEF ELIF ELSE FOR IF
%token <token> NOT OR RETURN WHILE INDENT DEDENT
%type  <str> expr value logical conditional stmt master conditionstart

%start program

%%

program: master       { opt.push_back(*$1); delete $1; }

master: stmt          { $$ = $1; }
        | master stmt { auto tmp = new string(*$$ + "\n" + *$2); 
                        delete $$, $1, $2;
                        $$ = tmp;
                      }
;

stmt: IDENTIFIER EQUALS expr NEWLINE                          { if (std::find(symb.begin(), symb.end(), *$1) == symb.end()){
                                                                  symb.push_back(*$1);
                                                                }
                                                                $$ = new string(*$1 + " = " + *$3 + ";");
                                                                delete $1, $3;
                                                              }
      | IF logical conditionstart conditional                 { $$ = new string("if (" + *$2 + ") {\n" + *$3 + *$4);
                                                                delete $2, $3, $4;
                                                              }
      | WHILE logical conditionstart DEDENT                   { $$ = new string("while (" + *$2 + ") {\n" + *$3 + "\n}");
                                                                delete $2, $3;
                                                              }
      | BREAK NEWLINE                                         { $$ = new string("break;"); }
;

conditional: DEDENT                                           { $$ = new string("\n}"); }
             | DEDENT ELSE conditionstart DEDENT              { $$ = new string("\n} else {\n" + *$3 + "\n}"); delete $3; }
;

conditionstart: COLON NEWLINE INDENT master                   { $$ = new string(*$4); delete $4; }

value:    NUMBER                 { $$ = $1; }
          | FLOAT                { $$ = $1; }
          | IDENTIFIER           { $$ = $1; }
          | TRUE                 { $$ = new string("true"); }
          | FALSE                { $$ = new string("false"); }
          | LPAREN expr RPAREN   { $$ = new string("(" + *$2 + ")"); delete $2;}
;

expr:     value                  { $$ = $1; }
          | expr PLUS expr       { $$ = new string(*$1 + " + " + *$3); delete $1, $3;}
          | expr MINUS expr      { $$ = new string(*$1 + " - " + *$3); delete $1, $3;}
          | expr TIMES expr      { $$ = new string(*$1 + " * " + *$3); delete $1, $3;}
          | expr DIVIDEDBY expr  { $$ = new string(*$1 + " / " + *$3); delete $1, $3;}
;

logical:  value                  { $$ = $1; }
          | NOT logical          { $$ = new string("!" + *$2); delete $2;}
          | logical AND logical  { $$ = new string(*$1 + " && " + *$3); delete $1, $3;}
          | logical OR logical   { $$ = new string(*$1 + " || " + *$3); delete $1, $3;}
          | logical EQ logical   { $$ = new string(*$1 + " == " + *$3); delete $1, $3;}
          | logical NEQ logical  { $$ = new string(*$1 + " != " + *$3); delete $1, $3;}
          | logical GT logical   { $$ = new string(*$1 + " > " + *$3); delete $1, $3;}
          | logical GTE logical  { $$ = new string(*$1 + " >= " + *$3); delete $1, $3;}
          | logical LT logical   { $$ = new string(*$1 + " < " + *$3); delete $1, $3;}
          | logical LTE logical  { $$ = new string(*$1 + " <= " + *$3); delete $1, $3;}
;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error: " << err << " on line "<< yylineno << std::endl;
}