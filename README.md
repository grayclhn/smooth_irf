smooth_irf overview
===================

This repository contains the code and data for the working paper *A
method for smoothing the Impulse Response Functions of discrete-time
linear models* by Gray Calhoun.  If you have trouble reproducing the
paper's analysis, please contact Gray Calhoun:
<gcalhoun@iastate.edu>. A pdf of the latest version of the paper
should be available at <http://gray.clhn.org> and you can find the
latest version of this directory at
<https://github.com/grayclhn/smooth_irf>.

Some details:

- JEL codes: C32, E52
- Keywords: Vector Autoregression, multivariate time series, policy
  shocks
- The project is at version 0.3.

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
<https://github.com/grayclhn/smooth_irf/issues>.
Thanks!
