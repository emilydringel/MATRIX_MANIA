module L = Llvm
module A = Ast

open Sast

module StringMap = Map.Make(String)

let translate (functions) =
	let context = L.global_context () in
	let the_module = L.create_module context "MatrixMania" in

	let i32_t = L.i32_type context
	and i8_t = L.i8_type context
	and i1_t = L.i1_type context
	and float_t    = L.double_type context
	and array_t = L.array_type
	and void_t     = L.void_type   context in

	let ltype_of_typ = function
		  A.Int -> i32_t 
		| A.Float -> float_t 
		| A.Void  -> void_t
		(*| A.Matrix(t, r, c) ->
			let rows = match r with IntLit(s) -> s 
															| _ -> raise(Failure"Integer required for matrix dimension") in
			let cols = match c with IntLit(s) -> s 
															| _ -> raise(Failure"Integer required for matrix dimension") in
			(match t with
					A.Int      -> array_t (array_t i32_t cols) rows
					| A.Float  -> array_t (array_t float_t cols) rows
					| _ -> raise(Failure"Invalid datatype for matrix"))*)

	in

	(* Declare and store global variables *)
(*
	let global_vars : L.llvalue StringMap.t =
		let global_var m (t, n) = 
			let init = match t with
			A.Float -> L.const_float (ltype_of_typ t) 0.0
			| _ -> L.const_int (ltype_of_typ t) 0
			in StringMap.add n (L.define_global n init the_module) m in
		List.fold_left global_var StringMap.empty globals in
*)
	
	(* Declare external functions *)

	let printf_t : L.lltype =
		L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
	let printf_func : L.llvalue =
		L.declare_function "printf" printf_t the_module in

	let printm_t : L.lltype =
      L.function_type i32_t [| L.pointer_type i32_t |] in
  let printm_func : L.llvalue =
      L.declare_function "printm" printm_t the_module in

	let printmf_t : L.lltype =
			L.function_type i32_t [| array_t float_t 8 |] in
	let printmf_func : L.llvalue =
			L.declare_function "printmf" printmf_t the_module in

	(* Define each function (arguments and return type) 
	so we can call it even before we've created its body *)

	let function_decls : (L.llvalue * sfunc_decl) StringMap.t =
		let function_decl m fdecl =
			let name = fdecl.sfname
			and formal_types = 
				Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals)
			in let ftype = L.function_type (ltype_of_typ fdecl.styp) formal_types in
			StringMap.add name (L.define_function name ftype the_module, fdecl) m in
		List.fold_left function_decl StringMap.empty functions in



	(* Fill in the body of the given function *)
	
	let build_function_body fdecl =
		let (the_function, _) = StringMap.find fdecl.sfname function_decls in
		let builder = L.builder_at_end context (L.entry_block the_function) in

		let int_format_str = L.build_global_stringptr "%d\n" "fmt" builder
		and float_format_str = L.build_global_stringptr "%g\n" "fmt" builder in

	    (* Construct the function's "locals": formal arguments and locally
	       declared variables.  Allocate each on the stack, initialize their
	       value, if appropriate, and remember their values in the "locals" map *)
		let var_hash = Hashtbl.create 20 in
			let add_formal (t, n) p = 
				L.set_value_name n p;
				let local = L.build_alloca (ltype_of_typ t) n builder in
					ignore (L.build_store p local builder);
					ignore (Hashtbl.add var_hash n local)

			in
			List.iter2 add_formal fdecl.sformals (Array.to_list (L.params the_function));
	    (* Return the value for a variable or formal argument.
	       Check local names  *)
		let lookup n = Hashtbl.find var_hash n
		in

	    (* Construct code for an expression; return its value *)
	    let rec expr builder ((_, e) : sexpr) = match e with
				SLiteral i  -> L.const_int i32_t i
	      | SFliteral l -> L.const_float_of_string float_t l
	      | SNoexpr -> L.const_int i32_t 0
				| SMatrixLit l -> 
					(* (sexpr list) list *)
					(* extract rows and column info here *)
					let count a = List.fold_left (fun x _ -> x + 1) 0 a in
					let rows = count l in 
					let cols = count (List.hd l) in

					(* allocate space 2 + rows * cols*)
					let matrix = L.build_alloca i32_t "matrix" builder in
					
					(* go through list of lists and put in place *)
					(*build_store v p b creates a store %v, %p instruction at 
					the position specified by the instruction builder b. *)

					let all_good = (List.fold_left (fun same row -> (count row) == cols) true l ) in
					let eval_row row 
					  = List.fold_left (fun eval_row x -> eval_row @ [expr builder x]) [] row in 
					let unfolded = List.fold_left (fun unfld row -> unfld @ (eval_row row)) [] l in
					let unfolded = [L.const_int i32_t rows; L.const_int i32_t cols] @ unfolded in
					
					let rec store idx lst = match lst with
						 hd::tl -> let ptr = L.build_in_bounds_gep matrix [|L.const_int i32_t idx|] "ptr" builder in
											 L.build_store hd ptr builder;
											 store (idx + 1) tl;
						| _ -> ()
					in
					store 0 unfolded;
					L.build_in_bounds_gep matrix [|L.const_int i32_t 0|] "matrix" builder 
					
					(*List.fold_left (fun idx element -> build_gep matrix 2 name builder)
					
					L.build_store unfolded matrix builder 
					let pointer = build_gep matrix 2 name builder i*)
					(* creates a %name = getelementptr %p, indices *)
					
					(*
					print_int(count unfolded);
					print_int(if all_good == true then 1 else 0);
					print_int(rows);
					print_int(cols); 
					L.const_int i32_t 0
					*)
					(*L.const_array i32_t (Array.of_list unfolded)*)
 				| SId s       -> 
					L.build_load (lookup s) s builder
				| SAssign (s, e) -> let e' = expr builder e in
					ignore(L.build_store e' (lookup s) builder); e'
				| SBinop ((A.Float, _) as e1, op, e2) -> 
					let e1' = expr builder e1
					and e2' = expr builder e2 in
					(match op with 
						A.Add     -> L.build_fadd
					| A.Sub     -> L.build_fsub
					| A.Mult    -> L.build_fmul
					| A.Div     -> L.build_fdiv 
					| A.Equal   -> L.build_fcmp L.Fcmp.Oeq
					| A.Neq     -> L.build_fcmp L.Fcmp.One
					| A.Less    -> L.build_fcmp L.Fcmp.Olt
					| A.Leq     -> L.build_fcmp L.Fcmp.Ole
					| A.Greater -> L.build_fcmp L.Fcmp.Ogt
					| A.Geq     -> L.build_fcmp L.Fcmp.Oge
					| A.And | A.Or ->
							raise (Failure "internal error: semant should have rejected and/or on float")
					) e1' e2' "tmp" builder
				| SBinop (e1, op, e2) -> 
					(*print_int(if (L.is_null (expr builder predicate)) then 0 else 1);*)
					let e1' = expr builder e1
					and e2' = expr builder e2 in
					(match op with
						A.Add     -> L.build_add
					| A.Sub     -> L.build_sub
					| A.Mult    -> L.build_mul
								| A.Div     -> L.build_sdiv
					| A.And     -> L.build_and
					| A.Or      -> L.build_or
					| A.Equal   -> L.build_icmp L.Icmp.Eq
					| A.Neq     -> L.build_icmp L.Icmp.Ne
					| A.Less    -> L.build_icmp L.Icmp.Slt
					| A.Leq     -> L.build_icmp L.Icmp.Sle
					| A.Greater -> L.build_icmp L.Icmp.Sgt
					| A.Geq     -> L.build_icmp L.Icmp.Sge
					) e1' e2' "tmp" builder
						| SUnop(op, ((t, _) as e)) -> 
								let e' = expr builder e in
					(match op with
						A.Neg when t = A.Float -> L.build_fneg 
					| A.Neg                  -> L.build_neg
								| A.Not                  -> L.build_not) e' "tmp" builder
	      | SCall ("print", [e]) | SCall ("printb", [e]) -> 
			  L.build_call printf_func [| int_format_str ; (expr builder e) |]
			    "printf" builder
	      | SCall ("printf", [e]) -> 
			  L.build_call printf_func [| float_format_str ; (expr builder e) |]
			    "printf" builder
				| SCall ("printm", [e]) ->
					L.build_call printm_func [| (expr builder e) |] "printm" builder
				| SCall ("printmf", [e]) ->
					L.build_call printmf_func [| (expr builder e)|] "printmf" builder
	      | SCall (f, args) -> 
	    	let (fdef, fdecl) = StringMap.find f function_decls in
		 	let llargs = List.rev (List.map (expr builder) (List.rev args)) in
		 	let result = (match fdecl.styp with 
	                        A.Void -> ""
	                      | _ -> f ^ "_result") in
	         L.build_call fdef (Array.of_list llargs) result builder
	    in
    
    (* LLVM insists each basic block end with exactly one "terminator" 
       instruction that transfers control.  This function runs "instr builder"
       if the current block does not already have a terminator.  Used,
       e.g., to handle the "fall off the end of the function" case. *)
	    
	    let add_terminal builder instr =
	      match L.block_terminator (L.insertion_block builder) with
			Some _ -> ()
	      | None -> ignore (instr builder) in
		
	    (* Build the code for the given statement; return the builder for
	       the statement's successor (i.e., the next instruction will be built
	       after the one generated by this call) *)

	    let rec stmt builder = function
			    SBlock sl -> List.fold_left stmt builder sl
	    	| SExpr e -> ignore(expr builder e); builder 
	    	| SReturn e -> 
						ignore(match fdecl.styp with
							(* Special "return nothing" instr *)
							A.Void -> L.build_ret_void builder 
							(* Build return statement *)
							| _ -> L.build_ret (expr builder e) builder );
						builder
				| SIf (predicate, then_stmt, else_stmt) ->
						(* let expr_val = expr builder predicate in
						let int_val = if L.is_null expr_val then 0 else 1 in
						let bool_val = L.const_int i1_t int_val in *)
						let bool_val = expr builder predicate in
						(*let bool_val = L.const_int i1_t (if 0 then 1 else 0) in *)
						let merge_bb = L.append_block context "merge" the_function in
									let build_br_merge = L.build_br merge_bb in (* partial function *)
				
						let then_bb = L.append_block context "then" the_function in
						add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
							build_br_merge;
				
						let else_bb = L.append_block context "else" the_function in
						add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
							build_br_merge;
				
						ignore(L.build_cond_br bool_val then_bb else_bb builder);
						L.builder_at_end context merge_bb
				| SWhile (predicate, body) ->
						let pred_bb = L.append_block context "while" the_function in
						ignore(L.build_br pred_bb builder);
				
						let body_bb = L.append_block context "while_body" the_function in
						add_terminal (stmt (L.builder_at_end context body_bb) body)
							(L.build_br pred_bb);
						let pred_builder = L.builder_at_end context pred_bb in
						(* let int_val = if L.is_null (expr builder predicate) then 0 else 1 in
						let bool_val = L.const_int i1_t int_val in *)
						let bool_val = expr pred_builder predicate in
						let merge_bb = L.append_block context "merge" the_function in
						ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
						L.builder_at_end context merge_bb
					
				(* Implement for loops as while loops *)
				| SFor (e1, e2, e3, body) -> stmt builder
					( SBlock [SExpr e1 ; SWhile (e2, SBlock [body ; SExpr e3]) ] )
				| SVarDecl (t, id, e) -> match t with
						A.Matrix(t) -> (* do stuff*)
								builder
						| _ -> 
							let local_var = L.build_alloca (ltype_of_typ t) id builder in 
							Hashtbl.add var_hash id local_var;
							let e' = expr builder e in
							ignore(L.build_store e' (lookup id) builder); builder
	    in

	    (* Build the code for each statement in the function *)
	    
	    let builder = stmt builder (SBlock fdecl.sbody) in

	    (* Add a return if the last block falls off the end *)
	    add_terminal builder (match fdecl.styp with
	        A.Void -> L.build_ret_void
	      | A.Float -> L.build_ret (L.const_float float_t 0.0)
	      | t -> L.build_ret (L.const_int (ltype_of_typ t) 0))
  	in

	List.iter build_function_body functions;
	the_module