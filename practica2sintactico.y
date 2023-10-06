%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    #include "tablasimbolos.h"
    
    extern int  yylex(void);
    extern char *yytext;

    /* Here go the variables I need
    char* id;
    */
    char* id;
    char* id1;
    char* id2;


   int yyerror(char *s);
%}

%union {
    float numero_real;
    char* identificador;
    int condition;
}

%start S;

%token SIEN;
%token EVAL;
%token IF;
%token THEN;
%token ELSE;
%token <numero_real> INT;
%token <numero_real> REAL;
%token <numero_real> EXP;
%token <identificador> ID;
%token LEQ;
%token GEQ;
%token EQI;
%token NEQ;
%token EQU;
%token ADD;
%token SUB;
%token MULT;
%token DIV;
%token SEP;
%token PCOMA;
%token PO;
%token PC;
%token CPO;
%token CPC;
%token LT;
%token GT;

%type <condition> cond
%type <numero_real> IF_ST
%type <numero_real> E0;
%type <numero_real> E1;
%type <numero_real> E2;


%%



S     : EVAL E0 PCOMA                     { printf("El resultado de evaluar el programa es %.2f\n", $2); } 
      | SIEN LDs EVAL E0                  { printf("El resultado de evaluar el programa es %.2f\n", $4); }
      | EVAL IF_ST PCOMA                  { printf("El resultado de evaluar el programa es %.2f\n", $2); } 
      | SIEN LDs EVAL IF_ST               { printf("El resultado de evaluar el programa es %.2f\n", $4); }
      ;

LDs   : LDs SEP D
      | D
      ;

IF_ST : IF PO cond PC THEN CPO E0 CPC ELSE CPO E0 CPC         { if($3) $$ = $7;
                                                                else $$ = $11;} 

D     : ID                                { printf("El valor del identificador %s es ", $1); 
                                            id = NULL;
                                            id = (char*)malloc(15);
                                            sprintf(id, "%s", $1); }
        EQU E0                            { insertarTS(id, $4);
                                            printf("%5.2f\n", $4); }
      | LT ID                             { id1 = NULL;
                                            id1 = (char *)malloc(15); 
                                            sprintf(id1, "%s", $2); }
        SEP ID                            { id2 = NULL;
                                            id2 = (char *)malloc(15);
                                            sprintf(id2, "%s", $5); }
        GT EQU LT E0                      { insertarTS(id1, $10);
                                            printf("El valor del identificador %s es %.2f\n", id1, $10); }
        SEP E0                            { insertarTS(id2, $13);
                                            printf("El valor del identificador %s es %.2f\n", id2, $13); }
        GT         
      ;

E0    : E0 ADD E1                         { $$ = $1 + $3; }
      | E0 SUB E1                         { $$ = $1 - $3; }
      | E1                                { $$ = $1; }
      ;

cond  : E0 LEQ E0                         { if($1 <= $3) $$ = 1;
                                            else $$ = 0; }
      | E0 GEQ E0                         { if($1 >= $3) $$ = 1;
                                            else $$ = 0; }
      | E0 EQI E0                         { if($1 == $3) $$ = 1;
                                            else $$ = 0; }
      | E0 NEQ E0                         { if($1 != $3) $$ = 1;
                                            else $$ = 0; }
      | E0 LT E0                          { if($1 < $3) $$ = 1;
                                            else $$ = 0; }
      | E0 GT E0                          { if($1 > $3) $$ = 1;
                                            else $$ = 0; }
      | E0                                { if($1) $$ = 1;
                                            else $$ = 0; }
      ;

E1    : E1 MULT E2                        { $$ = $1 * $3; }
      | E1 DIV E2                         { $$ = $1 / $3; }
      | E2                                { $$ = $1; }
      ;

E2    : INT                               { $$ = $1; }
      | REAL                              { $$ = $1; }
      | EXP                               { $$ = $1; }
      | ID                                { $$ = buscarTS($1); }
      | PO E0 PC                          { $$ = $2; }
      ;
      
%%

int main() {

  yyparse();

}

          

int yyerror (char *s)
{

  printf ("%s\n", s);

  return 0;

}


             
int yywrap()  
{  

  return 1;  

}  