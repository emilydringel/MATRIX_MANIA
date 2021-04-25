(* ast.ml file *)

(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or | Mod

type uop = Not | Neg

type typ = Int | Float | Void | Matrix of typ 

type bind = typ * string

type expr =
    IntLit of int
  | FLit of string
  | MatrixLit of (expr list) list 
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr
  | Call of string * expr list
  | Access of expr * expr * expr
  | Noexpr

type stmt =
    Block of stmt list
  | VarDecl of typ * string * expr
  | Update of expr * expr * expr * expr
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | While of expr * stmt

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    body : stmt list;
  }

  type var_decl = {
    var: bind
  }

type program = func_decl list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Mod -> "%"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"

(*Added - for pretty printing*)
let rec string_of_typ (t) =
  match t with
    Int -> "int"
  | Float -> "float"
  | Void -> "void" 
  | Matrix(t) -> "matrix of type: " ^ string_of_typ t 

let string_of_uop (o) =
  match o with
    Not -> "!"
  | Neg -> "-"

let rec string_of_expr = function
  IntLit(l) -> string_of_int l
| FLit(l) -> l
| Id(s) -> s
| Binop(e1, o, e2) ->
    string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
| Unop(o, e) -> string_of_uop o ^ string_of_expr e
| Assign(v, e) -> v ^ " = " ^ string_of_expr e
| Call(f, el) ->
    f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
| Noexpr -> ""
| MatrixLit(l) -> 
let string_of_row l =
  String.concat "" (List.map string_of_expr l)
in
String.concat "" (List.map string_of_row l)
| Access(e1, e2, e3) ->    
string_of_expr e1 ^ " " ^ string_of_expr e2 ^ " " ^ string_of_expr e3

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s1, s3) -> 
    "if (" ^ string_of_expr e ^ ")\n" ^
    string_of_stmt s1 ^ "else\n" ^ string_of_stmt s3
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s
  | VarDecl(t, s, e) -> string_of_typ t ^ " " ^ s ^ "=" ^ string_of_expr e ^ "\n"
  | Update(m, r, c, e) -> string_of_expr e ^ "[" ^ string_of_expr e ^ "," ^ 
                          string_of_expr e ^ "] =" ^ string_of_expr e ^ "\n"

let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "}\n"
let string_of_program funcs =  String.concat "" (List.map string_of_fdecl funcs)
