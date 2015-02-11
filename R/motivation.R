## This software is licensed under the MIT "Expat" License.
## <http://opensource.org/licenses/MIT>

## Copyright (c) 2015 Gray Calhoun

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

## This code should be run in the directory above ./R
source("R/functions.R")

col <- "dark gray"
pdf(file = "graphs/motivation.pdf", width = 6, height = 1.5)
par(mfcol = c(1, 3), mar = c(2,3,3,1), fg = col, col.axis = "black",
    col.main = "black", bty = "n")
plot(0:5, .2^(0:5), type = "p", pch = 19, main = "IRF, no interpolation", col = "black")
for (i in 0:5) {
    lines(c(i,i), c(0,.2^i), type = "l", col = "black")
}
abline(0, 0, col = rgb(0,0,0,.2))
plot(0:5, .2^(0:5), type = "l", main = "IRF, linear interpolation", col = "black")
abline(0, 0, col = rgb(0,0,0,.2))
curve(.2^x, from = 0, to = 5, main = "IRF, smooth interpolation", col = "black")
abline(0, 0, col = rgb(0,0,0,.2))
dev.off()

pdf(file = "graphs/motivation2.pdf", width = 6, height = 1.5)
par(mfcol = c(1, 3), mar = c(2,3,3,1), fg = col, col.axis = "black",
    col.main = "black", bty = "n")
plot(0:5, (-.2)^(0:5), type = "p", pch = 19, main = "IRF, no interpolation", col = "black")
for (i in 0:5) {
    lines(c(i,i), c(0,(-.2)^i), type = "l", col = "black")
}
abline(0, 0, col = rgb(0,0,0,.2))
plot(0:5, (-.2)^(0:5), type = "l", main = "IRF, linear interpolation", col = "black")
abline(0, 0, col = rgb(0,0,0,.2))
curve(.2^x * cos(pi * x), from = 0, to = 5, main = "IRF, smooth interpolation", col = "black")
abline(0, 0, col = rgb(0,0,0,.2))
dev.off()
