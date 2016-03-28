## This software is licensed under the MIT "Expat" License.
## <http://opensource.org/licenses/MIT>
##
## Copyright (c) 2015 Gray Calhoun
##
## Permission is hereby granted, free of charge, to any person
## obtaining a copy of this software and associated documentation
## files (the "Software"), to deal in the Software without
## restriction, including without limitation the rights to use, copy,
## modify, merge, publish, distribute, sublicense, and/or sell copies
## of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.
##
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

makeshock <- function(V = NULL, P = t(chol(V)), e = rnorm(ncol(P))) {
    drop(P %*% e / sqrt(sum(e * e)))
}

newvar <- function(y, p) {
    k <- ncol(y)
    z = y[-(1:p),]
    x = matrix(1, nrow(z), 1 + p*k)
    for (i in 1:p) {
        x[,1 + (((i-1)*k + 1):(i*k))] = y[((p+1):nrow(y)) - i,]
    }
    m <- lapply(1:k, function(i) lm.fit(x, z[,i]))
    ep <- sapply(m, residuals)
    list(A = t(sapply(m, function(mi) coefficients(mi)[-1])),
         V = var(ep),
         resid = ep)
}

get_irfs <- function(A, shock, M, N = 100) {
    k <- nrow(A)
    p <- ncol(A) / k
    e <- eigen(canonical(A), symmetric = FALSE)
    V <- e$vectors
    Vi <- solve(V)
    xout <- seq(0, M, by = 1/N)
    yout <- matrix(0, k, length(xout))
    yout[,1] <- shock
    y0 <- rep(0, p*k)
    y0[1:k] <- shock

    for (i in 2:ncol(yout)) {
        yout[,i] <- Re(V %*% diag(e$values^((i-1)/N)) %*% Vi %*% y0)[1:k]
    }
    list(x = xout, y = yout)
}

d1 <- read.csv("data/Newdata1.csv")
d1$NBREC <- log(d1$NBREC)
d1$TRES <- log(d1$TRES)
d1$PSCCOM <- log(d1$PSCCOM)
d2 <- read.csv("data/Newgdp97.csv")
d2$GDPM <- log(d2$GDPM)
d2$PGDPM <- log(d2$PGDPM)

d <- cbind(ts(as.matrix(subset(d1, select = -X)), start = c(1959,1), frequency = 12),
           ts(as.matrix(subset(d2, select = -X)), start = c(1965,1), frequency = 12))
colnames(d) <- c(names(d1)[-1], names(d2)[-1])
d <- window(d, start = c(1965,1))
rm(d1, d2)

maxiter <- 15000
M <- 60
Nsmooth <- 20

v <- newvar(d, 6)
P <- t(chol(v$V))

irfs1 <- replicate(500, simplify = FALSE, {
    for (j in 1:maxiter) {
        ## Calculate potential shock, then normalize so that it
        ## induces a 1ppt move in the Federal Funds rate.
        shock <- makeshock(P = P)
        icoarse <- get_irfs(v$A, shock, M, 1)
        ismooth <- get_irfs(v$A, shock, M, Nsmooth)

        rownames(icoarse$y) <- colnames(d)
        rownames(ismooth$y) <- colnames(d)

        if (all(ismooth$y["NBREC", ismooth$x <= 5] <= 0) &&
            all(ismooth$y["PGDPM", ismooth$x <= 5] <= 0) &&
            all(ismooth$y["FYFF", ismooth$x  <= 5] >= 0))
            break
    }
    stopifnot(j < maxiter)
    list(coarse = icoarse$y, smooth = ismooth$y)
})

subplot1 <- function(irfs, type, series, N, linecolor,...) {
    y <- ts(100 * sapply(irfs, function(z) z[[type]][series,]), start = 0, freq = N)
    plot(y, plot.type = "single", bty = "n", las = 1, col = linecolor, xlab="", ylab="",...)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:5) {
        lines(c(i,i), range(y), col = rgb(0,0,0,.2))
    }
}

linecolor = rgb(0,0,0,0.08)
N <- 12 * Nsmooth
pdf(file = "graphs/empirics.pdf", width=6.5, height=8)
par(fg = "dark gray", col.axis = "black", col.main = "black", mfcol=c(3,2), col = "dark gray",
    cex.main = 1, cex.axis = .9, cex.lab = .9, mar = c(2.5,3,3,1.5))
subplot1(irfs1, "smooth", "GDPM", N, linecolor, main = 'Percent change in GDP')
subplot1(irfs1, "smooth", "FYFF", N, linecolor, main = 'Change in Federal Funds rate (basis points)')
subplot1(irfs1, "smooth", "TRES", N, linecolor, main = 'Percent change in total reserves')
subplot1(irfs1, "smooth", "PGDPM", N, linecolor, main = 'Percent change in GDP deflator')
subplot1(irfs1, "smooth", "PSCCOM", N, linecolor, main = 'Percent change in commodity price index')
subplot1(irfs1, "smooth", "NBREC", N, linecolor, main = 'Percent change in non-borrowed reserves')
dev.off()
