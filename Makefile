# Makefile for preparing files for distribution

.PHONY: distribution test mkdirs clean cleanall cleantest

default:
	@echo "Type:"
	@echo "make distribution    - to prepare distribution directory dist"
	@echo "make test            - to run suite of example files to check against output of previous version"

distribution: mkdirs dist/latexdiff dist/latexrevise dist/latexdiff-so dist/latexdiff-fast dist/latexdiff-vc dist/latexdiff.1 dist/latexrevise.1 dist/latexdiff-vc.1 dist/doc/latexdiff-man.pdf dist/example/example-draft.tex dist/example/example-rev.tex dist/doc/example-diff.tex dist/doc/latexdiff-man.tex dist/COPYING dist/README

mkdirs:
	mkdir -p dist/doc
	mkdir -p dist/example

latexdiff.tar: distribution
	cd dist; tar -cvf ../latexdiff.tar .

dist/latexdiff: latexdiff
	grep -v '^###' latexdiff > dist/latexdiff ; chmod a+x dist/latexdiff

dist/latexrevise: latexrevise
	grep -v '^###' latexrevise > dist/latexrevise ; chmod a+x dist/latexrevise

dist/latexdiff-vc: latexdiff-vc
	grep -v '^###' latexdiff-vc > dist/latexdiff-vc ; chmod a+x dist/latexdiff-vc

dist/latexdiff-so: latexdiff Algorithm-Diff-Block
	awk '/use Algorithm::Diff qw\(traverse_sequences\);/ { system("cat Algorithm-Diff-Block") ; next } { print }' latexdiff | grep -v '^###' > dist/latexdiff-so ; chmod a+x dist/latexdiff-so

dist/latexdiff-fast: latexdiff Algorithm-Diff-Fast
	awk '/use Algorithm::Diff qw\(traverse_sequences\);/ { system("cat Algorithm-Diff-Fast") ; next } { print }' latexdiff | grep -v '^###' > dist/latexdiff-fast ; chmod a+x dist/latexdiff-fast

dist/latexdiff.1: latexdiff
	pod2man -center=" " latexdiff > dist/latexdiff.1

dist/latexrevise.1: latexrevise
	pod2man -center=" " latexrevise > dist/latexrevise.1

dist/latexdiff-vc.1: latexdiff-vc
	pod2man -center=" " latexdiff-vc > dist/latexdiff-vc.1

dist/doc/latexdiff-man.pdf: latexdiff-man.tex latexdiff.tex latexdiff-vc.tex latexrevise.tex example-diff.pdf
	pdflatex latexdiff-man.tex
	pdflatex latexdiff-man.tex
	mv latexdiff-man.pdf dist/doc

dist/doc/example-diff.tex: example-diff.tex
	cp $^ $@

dist/doc/latexdiff-man.tex: latexdiff-man.tex
	cp $^ $@

dist/doc/latexdiff.tex: latexdiff.tex
	cp $^ $@

dist/doc/latexrevise.tex: latexrevise.tex
	cp $^ $@

dist/doc/latexdiff-vc.tex: latexrevise.tex
	cp $^ $@

latexdiff.tex: latexdiff
	pod2latex latexdiff; sed 's/--/-{}-/g' latexdiff.tex > tmp$$.tex ; mv tmp$$.tex latexdiff.tex

latexrevise.tex: latexrevise
	pod2latex latexrevise ; sed 's/--/-{}-/g' latexrevise.tex > tmp$$.tex ; mv tmp$$.tex latexrevise.tex

latexdiff-vc.tex: latexdiff-vc
	pod2latex latexdiff-vc; sed 's/--/-{}-/g' latexdiff-vc.tex > tmp$$.tex ; mv tmp$$.tex latexdiff-vc.tex

example-diff.pdf: example-diff.tex
	pdflatex example-diff.tex

example-diff.tex: example-draft.tex example-rev.tex latexdiff
	latexdiff -t UNDERLINE example-draft.tex example-rev.tex > example-diff.tex

dist/example/example-draft.tex: example-draft.tex
	cp $< $@

dist/example/example-rev.tex: example-rev.tex
	cp $< $@

dist/README: README
	cp $< $@

dist/COPYING: COPYING
	cp $< $@

clean:
	\rm *.aux *.pdf *.log latexdiff.debug.* example-diff.tex latexdiff.tex latexdiff-vc.tex latexrevise.tex

cleantest:
	\rm testsuite/*-diff.tex  testsuite/*.{aux,log,pdf}

cleanall: clean cleantest
	\rm -r dist 

test:
	cd testsuite; verify --run


