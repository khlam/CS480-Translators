%{
#include <iostream>
#include <stack>
#include <cstdlib>
#include "parser.hpp"

using namespace std;
YYSTYPE yylval;
YYLTYPE yylloc;
yypstate* pstate = yypstate_new();
std::stack<int> _indent_stack;

#define PUSH_TOKEN(token) do {  \
  int s = yypush_parse(pstate, token, &yylval, &yylloc);  \
  if (s != YYPUSH_MORE) {                                 \
    yypstate_delete(pstate);                              \
    return s;                                             \
  }                                                       \
} while(0)

%}

%option noyywrap
%option yylineno

%%

%{
  /* Init indent stack */
  if (_indent_stack.empty()) {
    _indent_stack.push(0);
  }
%}

^[ \t]*\r?\n    { /* Skip blank lines */ }
^[ \t]*#.*\r?\n { /* Skip whole-line comments. */ }
#.*$            { /* Skip comments on the same line as a statement. */ }

^[ \t]+   {
            if (_indent_stack.top() < yyleng) {
              PUSH_TOKEN(INDENT);

              _indent_stack.push(yyleng);
            } else {

              while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
                _indent_stack.pop();
                
                PUSH_TOKEN(DEDENT);
              }

              if (_indent_stack.empty()) {
                std::cerr << "Error: Incorrect indentation on line "
                  << yylineno << std::endl;
                return 1;
              }
            }
          }

^[^ \t\n]+    {
                while(_indent_stack.top() != 0) {
                  _indent_stack.pop();
                  PUSH_TOKEN(DEDENT);
                }
                REJECT;
              }

\r?\n     { PUSH_TOKEN(NEWLINE); }

<<EOF>>   { while(_indent_stack.top() != 0) {
              _indent_stack.pop();
              PUSH_TOKEN(DEDENT);
            }
            int s = yypush_parse(pstate, 0, NULL, NULL);
            yypstate_delete(pstate);
            return s;
          }

[ \t]       { /* Ignore spaces that haven't been handled above. */ }

"and"       { PUSH_TOKEN(AND); }
"break"     { PUSH_TOKEN(BREAK); }
"def"       { PUSH_TOKEN(DEF); }
"elif"      { PUSH_TOKEN(ELIF); }
"else"      { PUSH_TOKEN(ELSE); }
"for"       { PUSH_TOKEN(FOR); }
"if"        { PUSH_TOKEN(IF); }
"not"       { PUSH_TOKEN(NOT); }
"or"        { PUSH_TOKEN(OR); }
"return"    { PUSH_TOKEN(RETURN); }
"while"     { PUSH_TOKEN(WHILE); }
"True"      { PUSH_TOKEN(TRUE); }
"False"     { PUSH_TOKEN(FALSE); }

[a-zA-Z_][a-zA-Z0-9_]*  { 
                          yylval.str = new std::string(yytext, yyleng);
                          PUSH_TOKEN(IDENTIFIER);
                        }

-?[0-9]*"."[0-9]+       { 
                          yylval.str = new std::string(yytext, yyleng);
                          PUSH_TOKEN(FLOAT);
                        }

-?[0-9]+      { 
                yylval.str = new std::string(yytext, yyleng);
                PUSH_TOKEN(INTEGER);
              }

"="   { PUSH_TOKEN(ASSIGN); }
"+"   { PUSH_TOKEN(PLUS); }
"-"   { PUSH_TOKEN(MINUS); }
"*"   { PUSH_TOKEN(TIMES); }
"/"   { PUSH_TOKEN(DIVIDEDBY); }
"=="  { PUSH_TOKEN(EQ); }
"!="  { PUSH_TOKEN(NEQ); }
">"   { PUSH_TOKEN(GT); }
">="  { PUSH_TOKEN(GTE); }
"<"   { PUSH_TOKEN(LT); }
"<="  { PUSH_TOKEN(LTE); }
"("   { PUSH_TOKEN(LPAREN); }
")"   { PUSH_TOKEN(RPAREN); }
","   { PUSH_TOKEN(COMMA); }
":"   { PUSH_TOKEN(COLON); }


.     {
        std::cerr << "Unrecognized token on line " << yylineno << ": " << yytext << std::endl;
        return 1;
      }


%%
