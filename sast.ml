(* Semantically-checked Abstract Syntax Tree and functions for printing it *)

open Ast

type sexpr = typ * sx
and sx =
    SLiteral of int
  (*| SStrLiteral of string*)
  | SFliteral of string
  | SMatrixLit of (sexpr list) list
  | SId of string
  | SBinop of sexpr * op * sexpr
  | SUnop of uop * sexpr
  | SAssign of string * sexpr
  | SCall of string * sexpr list
  | SAccess of sexpr * int * int (*SAccess of sexpr * sint * sint*)
  | SNoexpr

type sstmt =
    SBlock of sstmt list
  | SVarDecl of typ * string * sexpr
  | SExpr of sexpr
  | SReturn of sexpr
  | SIf of sexpr * sstmt * (sexpr * sstmt) list * sstmt
  | SFor of sexpr * sexpr * sexpr * (sstmt list)
  | SWhile of sexpr * sstmt list
  | SBreak (* Maybe *)
  | SContinue 

type sfunc_decl = {
    styp : typ;
    sfname : string;
    sformals : bind list;
    (*slocals : bind list;*)
    sbody : sstmt list;
  }
(*
type svar_decl = {
    svar: bind
  }
*)
(*type smain = sstmt list*)

type sdefine = typ * string * sexpr

type simport = string

type sprogram = simport list * sdefine list * sfunc_decl list (* smain *)

(* Pretty-printing functions *)



let rec string_of_sexpr (t, e) =
  "(" ^ string_of_typ t ^ " : " ^ match e with (*Got rid of ( to compile)*)
    SLiteral(l) -> string_of_int l
  (*
  | SBoolLit(true) -> "true"
  | SBoolLit(false) -> "false"
  *)
  | SMatrixLit(l) -> 
  let string_of_row l =
    String.concat "" (List.map string_of_sexpr l)
  in
  String.concat "" (List.map string_of_row l)
  (*"matrix lit!" Only sort of works *)
  (*let print_list l =
    let rec print_elements l = function
      | [] -> ()
      | h::t -> string_of_sexpr h; print_string ","; print_elements t; ()
    in
    let rec print_row l = function
      | [] -> ()
      | h::t -> print_elements h; print_string ";"; print_row t; ()
    in
    print_string "[";
    print_row l;
    print_string "]";
  in print_list l; "" *)
  | SFliteral(l) -> l
  (*| SStrLiteral(l) -> l This is inconsistent in our code but I think it makes sense to have them*)
  | SId(s) -> s
  | SBinop(e1, o, e2) ->
      string_of_sexpr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_sexpr e2
  | SUnop(o, e) -> string_of_uop o ^ string_of_sexpr e
  | SAssign(v, e) -> v ^ " = " ^ string_of_sexpr e
  | SCall(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
  | SNoexpr -> "(" ^ ")"	(* Edited to make run??*)	
  | SAccess(e, i1, i2) ->    
      string_of_sexpr e ^ " " ^ string_of_int i1 ^ " " ^ string_of_int i2 (* changed from sint to int *)
 (* | _ -> "" *)

let rec string_of_sstmt = function
    SBlock(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_sstmt stmts) ^ "}\n"
  | SExpr(expr) -> string_of_sexpr expr ^ ";\n";
  | SReturn(expr) -> "return " ^ string_of_sexpr expr ^ ";\n";
  (*| SIf(e, s, SBlock([])) ->
      "if (" ^ string_of_sexpr e ^ ")\n" ^ string_of_sstmt s *)
  | SIf(e, s1, l, s3) -> 
  let string_of_elif_stmt (e,s) = 
    "else if (" ^ string_of_sexpr e ^ ")\n" ^
    string_of_sstmt s
  in
  "if (" ^ string_of_sexpr e ^ ")\n" ^
  string_of_sstmt s1 ^ String.concat "" (List.map string_of_elif_stmt l) ^ "else\n" ^ string_of_sstmt s3
  (*| SIf(e, s1, s2) ->  "if (" ^ string_of_sexpr e ^ ")\n" ^
      string_of_sstmt s1 ^ "else\n" ^ string_of_sstmt s2*)
      (*| SFor of sexpr * sexpr * sexpr * sstmt list*)
  | SFor(e1, e2, e3, l) ->
      "for (" ^ string_of_sexpr e1  ^ " ; " ^ string_of_sexpr e2 ^ " ; " ^
      string_of_sexpr e3  ^ ") " ^ String.concat "" (List.map string_of_sstmt l)
  | SWhile(e, l) -> "while (" ^ string_of_sexpr e ^ ") " ^ String.concat "" (List.map string_of_sstmt l)
(*break and continue added here? *)
  | SBreak -> "break \n"
  | SContinue -> "continue \n"
  | SVarDecl(t, s, e) -> string_of_typ t ^ " " ^ s ^ "=" ^ string_of_sexpr e ^ "\n"

let string_of_sfdecl fdecl =
  string_of_typ fdecl.styp ^ " " ^
  fdecl.sfname ^ "(" ^ String.concat ", " (List.map snd fdecl.sformals) ^
  ")\n{\n" ^
  (*String.concat "" (List.map string_of_vdecl fdecl.slocals) ^  SOMETHING HERE IS WRONG *)
  String.concat "" (List.map string_of_sstmt fdecl.sbody) ^
  "}\n"

let string_of_sprogram (funcs) =
  (*String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^*)
  String.concat "\n" (List.map string_of_sfdecl funcs)




