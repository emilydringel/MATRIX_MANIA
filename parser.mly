/* Parser File */

/* Ocamlyacc parser for MicroC */

%{

%}

%token SEMI LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK COMMA PLUS MINUS TIMES DIVIDE MOD ASSIGN
%token NOT EQ NEQ LT LEQ GT GEQ AND OR ISEQ NOTEQ
%token RETURN IF ELIF ELSE FOR IN WHILE BREAK CONTINUE 
/*%token INT BOOL FLOAT MATRIX */
%token NONE
%token <int> LITERAL
%token <bool> BLIT
%token <string> ID FLIT
%token DEF MAIN
%token IMPORT DEFINE
%token EOF

%start program
%type <Ast.program> program

%nonassoc NOELSE
%nonassoc ELSE /* what is this? what about if and elif? */
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ ISEQ NOTEQ
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT

%%

program:
  imports defines decls main EOF { $2 }

imports:
   /* nothing */               { []     }
  | imports IMPORT ID SEMI { $3 :: $1 }

defines:
   /* nothing */               { []     }
  | defines DEFINE ID expr SEMI { $3 :: Define($3, $4) }

main:
  DEF MAIN LPAREN RPAREN LBRACE vdecl_list stmt_list RBRACE
    { { 
	 locals = List.rev $6;
	 body = List.rev $7 } }


decls:
   /* nothing */ { ([], [])               }
 | decls vdecl { (($2 :: fst $1), snd $1) }
 | decls fdecl { (fst $1, ($2 :: snd $1)) }

fdecl:
   DEF ID LPAREN formals_opt RPAREN LBRACE vdecl_list stmt_list RBRACE
     { { fname = $2;
	 formals = List.rev $4;
	 locals = List.rev $7;
	 body = List.rev $8 } }

formals_opt:
    /* nothing */ { [] }
  | formal_list   { $1 }

formal_list:
    ID                   { [$1]     }
  | formal_list COMMA ID { $3 :: $1 }

/*
typ:
    INTMATRIX { IntMatrix }
    BOOLMATRIX { BoolMatrix }
    FLOATMATRIX { FloatMatrix }
  | INT   { Int   }
  | BOOL  { Bool  }
  | FLOAT { Float }
  | NONE  { None  }*/

vdecl_list:
    /* nothing */    { [] }
  | vdecl_list vdecl { $2 :: $1 }

vdecl:
   ID ASSIGN expr SEMI { $1 }

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

elif_list:
     /* nothing */       { [] }
   | elif_list elif { $2 :: $1 }

elif:
  ELIF LPAREN expr RPAREN LBRACE stmt RBRACE { ($3, $6) }

stmt:
    expr SEMI                               { Expr $1               }
  | BREAK SEMI                              { Break                 }
  | CONTINUE SEMI                           { Continue              }
  | RETURN expr_opt SEMI                    { Return $2             }
  | LBRACE stmt_list RBRACE                 { Block(List.rev $2)    }
  | LBRACE elif_list RBRACE	                { Block(List.rev $2)    } 
  | IF LPAREN expr RPAREN LBRACE stmt RBRACE elif_list ELSE LBRACE stmt RBRACE  
                                            { If($3, $6, $8, $11)        } 
  | IF LPAREN expr RPAREN LBRACE stmt RBRACE elif_list %prec NOELSE { If($3, $6, $8, Block([])) } 
  
  | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt_list
                                            { For($3, $5, $7, $9)   }
  | WHILE LPAREN expr RPAREN LBRACE stmt_list RBRACE          { While($3, $6)         }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    LITERAL          { Literal($1)            }
  | FLIT	           { Fliteral($1)           }
  | BLIT             { BoolLit($1)            } /* remove bools */
  | matrix_lit       { MatrixLit($1)          } /* int_matrix_lit?? */
  | NONE             { None                   }
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
  | expr ISEQ   expr { Binop($1, ISEQ, $3) }
  | expr NOTEQ  expr { Binop($1, NOTEQ,   $3)   }
  | expr AND    expr { Binop($1, And,   $3)   }
  | expr OR     expr { Binop($1, Or,    $3)   }
  | MINUS expr %prec NOT { Unop(Neg, $2)      }
  | NOT expr         { Unop(Not, $2)          }
  | ID ASSIGN expr   { Assign($1, $3)         }
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | LPAREN expr RPAREN { $2                   }

/* matrix.size */
/* == */
/* != */
/* matrix[row, column] */

matrix_row: 
    expr                   { [$1] }
  | expr COMMA matrix_row  { $1 :: $3 }

matrix_row_list:
    matrix_row                { [$1] }
  | matrix_row SEMI matrix_row_list  { $1 :: $3 }

matrix_lit:   /*[1, 2, 3; 4, 5, 6] */
	LBRACK matrix_row_list RBRACK { $2 }


args_opt:
    /* nothing */ { [] }
  | args_list  { List.rev $1 }

args_list:
    expr                    { [$1] }
  | args_list COMMA expr { $3 :: $1 }
