(* Semantic checking for the MicroC compiler *)

(* BIGGEST PROBLEMS: 
1. How to keep track of the matrix size? Maybe sx should be different for matrices? -- don't do this
2. How do you say matrix of any type/size -- ex. in printing
3. Getting matrix size from a matrix literal -- using lists, should be not too hard
4. Finish expr and check_stmt from chalkboard notes
*)

open Ast
open Sast

module StringMap = Map.Make(String)


(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.

   Check each global variable, then check each function *)

   let check (imports, defines, functions) =

  (* Check binds - Verify a list of bindings has no void types or duplicate names *)

  (**** Check global variables ****)
  let check_binds (kind : string) (binds : bind list) =
    List.iter (function
	(Void, b) -> raise (Failure ("illegal void " ^ kind ^ " " ^ b))
      | _ -> ()) binds;
    let rec dups = function
        [] -> ()
      |	((_,n1) :: (_,n2) :: _) when n1 = n2 ->
	  raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
      | _ :: t -> dups t
    in dups (List.sort (fun (_,a) (_,b) -> compare a b) binds)
  in

  (*check_binds "global" globals;*)

  (**** Check functions ****)

  (* Collect function declarations for built-in functions: no bodies *)
  
  let built_in_decls = 
    let add_bind map (name, ty) = StringMap.add name {
      typ = Void;
      fname = name; 
      formals = [(ty, "x")];
      body = [] } map
      (*locals = []; body = [] } map*)
    in List.fold_left add_bind StringMap.empty [ ("size", Matrix(Int));
                               ("print", Int);
			                         ("printm", Matrix(Int));
                               ("printmf", Matrix(Float)); (* Not working *)
			                         ("printf", Float)]
  in

  (* Add function name to symbol table *)
  
  let add_func map fd = 
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname (* Name of the function *)
    in match fd with (* No duplicate functions or redefinitions of built-ins *)
         _ when StringMap.mem n built_in_decls -> make_err built_in_err
       | _ when StringMap.mem n map -> make_err dup_err  
       | _ ->  StringMap.add n fd map 
  in
  

  (* Collect all function names into one symbol table *)
  let function_decls = List.fold_left add_func built_in_decls functions
  in
  
  (* Return a function from our symbol table *)
  let find_func s = 
    try StringMap.find s function_decls
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in


  let _ = find_func "main" in (* Ensure "main" is defined *)

  let check_function func =
    (* Make sure no formals or locals are void or duplicates *)
    check_binds "formal" func.formals;
    (* check_binds "local" func.locals; *)

    (* Raise an exception if the given rvalue type cannot be assigned to
       the given lvalue type *)
       
    let check_assign lvaluet rvaluet err =
       if lvaluet = rvaluet || (lvaluet==Float && rvaluet == Int) then lvaluet else raise (Failure err)
    in   
    
    (*
    let check_type e t typ_list =
      if not (List.mem t typ_list) then raise (Failure ("illegal type " ^ string_of_typ t ^ " of " ^ string_of_expr e))
    in 
    *)

    (* Build local symbol table of variables for this function *)
    
    let symbols = Hashtbl.create 20 in

    List.iter (fun (ty, name) -> Hashtbl.add symbols name ty)
        (func.formals);

