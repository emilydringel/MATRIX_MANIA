parser.native: parser.mly ast.ml scanner.mll
	ocamlbuild parser.native

scanner.native: scanner.mll
	ocamlbuild -r scanner.native

.PHONY : all
all: clean scanner.native

.PHONY : clean
clean:
	ocamlbuild -clean
	rm scanner.native parser.native
	rm parser.ml parser.mli parser.output