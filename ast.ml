(* ast.ml file *)

(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | ISEQ | NOTEQ | Less | Leq | Greater | Geq |
          And | Or | Mod

type uop = Not | Neg | Size

type typ = Int | Float | Void | Matrix of typ (* Is this how you write matrix??*)

type bind = typ * string

type expr =
    Literal of int
  | Fliteral of string
  | MatrixLit of string
 (* | BoolLit of bool *)
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
