(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sexpr = typ * sx
and sx =
    SLiteral of int
  | SFliteral of string
  | SMatrixLit of (sexpr list) list
  | SId of string
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | SAssign of string * sexpr
  | SCall of string * sexpr list
  | SAccess of sexpr * sexpr * sexpr
  | SNoexpr

type sstmt =
    SBlock of sstmt list
  | SVarDecl of typ * string * sexpr
  | SUpdate of sexpr * sexpr * sexpr * sexpr
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * sstmt
  | SWhile of sexpr * sstmt

type sfunc_decl = {
    styp : typ;
    sfname : string;
    sformals : bind list;
    sbody : sstmt list;
  }

type sdefine = typ * string * sexpr

type simport = string

type sprogram = sfunc_decl list 

(* Pretty-printing functions *)



let rec string_of_sexpr (t, e) =
  "(" ^ string_of_typ t ^ " : " ^ match e with 
    SLiteral(l) -> string_of_int l
  | SMatrixLit(l) -> 
  let string_of_row l =
    String.concat "" (List.map string_of_sexpr l)
  in
  String.concat "" (List.map string_of_row l)
  | SFliteral(l) -> l
  | SId(s) -> s
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  | SAssign(v, e) -> v ^ " = " ^ string_of_sexpr e
  | SCall(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
  | SNoexpr -> "(" ^ ")"	
  | SAccess(e1, e2, e3) ->    
    string_of_sexpr e1 ^ " " ^ string_of_sexpr e2 ^ " " ^ string_of_sexpr e3

let rec string_of_sstmt = function
    SBlock(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n";
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n";
  | SIf(e, s1, s2) -> "if (" ^ string_of_sexpr e ^ ")\n" ^
      string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2
  | SWhile(e, s) -> "while (" ^ string_of_sexpr e ^ ") " ^ string_of_sstmt s
  | SVarDecl(t, s, e) -> string_of_typ t ^ " " ^ s ^ "=" ^ string_of_sexpr e ^ "\n"
  | SUpdate(m, r, c, e) -> string_of_sexpr e ^ "[" ^ string_of_sexpr e ^ "," ^ 
                          string_of_sexpr e ^ "] =" ^ string_of_sexpr e ^ "\n"

let string_of_sfdecl fdecl =
  string_of_typ fdecl.styp ^ " " ^
  fdecl.sfname ^ "(" ^ String.concat ", " (List.map snd fdecl.sformals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_sstmt fdecl.sbody) ^
  "}\n"

let string_of_sprogram (funcs) =
  String.concat "\n" (List.map string_of_sfdecl funcs)




