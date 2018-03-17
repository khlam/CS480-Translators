%{
#include <iostream>
#include <set>
#include "parser.hpp"
#include "ast.h"

using namespace std;

extern int yylex();
void yyerror(YYLTYPE* loc, const char* err);

Node *root = newNode("Block");
%}

%locations
%code requires{
#include "ast.h"
}
%union {
  std::string* str;
  Node *nodes;
  vector<Node *> *childs;
}

%define api.pure full
%define api.push-pull push

%token <str> IDENTIFIER FLOAT INTEGER TRUE FALSE
%type <nodes> primary_expression negated_expression

%token <nodes> INDENT DEDENT NEWLINE
%token <nodes> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <nodes> ASSIGN PLUS MINUS TIMES DIVIDEDBY
%token <nodes> EQ NEQ GT GTE LT LTE
%token <nodes> LPAREN RPAREN COMMA COLON
%type <nodes> statement expression assign_statement 
%type <childs> statements
%type <nodes> if_statement elif_blocks else_block condition 
%type <nodes> block while_statement break_statement

%left OR
%left AND
%left PLUS MINUS
%left TIMES DIVIDEDBY
%left EQ NEQ GT GTE LT LTE
%right NOT

/*
Type            Statements
0               assignment
1               if
2               while
3               
4               block
5               else
6               while
7               break
*/

%start program
%%

program: statements { root->childs = *$1; root->type = 4;}
  ;

statements: statement             { $$ = new vector <Node *> ({$1}); }
          | statements statement  { $1->push_back($2);
                                    $$ = $1;    
                                  }
  ;

statement: assign_statement { $$ = $1; }
          | if_statement    { $$ = $1; }
          | while_statement { $$ = $1; }
          | break_statement { $$ = $1; }
  ;

primary_expression: IDENTIFIER                { Node *tempNew = newNode("Identifier: ", *$1);
                                                $$ = tempNew;
                                              }
                  | FLOAT                     { Node *tempNew = newNode("Float: ", *$1);
                                                $$ = tempNew;
                                              }
                  | INTEGER                   { Node *tempNew = newNode("Integer: ", *$1);
                                                $$ = tempNew;
                                              }
                  | TRUE                      { Node *tempNew = newNode("Boolean: ", "1");
                                                $$ = tempNew;
                                              }
                  | FALSE                     { Node *tempNew = newNode("Boolean: ", "0");
                                                $$ = tempNew;
                                              }
                  | LPAREN expression RPAREN  { $$ = $2; }
  ;

negated_expression: NOT primary_expression  { }
  ;

expression: primary_expression              { $$ = $1; }
          | negated_expression              { }
          | expression PLUS expression      { Node *new_sum = newNode("PLUS");                                            
                                              new_sum->childs.push_back($1);
                                              new_sum->childs.push_back($3);
                                              $$ = new_sum;
                                            }
          | expression MINUS expression     { }
          | expression TIMES expression     { Node *new_multiply = newNode("TIMES");                                            
                                              new_multiply->childs.push_back($1);
                                              new_multiply->childs.push_back($3);
                                              $$ = new_multiply;
                                            }
          | expression DIVIDEDBY expression { Node *new_divide = newNode("DIVIDEDBY");
                                              new_divide->childs.push_back($1);
                                              new_divide->childs.push_back($3);
                                              $$ = new_divide;
                                            }
          | expression EQ expression        { }
          | expression NEQ expression       { }
          | expression GT expression        { Node *new_GT = newNode("GT");
                                              new_GT->childs.push_back($1);
                                              new_GT->childs.push_back($3);
                                              $$ = new_GT;
                                            }
          | expression GTE expression       { Node *new_GTE = newNode("GTE");                                            
                                              new_GTE->childs.push_back($1);
                                              new_GTE->childs.push_back($3);
                                              $$ = new_GTE;
                                            }
          | expression LT expression        { }
          | expression LTE expression       { }
  ;

assign_statement: IDENTIFIER ASSIGN expression NEWLINE  { Node *new_assignment = newNode("Assignment");
                                                          new_assignment->type = 0;
                                                          Node *new1 = newNode("Identifier: ", *$1);
                                                          new_assignment->childs.push_back(new1);                                                          
                                                          new_assignment->childs.push_back($3);
                                                          $$ = new_assignment;
                                                        }
  ;

block: INDENT statements DEDENT { Node *new_block = newNode("Block");
                                  new_block->type = 4;
                                  new_block->childs = *$2;
                                  $$ = new_block;
                                }
  ;

condition: expression       { $$ = $1; }
  | condition AND condition { }
  | condition OR condition  { }
  ;

if_statement: IF condition COLON NEWLINE block elif_blocks else_block { Node * new_if = newNode("If");
                                                                        new_if->type = 1;
                                                                        new_if->childs.push_back($2);
                                                                        new_if->childs.push_back($5);
                                                                        new_if->childs.push_back($6);
                                                                        new_if->childs.push_back($7);
                                                                        $$ = new_if;                                                       
                                                                      }
  ;

elif_blocks: %empty                                { $$ = NULL; }
  | elif_blocks ELIF condition COLON NEWLINE block { }
  ;

else_block: %empty           { $$ = NULL; }
  | ELSE COLON NEWLINE block { Node * new_block = newNode("Else");
                               new_block->type = 5;
                               new_block->childs.push_back($4);
                               $$ = new_block;
                             }
  ;

while_statement: WHILE condition COLON NEWLINE block  { Node * new_while = newNode("While");
                                                        new_while->type = 6;
                                                        new_while->childs.push_back($2);
                                                        new_while->childs.push_back($5);
                                                        $$ = new_while;                                                     
                                                      }
  ;

break_statement: BREAK NEWLINE  { Node * new_break = newNode("Break");
                                  new_break->type = 7;
                                  $$ = new_break;
                                }
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  cerr << "Error (line " << loc->first_line << "): " << err << endl;
}