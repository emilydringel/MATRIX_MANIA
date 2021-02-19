(* Parser File *)

/* Ocamlyacc parser for MicroC */

%{

%}

%token SEMI LPAREN RPAREN LBRACE RBRACE COMMA PLUS MINUS TIMES DIVIDE ASSIGN
%token NOT EQ NEQ LT LEQ GT GEQ AND OR
%token RETURN IF ELIF ELSE FOR IN WHILE MATRIX INT BOOL FLOAT NONE BREAK CONTINUE 
%token <int> LITERAL
%token <bool> BLIT
%token <matrix> MLIT (* what is <this>*)
%token <string> ID FLIT
%token CLASS DEF (*WHERE DO THESE GO???????*)
%token EOF

%start program
%type <Ast.program> program

%nonassoc NOELSE
%nonassoc ELSE (* what is this? what about if and elif? *)
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE
%right NOT

%%

program:
  CLASS ID LBRACE decls DEF MAIN RBRACE EOF { $1 } (* HOW TO PUT IN MAIN METHOD?*)

decls:
   /* nothing */ { ([], [])               }
 | decls vdecl { (($2 :: fst $1), snd $1) } (* WHAT?? *)
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

typ:
    MATRIX { Matrix }
  | INT   { Int   }
  | BOOL  { Bool  }
  | FLOAT { Float }
  | NONE  { None  }

vdecl_list:
    /* nothing */    { [] }
  | vdecl_list vdecl { $2 :: $1 }

vdecl:
   ID ASSIGN expr SEMI { $1 } (* What do we do about this and assigning variables *)

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }


elif_block:
  ELIF expr LBRACE stmt RBRACE elif_block  { If($2, $4, Block([])  } (* ?? *)

stmt:
    expr SEMI                               { Expr $1               }
  | RETURN expr_opt SEMI                    { Return $2             }
  | LBRACE stmt_list RBRACE                 { Block(List.rev $2)    }
  | IF expr LBRACE stmt RBRACE %prec NOELSE { If($2, $4, Block([])) } (* Is this right? *)
  | IF expr LBRACE stmt RBRACE ELSE LBRACE stmt RBRACE  
					    { If($2, $4, $8)        }
  | IF expr LBRACE stmt elif_block RBRACE ELSE LBRACE stmt RBRACE  
                                            { If($2, $4, $8)        } (* WITH ELSE IF *)
  | FOR ID IN expr LBRACE stmt RBRACE
                                            { For($2, $4, $6)   }
  | WHILE  expr LBRACE stmt RBRACE          { While($2, $4)         }

expr_opt:
    /* nothing */ { Noexpr }
  | expr          { $1 }

expr:
    LITERAL          { Literal($1)            }
  | FLIT	     { Fliteral($1)           }
  | BLIT             { BoolLit($1)            }
  | matrix_lit       { MatrixLit($1)          }
  | ID               { Id($1)                 }
  | expr PLUS   expr { Binop($1, Add,   $3)   }
  | expr MINUS  expr { Binop($1, Sub,   $3)   }
  | expr TIMES  expr { Binop($1, Mult,  $3)   }
  | expr DIVIDE expr { Binop($1, Div,   $3)   }
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
  | ID ASSIGN expr   { Assign($1, $3)         }
  | ID LPAREN args_opt RPAREN { Call($1, $3)  }
  | LPAREN expr RPAREN { $2                   }

matrix_elmt: (* like stmt_list *)
	
matrix_row: 

matrix_lit:   (*[1, 2, 3; 4, 5, 6] *)
	LBRACK COMMA LITERAL SEMI RBRACK


args_opt:
    /* nothing */ { [] }
  | args_list  { List.rev $1 }

args_list:
    expr                    { [$1] }
  | args_list COMMA expr { $3 :: $1 }
