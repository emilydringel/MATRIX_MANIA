matrixmania.native: matrixmania.ml codegen.ml semant.ml parser.native scanner.native
	ocamlbuild -use-ocamlfind -r matrixmania.native -pkgs llvm,llvm.analysis

parser.native: parser.mly ast.ml scanner.mll
	ocamlbuild parser.native

scanner.native: scanner.mll
	ocamlbuild -r scanner.native

test: matrixmania.native 
	./matrixmania.native $(filename) > test.ll
	echo -n "output: "
	llc -relocation-model=pic test.ll
	gcc -o myexe test.s printm.o
	./myexe

.PHONY : all
all: clean matrixmania.native printm.o

.PHONY : clean
clean:
	ocamlbuild -clean
	rm -f *.li
	rm -f *.native
	rm -f parser.ml parser.mli parser.output
	rm -rf _build
	rm -f *.o
