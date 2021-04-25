/* Parser File */

/* Ocamlyacc parser for MATRIXMANIA */

%{
 open Ast
%}

%token SEMI LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK COMMA   
%token PLUS MINUS TIMES DIVIDE MOD ASSIGN NOT
%token EQ NEQ LT LEQ GT GEQ AND OR
%token RETURN IF ELIF ELSE FOR WHILE INT FLOAT VOID MATRIX
%token <int> INTLIT
%token <string> ID 
%token <string> FLIT
%token <string> STRLIT
%token DEF
%token EOF

%start program
%type <Ast.program> program

%nonassoc NOELSE
%nonassoc NOELIF
%nonassoc ELSE 
%nonassoc RETURN
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%left LBRACK RBRACK
%right NOT SIZE

%%

program:
  fdecls EOF { $1 }

fdecls:
   /* nothing */  { []       }
 | fdecls fdecl   { $2 :: $1 }

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
   MATRIX LT typ GT { Matrix($3) }
  |INT { Int   }
  | FLOAT { Float }
  | VOID  { Void } 

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
    typ ID ASSIGN expr SEMI                 { VarDecl($1, $2, $4)    }
  | expr LBRACK expr COMMA expr RBRACK ASSIGN expr SEMI          
                                            { Update($1, $3, $5, $8) }
  | expr SEMI                               { Expr $1                }
  | RETURN expr_opt SEMI                    { Return $2              }
  | block_stmt                              { $1                     }
  | IF LPAREN expr RPAREN block_stmt %prec NOELSE 
                                            { If($3, $5, Block([]))  } 
  | IF LPAREN expr RPAREN block_stmt ELSE block_stmt    
                                            { If($3, $5, $7)         } 
  | IF LPAREN expr RPAREN block_stmt elifs  { If($3, $5, $6)         } 
  | FOR LPAREN SEMI expr SEMI expr_opt RPAREN stmt
                                      { Block([While($4, Block([$8; (Expr $6)]))]) }
  | FOR LPAREN stmt expr SEMI expr_opt RPAREN stmt
                                      { Block([$3; While($4, Block([$8; (Expr $6)]))]) }
                   
  | WHILE LPAREN expr RPAREN stmt           { While($3, $5)          }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    INTLIT           { IntLit($1)            }
  | FLIT	           { FLit($1)           }
  | matrix_lit       { MatrixLit($1)          } 
  | ID               { Id($1)                 }
  | expr LBRACK expr COMMA expr RBRACK
                     { Access($1, $3, $5)     }
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
  | MINUS expr %prec NOT 
                     { Unop(Neg, $2)          }
  | NOT expr         { Unop(Not, $2)          }
  | ID ASSIGN expr   { Assign($1, $3)         }
  | ID LPAREN args_opt RPAREN 
                     { Call($1, $3)           }
  | LPAREN expr RPAREN 
                     { $2                     }

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
/* list of rows */ 

args_opt:
    /* nothing */ { [] }
  | args_list  { List.rev $1 }

args_list:
    expr                    { [$1] }
  | args_list COMMA expr { $3 :: $1 }
