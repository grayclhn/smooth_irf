## This software is licensed under the MIT "Expat" License.
## <http://opensource.org/licenses/MIT>

## Copyright (c) 2013–2015 Gray Calhoun

## Permission is hereby granted, free of charge, to any person
## obtaining a copy of this software and associated documentation
## files (the "Software"), to deal in the Software without
## restriction, including without limitation the rights to use, copy,
## modify, merge, publish, distribute, sublicense, and/or sell copies
## of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:

## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.

## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
## MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
## BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
## ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

.PHONY: all clean burn zip
all: smoothirf.pdf
zip: smoothirf.zip

latexmk = latexmk
Rscript = Rscript

.DELETE_ON_ERROR:

plots = $(addsuffix .pdf,$(addprefix graphs/,numeric numeric2 motivation motivation2))

graphs/motivation.pdf graphs/motivation2.pdf: R/motivation.R
	$(Rscript) $< &> $<out
graphs/numeric.pdf graphs/numeric2.pdf: R/numeric_example.R
	$(Rscript) $< &> $<out

smoothirf.pdf: smoothirf.tex VERSION.tex latex_misc/abbrevs.tex localrefs.bib $(plots)
	$(latexmk) -pdf -silent $<

smoothirf.zip: $(zipped) smoothirf.pdf $(plots) $(shell git ls-tree -r HEAD --name-only)
	zip -ruo9 $@ $^ -x *.gitignore

clean: 
	$(latexmk) -c smoothirf.tex
	rm -f *~ *.Rout
burn: clean
	$(latexmk) -C smoothirf.tex
	rm -f graphs/*.pdf *.zip *.bbl
