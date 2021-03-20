(* ast.ml file *)

(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | ISEQ | NOTEQ | Less | Leq | Greater | Geq |
          And | Or | Mod

type uop = Not | Neg | Size

type typ = Int | Float | Void | Matrix of typ * int * int  

type bind = typ * string

type expr =
    Literal of int
  | StrLiteral of string
  | Fliteral of string
  | MatrixLit of string 
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr
  | Call of string * expr list
  | Access of expr * int * int
  | Noexpr

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt
  | Break (* Maybe *)
  | Continue 

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

  type var_decl = {
    var: bind
  }

type program = bind list * func_decl list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | ISEQ -> "=="
  | NOTEQ -> "!="
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
  | Matrix(t, i, i2) -> "matrix of type: " ^ string_of_typ t ^ " rows: " ^ string_of_int i ^ " columns: " ^ string_of_int i2

let string_of_uop (o) =
  match o with
    Not -> "!"
  | Neg -> "-"
  | Size -> "size"

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"


