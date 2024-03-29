(*Emily, Diego, Sophie, Desu, Cindy*)
module L = Llvm
module A = Ast

open Sast

module StringMap = Map.Make(String)

let translate (functions) =
	let context = L.global_context () in
	let the_module = L.create_module context "MatrixMania" in

	let i32_t = L.i32_type context
	and i8_t = L.i8_type context
	and float_t    = L.double_type context
	and i64_t = L.i64_type context
	and void_t     = L.void_type   context in

	let rec ltype_of_typ = function
		  A.Int -> i32_t 
		| A.Float -> float_t 
		| A.Void  -> void_t
		| A.Matrix(t) -> L.pointer_type (ltype_of_typ t)

	in

  
	(* functions to easily get number of rows/columns of a matrix *)
  let get_matrix_rows matrix builder = (* matrix has already gone through expr *)
		let typ = L.string_of_lltype (L.type_of matrix) in
		let ret = match typ with
			"double*" -> let rows = L.build_load matrix "rows" builder 
				in L.build_fptosi rows i32_t "rowsint" builder 
			| _ -> L.build_load matrix "rows" builder
		in ret
	in
	let get_matrix_cols matrix builder = 
		let ptr = L.build_in_bounds_gep matrix [| L.const_int i32_t 1|] "ptr" builder in
		let typ = L.string_of_lltype (L.type_of ptr) in
		let ret = match typ with
			"double*" -> let cols = L.build_load ptr "cols" builder 
				in L.build_fptosi cols i32_t "colsint" builder 
			| _ -> L.build_load ptr "cols" builder
		in ret
	in
	
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
			L.function_type i32_t [| L.pointer_type float_t |] in
	let printmf_func : L.llvalue =
			L.declare_function "printmf" printmf_t the_module in
	
	(* Define each function (arguments and return type) 
	so we can call it even before we've created its body *)

		(* addition*)

		let addm_t : L.lltype =
			L.function_type (L.pointer_type i32_t) [| L.pointer_type i32_t; L.pointer_type i32_t |] in
	let addm_func : L.llvalue =
			L.declare_function "addm" addm_t the_module in

	let addmf_t : L.lltype =
			L.function_type (L.pointer_type float_t) [| L.pointer_type float_t; L.pointer_type float_t |] in
	let addmf_func : L.llvalue =
			L.declare_function "addmf" addmf_t the_module in

	(* subtraction *)		
	let subm_t : L.lltype =
			L.function_type (L.pointer_type i32_t) [| L.pointer_type i32_t; L.pointer_type i32_t |] in
	let subm_func : L.llvalue =
			L.declare_function "subm" subm_t the_module in

	let submf_t : L.lltype =
			L.function_type (L.pointer_type float_t) [| L.pointer_type float_t; L.pointer_type float_t |] in
	let submf_func : L.llvalue =
			L.declare_function "submf" submf_t the_module in	

	(* scalar multiplication*)

	let scalarm_t : L.lltype =
			L.function_type (L.pointer_type i32_t) [| float_t; L.pointer_type i32_t|] in
	let scalarm_func : L.llvalue =
			L.declare_function "scalarm" scalarm_t the_module in

	let scalarmf_t : L.lltype =
			L.function_type (L.pointer_type float_t) [| float_t; L.pointer_type float_t|] in
	let scalarmf_func : L.llvalue =
			L.declare_function "scalarmf" scalarmf_t the_module in

	(* matrix multiplication*)

	let multiplication_t : L.lltype =
			L.function_type (L.pointer_type i32_t) [| L.pointer_type i32_t; L.pointer_type i32_t|] in
	let multiplication_func : L.llvalue =
			L.declare_function "multiplication" multiplication_t the_module in

	let multiplicationf_t : L.lltype =
			L.function_type (L.pointer_type float_t) [| L.pointer_type float_t; L.pointer_type float_t|] in
	let multiplicationf_func : L.llvalue =
			L.declare_function "multiplicationf" multiplicationf_t the_module in

	(* equals *)
	let equal_t : L.lltype =
			L.function_type i32_t [| L.pointer_type i32_t; L.pointer_type i32_t|] in
	let equal_func : L.llvalue =
			L.declare_function "equal" equal_t the_module in

	let equalf_t : L.lltype =
			L.function_type i32_t [| L.pointer_type float_t; L.pointer_type float_t|] in
	let equalf_func : L.llvalue =
			L.declare_function "equalf" equalf_t the_module in

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
					let find_inner_type l = match l with
							hd::tl -> let (t,e) = hd in t
						| _ -> A.Int
					in
					
					let find_type mat = match mat with
							hd::tl -> find_inner_type hd
						| _ -> A.Int
					in

					let my_type = find_type l in 

					let make_matrix = match my_type with
						  A.Int ->
							(* extract rows and column info here *)
							let count a = List.fold_left (fun x _ -> x + 1) 0 a in
							let rows = count l in 
							let cols = count (List.hd l) in
							let rec valid_dims m = match m with
									hd::tl -> if count hd == count (List.hd l) 
															then valid_dims tl
														else false
								| _ -> true
							in 
							if not (valid_dims l) then
								raise(Failure "all rows of matrices must have the same number of elemens")
							else

							(* allocate space 2 + rows * cols*)
							let matrix = L.build_alloca (L.array_type i32_t (2+rows*cols)) "matrix" builder in
							
							let eval_row row 
								= List.fold_left (fun eval_row x -> eval_row @ [expr builder x]) [] row in 
							let unfolded = List.fold_left (fun unfld row -> unfld @ (eval_row row)) [] l in
							let unfolded = [L.const_int i32_t rows; L.const_int i32_t cols] @ unfolded in
							
							let rec store idx lst = match lst with
								hd::tl -> let ptr = L.build_in_bounds_gep matrix [| L.const_int i32_t 0; L.const_int i32_t idx|] "ptr" builder in
													ignore(L.build_store hd ptr builder);
													store (idx + 1) tl;
								| _ -> ()
							in
							store 0 unfolded;
							L.build_in_bounds_gep matrix [|L.const_int i32_t 0; L.const_int i32_t 0|] "matrix" builder 
					| A.Float ->
						let count a = List.fold_left (fun x _ -> x + 1) 0 a in
						let rows = float_of_int (count l) in 
						let cols = float_of_int (count (List.hd l)) in
						let rec valid_dims m = match m with
						    hd::tl -> if count hd == count (List.hd l) 
													  then valid_dims tl
												  else false
              | _ -> true
						in 
						if not (valid_dims l) then
							raise(Failure "all rows of matrices must have the same number of elemens")
						else

						(* allocate space 2 + rows * cols*)
						let matrix = L.build_alloca (L.array_type float_t (2+(int_of_float rows)*(int_of_float cols))) "matrix" builder in

						let eval_row row 
							= List.fold_left (fun eval_row x -> eval_row @ [expr builder x]) [] row in 
						let unfolded = List.fold_left (fun unfld row -> unfld @ (eval_row row)) [] l in
						let unfolded = [L.const_float float_t rows; L.const_float float_t cols] @ unfolded in
						let rec store idx lst = match lst with
							hd::tl -> let ptr = L.build_in_bounds_gep matrix [| L.const_int i64_t 0; L.const_int i64_t idx|] "ptr" builder in
												ignore(L.build_store hd ptr builder);
												store (idx + 1) tl;
							| _ -> ()
						in
						store 0 unfolded;
						L.build_in_bounds_gep matrix [| L.const_int i64_t 0; L.const_int i64_t 0|] "matrix" builder 
			    | _ -> raise (Failure "invalid matrix type")
					in make_matrix
 				| SId s       -> 
					L.build_load (lookup s) s builder
				| SAssign (s, e) -> 
					let e' = expr builder e
					and s' = lookup s in
					let e_type = L.string_of_lltype (L.type_of e')
					and s_type = L.string_of_lltype (L.type_of s') in
					let e_fixed = match (s_type, e_type) with
						"double", "i32" -> L.build_sitofp e' float_t "e_float" builder 
						| _ -> e'
				in
					ignore(L.build_store e_fixed s' builder); e'
				| SAccess ((ty, _) as m, r, c) ->
					(* get desired pointer location *)
					let matrix = expr builder m 
					and row_idx = expr builder r
					and col_idx = expr builder c in 
					let cols = get_matrix_cols matrix builder in
					(* row = row_idx * cols *)
					let row = L.build_mul row_idx cols "row" builder in 
					(* row_col = (row_idx * cols) + col_idx *)
					let row_col = L.build_add row col_idx "row_col" builder 
					and offset = L.const_int i32_t 2 in 
					(* idx = 2 + (row_idx * cols) + col_idx *)
					let idx = L.build_add offset row_col "idx" builder in
					let ptr = L.build_in_bounds_gep matrix [| idx |] "ptr" builder in
					L.build_load ptr "element" builder
				| SBinop ((A.Matrix(A.Int), _) as m1, op, m2) -> 
					let m1' = expr builder m1
					and m2' = expr builder m2 in
					let ret = match op with 
						A.Add     -> 
							L.build_call addm_func [| m1';m2' |] "addm" builder
					| A.Sub     -> L.build_call subm_func [| m1';m2' |] "subm" builder
					| A.Mult    -> 
						let (t', _) = m2 in
								let ret_val' = match t' with
									A.Int -> 
									let scalar = L.build_sitofp m2' float_t "scalar" builder in
									L.build_call scalarm_func [| scalar;m1' |] "scalarm" builder
								| A.Float ->
									L.build_call scalarm_func [| m2';m1' |] "scalarm" builder
								| _ -> 
									L.build_call multiplication_func [| m1';m2' |] "matm" builder
							in ret_val'
					| A.Equal   -> L.build_call equal_func [| m1';m2' |] "equal" builder
					| A.Neq     -> let eq = L.build_call equal_func [| m1';m2' |] "equal" builder in
													L.build_xor eq (L.const_int i32_t 1) "and" builder
					| _        	-> raise(Failure "internal error: semant should have rejected")
					in ret
				| SBinop ((_ as m1), (_ as op), ((A.Matrix(A.Int),_) as m2)) -> 
						let m1' = expr builder m1
						and m2' = expr builder m2 in
						let ret = match op with 
						| A.Mult    -> 
							let (t, _) = m1 in
							let ret_val = match t with 
									A.Int -> 
									let scalar = L.build_sitofp m1' float_t "scalar" builder in
									L.build_call scalarm_func [| scalar;m2' |] "scalarm" builder
								| A.Float ->
									L.build_call scalarm_func [| m1';m2' |] "scalarm" builder
								| _ -> raise(Failure "should be caught elsewhere")
							in ret_val
						| _        	-> raise(Failure "internal error: semant should have rejected")
						in ret
				| SBinop ((A.Matrix(A.Float), _) as m1, op, m2) -> 
					let m1' = expr builder m1
					and m2' = expr builder m2 in
					let ret = match op with 
						A.Add     -> 
							L.build_call addmf_func [| m1';m2' |] "addmf" builder
					| A.Sub     -> L.build_call submf_func [| m1';m2' |] "submf" builder
					| A.Mult    -> 
						let (t', _) = m2 in
								let ret_val' = match t' with
									A.Int -> 
									let scalar = L.build_sitofp m2' float_t "scalar" builder in
									L.build_call scalarmf_func [| scalar;m1' |] "scalarmf" builder
								| A.Float ->
									L.build_call scalarmf_func [| m2';m1' |] "scalarmf" builder
								| _ -> L.build_call multiplicationf_func [| m1';m2' |] "matmf" builder
							in ret_val'
					| A.Equal   -> L.build_call equalf_func [| m1';m2' |] "equalf" builder
					| A.Neq     -> let eq = L.build_call equalf_func [| m1';m2' |] "equalf" builder in
													L.build_xor eq (L.const_int i32_t 1) "and" builder
					| _        	-> raise(Failure "internal error: semant should have rejected")
					in ret
				| SBinop ((_ as m1), (_ as op), ((A.Matrix(A.Float),_) as m2)) -> 
						let m1' = expr builder m1
						and m2' = expr builder m2 in
						let ret = match op with 
						| A.Mult    -> 
							let (t, _) = m1 in
							let ret_val = match t with 
									A.Int -> 
									let scalar = L.build_sitofp m1' float_t "scalar" builder in
									L.build_call scalarmf_func [| scalar;m2' |] "scalarmf" builder
								| A.Float ->
									L.build_call scalarmf_func [| m1';m2' |] "scalarm" builder
								| _ -> raise(Failure "should be caught elsewhere")
							in ret_val
						| _        	-> raise(Failure "internal error: semant should have rejected")
						in ret
				| SBinop ((t1, e1), op, (t2, e2)) when t1 == A.Float ->
					let e1' = expr builder (t1, e1)
					and e2' = expr builder (t2, e2) in
					let e2' = if t2 == A.Float then e2' else (L.build_uitofp e2' float_t "float_e2" builder) in
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
					| _ ->
							raise (Failure "internal error: semant should have rejected and/or on float")
					) e1' e2' "tmp" builder
				| SBinop ((t1, e1), op, (t2, e2)) when t2 == A.Float -> 
					let e1' = expr builder (t1, e1)
					and e2' = expr builder (t2, e2) in
					let e1' = if t1 == A.Float then e1' else (L.build_sitofp e1' float_t "float_e1" builder) in
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
					| _ ->
							raise (Failure "internal error: semant should have rejected and/or on float")
					) e1' e2' "tmp" builder
				| SBinop (e1, op, e2) -> 
					let e1' = expr builder e1
					and e2' = expr builder e2 in
					(match op with
						A.Add     -> L.build_add
					| A.Sub     -> L.build_sub
					| A.Mult    -> L.build_mul
					| A.Div     -> L.build_sdiv
					| A.Mod     -> L.build_srem  
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
				| SCall ("getRows", [e]) ->
					let matrix = expr builder e in
					get_matrix_rows matrix builder
				| SCall ("getColumns", [e]) ->
					let matrix = expr builder e in
					get_matrix_cols matrix builder
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
						let bool_val = expr builder predicate in
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
						let bool_val = expr pred_builder predicate in
						let merge_bb = L.append_block context "merge" the_function in
						ignore(L.build_cond_br bool_val body_bb merge_bb pred_builder);
						L.builder_at_end context merge_bb
				| SVarDecl (t, id, e) -> 
							let local_var = L.build_alloca (ltype_of_typ t) id builder in 
							Hashtbl.add var_hash id local_var;
							let e' = expr builder e in
							let e_type = L.string_of_lltype (L.type_of e')
							and s_type = L.string_of_lltype (ltype_of_typ t) in
							let e_fixed = match (s_type, e_type) with
								"double", "i32" -> L.build_sitofp e' float_t "e_float" builder 
								| _ -> e'
						in
							ignore(L.build_store e_fixed (lookup id) builder); builder	
				| SUpdate (m, r, c, e) -> 
						(* get desired pointer location *)
						let matrix = expr builder m
						and row_idx = expr builder r
						and col_idx = expr builder c in 
						let cols = get_matrix_cols matrix builder in
						(* row = row_idx * cols *)
						let row = L.build_mul row_idx cols "row" builder in 
						(* row_col = (row_idx * cols) + col_idx *)
						let row_col = L.build_add row col_idx "row_col" builder 
						and offset = L.const_int i32_t 2 in 
						(* idx = 2 + (row_idx * cols) + col_idx *)
						let idx = L.build_add offset row_col "idx" builder in
						let ptr = L.build_in_bounds_gep matrix [| idx |] "ptr" builder in
						(* update value at that location *)
						let e' = expr builder e in
						let m_typ = L.string_of_lltype (L.type_of matrix) 
						and e_typ = L.string_of_lltype (L.type_of e') in 
						let e_fixed = match (m_typ, e_typ) with
						    "double*", "i32" -> L.build_uitofp e' float_t "float_e" builder
							| "i32*", "double" -> L.build_fptosi e' i32_t "int_e" builder 
							| _ -> e'
						in

						ignore(L.build_store e_fixed ptr builder); builder
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