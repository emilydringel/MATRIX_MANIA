(* Ocamllex scanner for MATRIXMANIA *)

{ open Parser }

let digit = ['0' - '9']
let digits = digit+
let withPoint = digits? '.' digits?
let exponent = 'e' ['+' '-']? digits
let float = withPoint exponent? | digits exponent

rule token = parse
  [' ' '\t' '\r' '\n'] { token lexbuf } (* Whitespace *)
| "/*"       { comment lexbuf }           (* Comments *)
| '('        { LPAREN }
| ')'        { RPAREN }
| '{'        { LBRACE }
| '}'        { RBRACE }
| '['        { LBRACK }
| ']'        { RBRACK }
| ';'        { SEMI }
| ','        { COMMA }
| '+'        { PLUS }
| '-'        { MINUS }
| '*'        { TIMES }
| '/'        { DIVIDE }
| '%'        { MOD }
| '='        { ASSIGN }
| "=="       { EQ }
| "!="       { NEQ }
| '<'        { LT }
| "<="       { LEQ }
| ">"        { GT }
| ">="       { GEQ }
| "&&"       { AND }
| "||"       { OR }
| "!"        { NOT }
| "if"       { IF }
| "else"     { ELSE }
| "elif"     { ELIF }
| "for"      { FOR }
| "while"    { WHILE }
| "continue" { CONTINUE }
| "break"    { BREAK }
| "return"   { RETURN }
| "int"      { INT }
| "float"    { FLOAT }
| "matrix"   { MATRIX }
| "void"     { VOID }
| "true"     { BLIT(true)  }
| "main"     { MAIN }
| "import"   {IMPORT }
| "define"   { DEFINE }
| "def"      { DEF }
| digits as lxm { LITERAL(int_of_string lxm) }
| float as lxm { FLIT(lxm) }
| ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']*     as lxm { ID(lxm) }
| eof { EOF }
| _ as char { raise (Failure("illegal character " ^ Char.escaped char)) }

and comment = parse
  "*/" { token lexbuf }
| _    { comment lexbuf }
