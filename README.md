smooth_irf overview
===================

This repository contains the code and data for my (Gray Calhoun's)
working paper *Smooth interpolation for Impulse Response Functions of
SVARs*.  If you have trouble reproducing the paper's analysis, please
contact me: <gcalhoun@iastate.edu>. A pdf of the latest version of the
paper should be available at my homepage
<http://www.econ.iastate.edu/~gcalhoun> and you can find the latest
version of this directory at
<https://git.ece.iastate.edu/gcalhoun/smooth_irf>.

This directory is for the 2015-02-22 version of the paper, which will
be submitted to summer conferences and probably to a journal soon.

Main files
----------

* `smoothirf.tex` is the LaTeX source for the paper itself.
* The `R` directory contains the R code used to generate graphs

Generating the pdf file and dependencies
----------------------------------------

To make the paper, you need R and LaTeX. You can run each of the files
in `R` from the main project directory, which will generate the right
pdf graphs in the `./graphs` subdirectory, then run `pdflatex` and
`bibtex` on `smoothirf.tex`. You may need to install some R and LaTeX
packages first.

If you install GNU Make and latexmk, you can streamline the process by
typing `make` in this directory, which will call all of the necessary
commands in the right order.

License and copying
-------------------

Copyright (c) 2015, Gray Calhoun.

All of the R code for this project is licensed under the
[MIT "Expat" License](http://opensource.org/licenses/MIT):

> Permission is hereby granted, free of charge, to any person
> obtaining a copy of this software and associated documentation
> files (the "Software"), to deal in the Software without
> restriction, including without limitation the rights to use, copy,
> modify, merge, publish, distribute, sublicense, and/or sell copies
> of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be
> included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.

Errors and contact information
------------------------------

Please let me know if you find errors. You can email
<gcalhoun@iastate.edu> or file an issue at
<https://git.ece.iastate.edu/gcalhoun/smooth_irf/issues>.
Thanks!
