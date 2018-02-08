%{
#include <stdlib.h>
#include <stdio.h>

int stack[128]; // Stack holding indentation level
int level = 0;	// Indentation level

void indentation(char* line);

%}

%option noyywrap

%%

^#.*\n		{ /* Ignore commented lines */ }
^[ ]*\n 	{ /* Ignore blank lines. */ }

^[ ]*[^ \n]+ { /* Do indentation*/									
				int lastChar = yyleng - 1;
				indentation(yytext) ;
				while ((lastChar >= 0) && (yytext[lastChar] != ' ')){
					unput(yytext[lastChar]);
					lastChar--;
				}
			}
				
[0-9]*		{ printf("%s\t\t%d\n", "INTEGER", atoi(yytext));}
[0-9]*[.][0-9]*		{ printf("%s\t\t%g\n", "FLOAT", atof(yytext));}

[\n]		{ printf("%s\n", "NEWLINE");}
"="			{ printf("%s\t\t=\n", "ASSIGN");}
"+"			{ printf("%s\t\t+\n", "PLUS");}
"-"			{ printf("%s\t\t-\n", "MINUS");}
"*"			{ printf("%s\t\t*\n", "TIMES");}
"/"			{ printf("%s\t/\n", "DIVIDEDBY");}
"=="		{ printf("%s\t\t==\n", "EQ");}
"!="		{ printf("%s\t\t!=\n", "NEQ");}
">"			{ printf("%s\t\t>\n", "GT");}
">="		{ printf("%s\t\t>=\n", "GTE");}
"<"			{ printf("%s\t\t<\n", "LT");}
"<="		{ printf("%s\t\t<=\n", "LTE");}

"("			{ printf("%s\t\t(\n", "LPAREN");}
")"			{ printf("%s\t\t)\n", "RPAREN");}
","			{ printf("%s\t\t,\n", "COMMA");}
":"			{ printf("%s\t\t:\n", "COLON");}

"True"		{ printf("BOOLEAN\t\t1\n");}
"False"		{ printf("BOOLEAN\t\t0\n");}

"and"		{ printf("AND\n");}
"break"		{ printf("BREAK\n");}
"def"		{ printf("DEF\t\tdef\n");}
"elif"		{ printf("ELIF\n");}
"else"		{ printf("ELSE\t\telse\n");}
"for"		{ printf("FOR\n");}
"if"		{ printf("IF\t\tif\n");}
"not"		{ printf("NOT\n");}
"or"		{ printf("OR\n");}
"return"	{ printf("RETURN\t\treturn\n");}
"while"		{ printf("WHILE\t\twhile\n");}

([a-zA-Z0-9_]*)*	{ printf("%s\t%s\n", "IDENTIFIER", yytext);}

[ ]			{ /*Ignore spaces*/ }
[	]		{ /*Ingore tabs */ }
<<EOF>>		{ indentation((char *)""); return 0;}

%%

void indentation(char * line) {
	int indent = 0;
	while ((*line == ' ' )||(*line == '	')){
		indent++;
		line++;
	}

	if (indent == stack[level]){
		return;
	}

	if (indent > stack[level]){
		printf("INDENT\n");
		stack[++level] = indent;
		return;
	}

	while (indent < stack[level]){
		printf("DEDENT\n");
		stack[level--] = '\0';
	}
}
