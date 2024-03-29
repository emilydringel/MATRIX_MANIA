(* Semantic checking for the MATRIX MANIA compiler *)
(*Emily, Diego, Sophie, Desu*)
open Ast
open Sast

module StringMap = Map.Make(String)


(* Semantic checking of the AST. Returns an SAST if successful,
   throws an exception if something is wrong.

   Check each global variable, then check each function *)

  let check functions =

  (* Check binds - Verify a list of bindings has no void types or duplicate names *)

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

  (**** Check functions ****)

  (* Collect function declarations for built-in functions: no bodies *)
  
  let built_in_decls = 
    let add_bind map (name, ty, ret) = StringMap.add name {
      typ = ret;
      fname = name; 
      formals = [(ty, "x")];
      body = [] } map
    in List.fold_left add_bind StringMap.empty [ 
                               ("print", Int, Void);
			                         ("printm", Matrix(Int), Void);
                               ("printmf", Matrix(Float), Void);
			                         ("printf", Float, Void)]
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

    (* Raise an exception if the given rvalue type cannot be assigned to
       the given lvalue type *)
       
    let check_assign lvaluet rvaluet err =
       if lvaluet = rvaluet || (lvaluet==Float && rvaluet == Int) then lvaluet else raise (Failure err)
    in   

    (* Build local symbol table of variables for this function *)
    
    let symbols = List.fold_left (fun m (ty, name) -> StringMap.add name ty m)
	                StringMap.empty (func.formals)
    in

    (* Return a variable from our local symbol table *)
    
    let type_of_identifier s env =
      try StringMap.find s env
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in

    (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr e env = match e with
        IntLit  l -> (Int, SLiteral l)
      | FLit l -> (Float, SFliteral l)
      | MatrixLit l -> 
        let find_inner_type l = match l with
            hd::tl -> let (t,e) = (expr hd env) in t
          | _ -> Void
        in
        
        let find_type mat = match mat with
            hd::tl -> find_inner_type hd
          | _ -> Void
        in

        let my_type = find_type l in

        let rec matrix_expr l =  match l with
            hd::tl -> let (ty,e) = expr hd env in
              if ty != my_type then raise (Failure ("Types in matrix do not match."));
              (ty, e) :: (matrix_expr tl)
          | _ -> []
        in
        (Matrix(my_type), SMatrixLit(List.map matrix_expr l)) 
      | Noexpr     -> (Void, SNoexpr)
      | Id s       -> (type_of_identifier s env, SId s)
      | Assign(var, e) -> 
          let lt = type_of_identifier var env
          and (rt, e') = expr e env in
          let err = "illegal assignment " ^ string_of_typ lt ^ " = " ^ 
            string_of_typ rt ^ " in " ^ string_of_sexpr (rt, e')
          in (check_assign lt rt err, SAssign(var, (rt, e')))
      | Unop(op, e) ->
          let (t, e') = expr e env in
          let ty = match op with
            Neg when t = Int || t = Float -> t
          | Not when t = Int -> Int
          | _ -> raise (Failure ("illegal unary operator " ^ 
                                 string_of_uop op ^ string_of_typ t ^
                                 " in " ^ string_of_expr e))
          in (ty, SUnop(op, (t, e')))
      | Binop(e1, op, e2) -> 
          let (t1, e1') = expr e1 env 
          and (t2, e2') = expr e2 env in
          (* All binary operators require operands of the same type *)
          let same = t1 = t2 in
          let castOk = ((t1 = Float && t2 = Int) || (t1 = Int && t2 = Float)) in
          (* Determine expression type based on operator and operand types *)
          let ty = match op with
            Add | Sub | Div | Mod | Mult when same && t1 = Int   -> Int
          | Add | Sub | Div | Mult when same  && t1 = Float -> Float
          | Add | Sub | Div | Mult when castOk -> Float 
          | Add | Sub when t1 = Matrix(Int) && t2 = Matrix(Int) -> Matrix(Int)
          | Add | Sub when t1 = Matrix(Float) && t2 = Matrix(Float) -> Matrix(Float)
          | Mult when t1 = Matrix(Int) && t2 = Matrix(Int) -> Matrix(Int)
          | Mult when t1 = Matrix(Float) && t2 = Matrix(Float) -> Matrix(Float)
          | Mult when t1 = Matrix(Int) && t2 = Int -> Matrix(Int)
          | Mult when t2 = Matrix(Int) && t1 = Int -> Matrix(Int)
          | Mult when t1 = Matrix(Int) && t2 = Float-> Matrix(Int)
          | Mult when t2 = Matrix(Int) && t1 = Float -> Matrix(Int)
          | Mult when t1 = Matrix(Float) && (t2 = Float || t2 = Int) -> Matrix(Float)
          | Mult when t2 = Matrix(Float) && (t1 = Float || t1 = Int) -> Matrix(Float)
          | Equal | Neq when same               -> Int
          | Equal | Neq when castOk             -> Int
          | Equal | Neq when (t1 = Matrix(Int) && t2 = Matrix(Int)) || (t1 = Matrix(Float) && t2 = Matrix(Float)) -> Int
          | Less | Leq | Greater | Geq
                     when (same || castOk) && (t1 = Int || t1 = Float) -> Int
          | And | Or when same && t1 = Int -> Int
          | _ -> raise (
	      Failure ("illegal binary operator " ^
                       string_of_typ t1 ^ " " ^ string_of_op op ^ " " ^
                       string_of_typ t2))
          in (ty, SBinop((t1, e1'), op, (t2, e2')))
      | Call("getRows", args) -> 
          if List.length args != 1 then
            raise (Failure ("expecting " ^ string_of_int 1 ^ 
                            " arguments in " ^ "getRows"))
          else let head = List.hd args in
          let (et, e') = expr head env in
          (Int, SCall("getRows", [(et, e')]))
      | Call("getColumns", args) -> 
          if List.length args != 1 then
            raise (Failure ("expecting " ^ string_of_int 1 ^ 
                            " arguments in " ^ "getColumns"))
          else let head = List.hd args in
          let (et, e') = expr head env in
          (Int, SCall("getColumns", [(et, e')]))
      | Call(fname, args) as call -> 
          let fd = find_func fname in
          let param_length = List.length fd.formals in
          if List.length args != param_length then
            raise (Failure ("expecting " ^ string_of_int param_length ^ 
                            " arguments in " ^ string_of_expr call))
          else let check_call (ft, _) e = 
            let (et, e') = expr e env in 
            let err = "illegal argument found " ^ string_of_typ et ^
              " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e
            in (check_assign ft et err, e')
          in 
          let args' = List.map2 check_call fd.formals args
          in (fd.typ, SCall(fname, args'))
      | Access(m, r, c) -> 
          let (r_t, _) = expr r env in
          let (c_t, _) = expr c env in
          if r_t != Int || c_t != Int 
            then raise(Failure ("index must be of type int"));
          let (m_t, e) = expr m env in
          let m_type = match m_t with
            Matrix(Int) -> Int
          | Matrix(Float) -> Float
          | _ -> raise (
            Failure ("illegal access of " ^
                           string_of_typ m_t))
          in
          (m_type, SAccess(expr m env, expr r env, expr c env))
    in

    (* Return a semantically-checked statement i.e. containing sexprs *)
    let rec check_stmt stmt env = match stmt with
        Expr e -> (SExpr (expr e env), env)
      | If(p, b1, b2) -> 
      let (st1, e1) =  check_stmt b1 env in
      let (st2, e2) =  check_stmt b2 env in
      (SIf(expr p env, st1, st2), env)
      | While(p, s) -> 
      let (st, en) =  check_stmt s env in
      (SWhile(expr p env, st), env)
      | Return e -> let (t, e') = expr e env in
        if t = Matrix(Int) || t=Matrix(Float) then raise( Failure("cannot return a matrix"));
        if t = func.typ then (SReturn (t, e'), env) 
        else raise (
	  Failure ("return gives " ^ string_of_typ t ^ " expected " ^
		   string_of_typ func.typ ^ " in " ^ string_of_sexpr (expr e env)))
	    
	    (* A block is correct if each statement is correct and nothing
	       follows any Return statement.  Nested blocks are flattened. *)
      | Block sl -> 
          let rec check_stmt_list bl en = match bl with
              [Return _ as s] -> 
              let (st, en1) = check_stmt s en in 
              [st]
            | Return _ :: _   -> raise (Failure "nothing may follow a return")
            | Block sl :: ss  -> check_stmt_list (sl @ ss) en (* Flatten blocks *)
            | s :: ss         -> 
            let (st, en2) = check_stmt s en in
            st :: check_stmt_list ss en2
            | []              -> []
          in let ssl = check_stmt_list sl env in
          (SBlock(ssl), env)
      | VarDecl(t, s, e) -> 
          let (ty, ex) = expr e env in
          let decl_type = check_assign t ty "Type not correct" in
          (SVarDecl(t, s, expr e env), StringMap.add s decl_type env)
      | Update(m, r, c, e) -> 
          let (r_t, _) = expr r env in
          let (c_t, _) = expr c env in
          if r_t != Int || c_t != Int 
            then raise(Failure ("index must be of type int"));
          let (m_t, _) = expr m env in
          let m_type = match m_t with
              Matrix(Int) -> Int
            | Matrix(Float) -> Float
            | _ -> raise (
              Failure ("illegal access of " ^
                            string_of_typ m_t)) in
          let (e_t, e_e) = expr e env in
          ignore(check_assign m_type e_t "Matrix type and expression type do not match");
          (SUpdate(expr m env, expr r env, expr c env, expr e env), env)

    in (* body of check_function *)
    { styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      sbody = let (bl, env) = check_stmt (Block func.body) symbols in match bl with
	SBlock(sl) -> sl
      | _ -> raise (Failure ("internal error: block didn't become a block?"))
    }
  
  
  in (List.map check_function functions)

  
