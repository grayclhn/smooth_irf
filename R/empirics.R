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
library(dplyr)

newvar <- function(y, p) {
    k <- ncol(y)
    z = y[-(1:p),]
    ynames <- if (is.null(colnames(y))) {
        paste("y", 1:k, sep = "")
    } else {
        colnames(y)
    }
    x = matrix(1, nrow(z), 1 + p*k)
    xnames <- character(p*k)
    for (i in 1:p) {
        xcols_i<- 1 + (((i-1)*k + 1):(i*k))
        x[,xcols_i] = y[((p+1):nrow(y)) - i,]
        xnames[xcols_i - 1] <- paste(ynames, "_L", i, sep = "")
    }
    m <- lapply(1:k, function(i) lm.fit(x, z[,i]))
    A <- t(sapply(m, function(mi) coefficients(mi)[-1]))
    ep <- sapply(m, residuals)
    rownames(A) <- ynames
    colnames(A) <- xnames
    colnames(ep) <- ynames
    list(A = A, V = var(ep), resid = ep)
}

get_irfs <- function(A, shock, M, N = 100, sumindex= NULL) {
    k <- nrow(A)
    p <- ncol(A) / k
    nsum <- length(sumindex)
    F <- matrix(0, k * p + nsum, k * p + nsum)
    colnames(F) <- c(paste("Δ⁻(", rownames(A)[sumindex], ")_L1", sep = ""), colnames(A))
    rownames(F) <- c(paste("Δ⁻", rownames(A)[sumindex], sep = ""), rownames(A), colnames(A)[1:(k*(p-1))])
    diag(F[1:nsum,1:nsum]) <- 1
    F[-(1:nsum), -(1:nsum)] <- canonical(A)
    F[1:nsum, -(1:nsum)] <- A[sumindex,]

    e <- eigen(F, symmetric = FALSE)
    V <- e$vectors
    Vi <- solve(V)
    
    y0 <- rep(0, nrow(F))
    y0[1:(k + nsum)] <- c(shock[sumindex], shock)
    xout <- seq(0, M, by = 1/N)
    yout <- matrix(0, k, length(xout))
    yout[,1] <- y0[1:k]

    for (i in 2:ncol(yout)) {
        yout[,i] <- Re(V %*% diag(e$values^((i-1)/N)) %*% Vi %*% y0)[1:k]
    }
    rownames(yout) <- rownames(F)[1:k]
    list(x = xout, y = yout)
}

makeshock <- function(V = NULL, P = t(chol(V)), e = rnorm(ncol(P))) {
    s <- drop(P %*% e / sqrt(sum(e * e)))
    s * 100 / s[1] ## scale to be a 100bp shock in abs value
}

d <-
    cbind(r = ts(data = read.csv("data/DFF.csv")$VALUE,
              start = c(1954,3), freq=4),
          Δy = 25 * diff(ts(data = read.csv("data/GDPC1.csv")$VALUE,
              start = c(1947,1), frequency=4)),
          π = 25 * diff(ts(data = read.csv("data/GDPDEF.csv")$VALUE,
              start = c(1947,1), frequency=4))) %>%
    window(start = c(1955,1), end=c(2014,4))
v <- newvar(d, 4)
P = t(chol(v$V))

maxiter <- 5000
Nsmooth <- 20
M <- 2.5 * 4

varboot <- function(A, ep) {
    n <- nrow(ep)
    k <- ncol(ep)
    p <- ncol(A) / k
    y <- matrix(nrow = n, ncol = k)
    y[1:p,] <- ep[sample(1:n, p, replace = TRUE),]
    for (i in (p+1):n) {
        y[i,] <- drop(A %*% c(t(y[i - (1:p),]))) + ep[sample(1:n, 1),]
    }
    colnames(y) <- rownames(A)
    y
}

irfs <- replicate(150, simplify = FALSE, {
    for (j in 1:maxiter) {
        yboot <- varboot(v$A, v$resid)
        bootest <- newvar(yboot, 4)
        shock <- makeshock(bootest$V)
        icoarse <- get_irfs(bootest$A, shock, M, 1, sumindex = c(2,3))
        ismooth <- get_irfs(bootest$A, shock, M, Nsmooth, sumindex = c(2,3))
        if (all(ismooth$y[3,ismooth$x <=2] >= 0)
            && all(ismooth$y[2, ismooth$x <= 2] <= 0)
            && all(abs(ismooth$y[2,]) <= 30)
            && all(abs(ismooth$y[1,]) <= 30)
            && all(abs(ismooth$y[3,]) <= abs(2 * ismooth$y[3,1])))
            break
    }
    stopifnot(j < maxiter)
    list(coarse = icoarse$y, smooth = ismooth$y)
})

subplot1 <- function(irfs, type, series, N,...) {
    y <- ts(sapply(irfs, function(z) z[[type]][series,]), start = 0, freq = N)
    plot(y, plot.type = "single", bty = "n", xlab = "", ylab = "", lwd = 1.5,...)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:5) {
        lines(c(i,i), range(y), col = rgb(0,0,0,.2))
    }
}

makeplot <- function(irfs, file, N, linecolor,...) {
    col = "dark gray"
    pdf(file = file, width = 6, height = 7)
    par(mfcol = c(3, 2), mar = c(2,3,3,1), fg = col,
        col.axis = "black", col.main = "black")
    subplot1(irfs, "coarse", 1, 4, col = linecolor, main = "GDP (percent difference)")
    subplot1(irfs, "coarse", 2, 4, col = linecolor, main = "Prices (percent difference)")
    subplot1(irfs, "coarse", 3, 4, col = linecolor, main = "Fed. Funds")
    subplot1(irfs, "smooth", 1, N * 4, col = linecolor, main = "GDP (smooth)")
    subplot1(irfs, "smooth", 2, N * 4, col = linecolor, main = "Prices (smooth)")
    subplot1(irfs, "smooth", 3, N * 4, col = linecolor, main = "Fed. Funds (smooth)")
    dev.off()
}

makeplot(irfs, "graphs/empirics.pdf", N = Nsmooth, rgb(0,0,0,.1))
