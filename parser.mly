/* Parser File */

/* Ocamlyacc parser for MATRIXMANIA */

%{
 open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK COMMA   
%token PLUS MINUS TIMES DIVIDE MOD ASSIGN NOT
%token /*SIZE*/ EQ NEQ LT LEQ GT GEQ AND OR
%token RETURN IF ELIF ELSE FOR WHILE INT BREAK CONTINUE FLOAT VOID MATRIX
%token <int> INTLIT
%token <string> ID 
%token <string> FLIT
%token <string> STRLIT
%token DEF MAIN
%token IMPORT DEFINE
%token EOF

%start program
%type <Ast.program> program

%nonassoc NOELSE
%nonassoc NOELIF
%nonassoc ELSE 
%nonassoc BREAK CONTINUE RETURN
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ LBRACK RBRACK
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT SIZE

%%

program:
  imports defines fdecls /*main*/ EOF { ($1, $2, $3) }

imports:
   /* nothing */                { []     }
  | imports IMPORT ID SEMI      { $3 :: $1 }

defines:
   /* nothing */                { []     }
  | defines DEFINE typ ID expr SEMI { ($3, $4, $5) :: $1 }

/*
main:
  DEF MAIN LPAREN RPAREN LBRACE stmt_list RBRACE
    { List.rev $6 }
*/
fdecls:
   /* nothing */  { []       }
 | fdecls fdecl   { $2 :: $1 }


/*decls:
    nothing { ([], [])               }
 | decls vdecl { (($2 :: fst $1), snd $1) }
 | decls fdecl { (fst $1, ($2 :: snd $1)) } */

fdecl:
   DEF typ ID LPAREN formals_opt RPAREN LBRACE stmt_list RBRACE
     { {
        typ = $2;   
        fname = $3;
	      formals = List.rev $5;
	      body = List.rev $8
	   } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    typ ID                   { [($1,$2)] }
  | formal_list COMMA typ ID { ($3,$4) :: $1 }


typ:
 /*   MATRIX LEQ typ GEQ { Matrix($3) } NEW - Might be wrong */ 
   MATRIX LT typ GT { Matrix($3) } /*  NEW - Might be wrong */
  |INT { Int   }
  | FLOAT { Float }
  | VOID  { Void } 
 

/* vdecl_list:
    /* nothing    { [] } */ 
/*  | vdecl_list vdecl { $2 :: $1 } */


/*vdecl:
   typ ID ASSIGN expr SEMI { $1 }*/

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

block_stmt:
  LBRACE stmt_list RBRACE                   { Block(List.rev $2)    }
  
elifs:
    ELIF LPAREN expr RPAREN block_stmt %prec NOELSE    
                                            { If($3, $5, Block([])) }
  | ELIF LPAREN expr RPAREN block_stmt ELSE block_stmt 
                                            { If($3, $5, $7)        }
  | ELIF LPAREN expr RPAREN block_stmt elifs           
                                            { If($3, $5, $6)        }

stmt:
    typ ID ASSIGN expr SEMI                 { VarDecl($1, $2, $4) }
  | expr SEMI                               { Expr $1               }
  | BREAK SEMI                              { Break                 }
  | CONTINUE SEMI                           { Continue              }
  | RETURN expr_opt SEMI                    { Return $2             }
  | block_stmt                              { $1                    }
  | IF LPAREN expr RPAREN block_stmt %prec NOELSE 
                                            { If($3, $5, Block([])) } 
  | IF LPAREN expr RPAREN block_stmt ELSE block_stmt    
                                            { If($3, $5, $7)        } 
  | IF LPAREN expr RPAREN block_stmt elifs  { If($3, $5, $6)        } 
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt
                                            { For($3, $5, $7, $9)   }
  | WHILE LPAREN expr RPAREN stmt           { While($3, $5)         }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    INTLIT           { IntLit($1)            }
/*| STRLIT	         { StringLit($1)          }*/
  | FLIT	           { FLit($1)           }
  | matrix_lit       { MatrixLit($1)          } 
 /* | NONE             { None                   }*/
  | ID               { Id($1)                 }
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
  | expr MOD    expr { Binop($1, Mod,   $3)   }
  | expr EQ     expr { Binop($1, Equal, $3)   }
  | expr NEQ    expr { Binop($1, Neq,   $3)   }
  | expr LT     expr { Binop($1, Less,  $3)   }
  | expr LEQ    expr { Binop($1, Leq,   $3)   }
  | expr GT     expr { Binop($1, Greater, $3) }
  | expr GEQ    expr { Binop($1, Geq,   $3)   }
  | expr AND    expr { Binop($1, And,   $3)   }
  | expr OR     expr { Binop($1, Or,    $3)   }
  | MINUS expr %prec NOT { Unop(Neg, $2)      }
  | NOT expr         { Unop(Not, $2)          }
  /*| SIZE expr        { Unop(Size, $2)         }*/
  | ID ASSIGN expr   { Assign($1, $3)         }
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | LPAREN expr RPAREN { $2                   }
  | matrix_access    { $1      }
/*
matrix:
  typ LBRACK INTLIT RBRACK LBRACK INTLIT RBRACK {   }

matrix_primitives:
  INTLIT  { Literal($1) }
  | FLIT { Fliteral($1) }
*/

matrix_access:
  expr LBRACK INTLIT COMMA INTLIT RBRACK { Access($1, $3, $5) }
/* before this $3 and $5 were LITERAL, but parser said that terminal $3 had no argument */ 

matrix_row: 
    expr                   { [$1] }
  | expr COMMA matrix_row  { $1 :: $3 }
/* expr or expr followed by colummn and row, stacking expr, can do math w/ expr  */

matrix_row_list:
    matrix_row                { [$1] }
  | matrix_row SEMI matrix_row_list  { $1 :: $3 }
/* 1 row or row followed by semi colon then rest of list */

matrix_lit:   
	LBRACK matrix_row_list RBRACK { $2 }
/* [1, 2, 3; 4, 5, 6] list of rows */ 

args_opt:
    /* nothing */ { [] }
  | args_list  { List.rev $1 }

args_list:
    expr                    { [$1] }
  | args_list COMMA expr { $3 :: $1 }
