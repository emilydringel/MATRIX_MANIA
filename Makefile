matrixmania.native: matrixmania.ml codegen.ml semant.ml parser.native scanner.native
	ocamlbuild -use-ocamlfind -r matrixmania.native -pkgs llvm,llvm.analysis

parser.native: parser.mly ast.ml scanner.mll
	ocamlbuild parser.native

scanner.native: scanner.mll
	ocamlbuild -r scanner.native

printm.o:
	gcc -c c_functions/matrix_functions.c

test: matrixmania.native c_functions/matrix_functions.o
	./matrixmania.native $(filename) > test.ll
	echo -n "output: "
	llc -relocation-model=pic test.ll
	gcc -o myexe test.s c_functions/matrix_functions.o
	./myexe
	rm test.ll
	rm myexe
	rm test.s
	rm c_functions/*.o

.PHONY : all
all: clean matrixmania.native c_functions/matrix_functions.o

.PHONY : clean
clean:
	ocamlbuild -clean
	rm -f *.ll
	rm -f *.native
	rm -f parser.ml parser.mli parser.output
	rm -rf _build
	rm -f c_functions/*.o *.o
	rm -f *.exe
	rm -f *.s
	rm -f *.output