(*
    let symbols = List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
	                StringMap.empty (func.formals)
                  StringMap.empty (globals @ func.formals @ func.locals )
    in
  *)

    (* Return a variable from our local symbol table *)
    
    let type_of_identifier s =
      try Hashtbl.find symbols s
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
      (* replace StringMap with StringHash to fix Not_found error*)
    in

    (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr = function
        IntLit  l -> (Int, SLiteral l)
      | FLit l -> (Float, SFliteral l)
      (*| StrLiteral l -> (Int, SStrLiteral l)*)
      | MatrixLit l -> 
        let find_inner_type l = match l with
            hd::tl -> let (t,e) = (expr hd) in t
          | _ -> Void
        in
        
        let find_type mat = match mat with
            hd::tl -> find_inner_type hd
          | _ -> Void
        in

        let my_type = find_type l in

        let rec matrix_expr l = match l with
            hd::tl -> let (ty,e) = expr hd in
              if ty != my_type then raise (Failure ("Types in matrix do not match."));
              (ty, e) :: (matrix_expr l)
          | _ -> []
        in

        (Matrix(my_type), SMatrixLit(List.map matrix_expr l)) (*Need to fix*)
      (*| BoolLit l  -> (Bool, SBoolLit l)*)
      | Noexpr     -> (Void, SNoexpr)
      | Id s       -> (type_of_identifier s, SId s) (*should be type of identifier*)
      | Assign(var, e) -> 
          let lt = type_of_identifier var
          and (rt, e') = expr e in
          let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^ 
            string_of_typ rt ^ " in " ^ string_of_sexpr (rt, e')
          in (check_assign lt rt err, SAssign(var, (rt, e')))
      | Unop(op, e) ->
          let (t, e') = expr e in
          let ty = match op with
            Neg when t = Int || t = Float -> t
          | Not when t = Int -> Int (* should check whether 0 or 1 in code *)
          (*| Size when t = Matrix(t,i,j) -> (Int, Int) How do we say any size/type *)
          | _ -> raise (Failure ("illegal unary operator " ^ 
                                 string_of_uop op ^ string_of_typ t ^
                                 " in " ^ string_of_expr e))
          in (ty, SUnop(op, (t, e')))
      | Binop(e1, op, e2) -> 
          let (t1, e1') = expr e1 
          and (t2, e2') = expr e2 in
          (* All binary operators require operands of the same type *)
          let same = t1 = t2 in
          let castOk = ((t1 = Float && t2 = Int) || (t1 = Int && t2 = Float)) in
          (* Determine expression type based on operator and operand types *)
          let ty = match op with
            Add | Sub | Div | Mod | Mult when same  && t1 = Int   -> Int
          | Add | Sub | Div | Mod | Mult when same  && t1 = Float -> Float
          | Add | Sub | Div | Mod | Mult when castOk -> Float 
          | Add | Sub | Div | Mod | Mult when castOk -> Float
          | Mult when t1 = Matrix(Int) && t2 = Matrix(Int) -> Matrix(Int)
          | Mult when t1 = Matrix(Int) && t2 = Matrix(Float) -> Matrix(Float)
          | Mult when t2 = Matrix(Int) && t1 = Matrix(Float) -> Matrix(Float)
          | Mult when t1 = Matrix(Float) && t2 = Matrix(Float) -> Matrix(Float)
          | Mult when t1 = Matrix(Int) && t2 = Int -> Matrix(Int)
          | Mult when t2 = Matrix(Int) && t1 = Int -> Matrix(Int)
          | Mult when t1 = Matrix(Int) && t2 = Float-> Matrix(Float)
          | Mult when t2 = Matrix(Int) && t1 = Float -> Matrix(Float)
          | Mult when t1 = Matrix(Float) && (t2 = Float || t2 = Int) -> Matrix(Float)
          | Mult when t2 = Matrix(Float) && (t2 = Float || t2 = Int) -> Matrix(Float)
          | Equal | Neq when same               -> Int
          | Equal | Neq when castOk             -> Int
          | Equal | Neq when (t1 = Matrix(Int) || t1 = Matrix(Float)) && (t2 = Matrix(Int) || t2 = Matrix(Float)) -> Int
          | Less | Leq | Greater | Geq
                     when (same || castOk) && (t1 = Int || t1 = Float) -> Int
          | And | Or when same && t1 = Int -> Int
          | _ -> raise (
	      Failure ("illegal binary operator " ^
                       string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                       string_of_typ t2))
          in (ty, SBinop((t1, e1'), op, (t2, e2')))
      | Call(fname, args) as call -> 
          let fd = find_func fname in
          let param_length = List.length fd.formals in
          if List.length args != param_length then
            raise (Failure ("expecting " ^ string_of_int param_length ^ 
                            " arguments in " ^ string_of_expr call))
          else let check_call (ft, _) e = 
            let (et, e') = expr e in 
            let err = "illegal argument found " ^ string_of_typ et ^
              " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
            in (check_assign ft et err, e')
          in 
          let args' = List.map2 check_call fd.formals args
          in (fd.typ, SCall(fname, args'))
      | Access(e1, l1, l2) -> 
          let (t,e) = expr e1 in
          let ty = match t with
            Matrix(Int) -> Int
          | Matrix(Float) -> Float
          | _ -> raise (
            Failure ("illegal access of " ^
                           string_of_typ t))
          in
        (ty, SAccess(expr e1, l1, l2))
    in
    
    (*
    let check_bool_expr e = 
      let (t', e') = expr e in
      let err = "expected one or two in " ^ string_of_sexpr (t', e')
      in if e!=1 && e'!=0 then raise (Failure err) else (t', e') 
    in
    *)

    (* Return a semantically-checked statement i.e. containing sexprs *)
    let rec check_stmt = function
        Expr e -> SExpr (expr e)
      | If(p, b1, b2) ->  SIf(expr p, check_stmt b1, check_stmt b2)
      (*| For(e1, e2, e3, l) ->
	      SFor(expr e1, expr e2, expr e3, List.map check_stmt l)*)
      (*| While(p, l) -> SWhile(expr p, List.map check_stmt l) *)
      (*| If(p, b1, b2) -> SIf(expr p, check_stmt b1, check_stmt b2)*)
      | For(e1, e2, e3, st) -> SFor(expr e1, expr e2, expr e3, check_stmt st)
      | While(p, s) -> SWhile(expr p, check_stmt s)
      | Return e -> let (t, e') = expr e in
        if t = func.typ then SReturn (t, e') 
        else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ func.typ ^ " in " ^ string_of_sexpr (expr e)))
	    
	    (* A block is correct if each statement is correct and nothing
	       follows any Return statement.  Nested blocks are flattened. *)
      | Block sl -> 
          let rec check_stmt_list = function
              [Return _ as s] -> [check_stmt s]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) (* Flatten blocks *)
            | s :: ss         -> check_stmt s :: check_stmt_list ss
            | []              -> []
          in SBlock(check_stmt_list sl)
      | Break -> SBreak
      | Continue -> SContinue
      | VarDecl(t, s, e) -> 
          let (ty,ex) = expr e in
          if ty != t then raise (Failure ("Type not correct"));
          Hashtbl.add symbols s t;
          SVarDecl(t, s, expr e) (* COME BACK TO THIS*)

    in (* body of check_function *)
    { styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      (*slocals  = func.locals;*)
      sbody = match check_stmt (Block func.body) with
	SBlock(sl) -> sl
      | _ -> raise (Failure ("internal error: block didn't become a block?"))
    }
  
  
  in (List.map check_function functions)

  
