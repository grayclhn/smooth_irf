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

get_irfs <- function(A, v, N = 100, M = 12, xstart = 0) {
    k <- nrow(A)
    p <- ncol(A) / k
    e <- eigen(canonical(A), symmetric = FALSE)
    V <- e$vectors
    Vi <- solve(V)
    xout <- seq(xstart, M, by = 1/N)
    yout <- matrix(0, k, length(xout))
    ystart <- which(xout == 0)
    yout[v, ystart] <- 1
    y0 <- rep(0, p*k)
    y0[v] <- 1

    for (i in (ystart+1):ncol(yout)) {
        yout[,i] <- Re(V %*% diag(e$values^((i-ystart)/N)) %*% Vi %*% y0)[1:2,]
    }
    list(x = xout, y = yout)
}

## Graphs for Figure 1

A <- matrix(c(-0.5, 0.01, -0.2, 0.1, 0.3, 0.1, -0.1, 0.0),
            nrow = 2, byrow = TRUE)

## shock to y1
icoarse1 <- get_irfs(A, 1, 1, 8)
ismooth1 <- get_irfs(A, 1, 100, 8)
## shock to y2
icoarse2 <- get_irfs(A, 2, 1, 8)
ismooth2 <- get_irfs(A, 2, 100, 8)

subplot1 <- function(irf, yvar,...) {
    plot(irf$x, irf$y[yvar,], "l", ylim = c(-.7, 1.1), lwd = 2,
         bty = "n", xlab = "", ylab = "", col = "black",...)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:8) {
        lines(c(i,i), c(-.6, 1), col = rgb(0,0,0,.2))
    }
}

col <- "dark gray"
pdf(file = "graphs/numeric.pdf", width = 6, height = 7)
par(mfcol = c(4, 2), mar = c(2,3,3,1), fg = col,
    col.axis = "black", col.main = "black")
subplot1(icoarse1, 1, main = "y_1 shock on y_1")
subplot1(icoarse1, 2, main = "y_1 shock on y_2")
subplot1(icoarse2, 1, main = "y_2 shock on y_1")
subplot1(icoarse2, 2, main = "y_2 shock on y_2")
subplot1(ismooth1, 1, main = "y_1 shock on y_1 (smoothed)")
subplot1(ismooth1, 2, main = "y_1 shock on y_2 (smoothed)")
subplot1(ismooth2, 1, main = "y_2 shock on y_1 (smoothed)")
subplot1(ismooth2, 2, main = "y_2 shock on y_2 (smoothed)")
dev.off()

## Graphs for Figure 2
nsim <- 150
ycoarse1on1 <- ycoarse1on2 <- ycoarse2on1 <- ycoarse2on2 <-
    ts(matrix(nrow = 9, ncol = nsim), start = 0, frequency = 1)
ysmooth1on1 <- ysmooth1on2 <- ysmooth2on1 <- ysmooth2on2 <-
    ts(matrix(nrow = 801, ncol = nsim), start = 0, frequency = 100)

for (i in 1:nsim) {
    Ai <- A + rnorm(length(A), 0, .15)
    c1 <- get_irfs(Ai, 1, 1, 8)
    ycoarse1on1[,i] <- c1$y[1,]
    ycoarse1on2[,i] <- c1$y[2,]
    s1 <- get_irfs(Ai, 1, 100, 8)
    ysmooth1on1[,i] <- s1$y[1,]
    ysmooth1on2[,i] <- s1$y[2,]
    c2 <- get_irfs(Ai, 2, 1, 8)
    ycoarse2on1[,i] <- c2$y[1,]
    ycoarse2on2[,i] <- c2$y[2,]
    s2 <- get_irfs(Ai, 2, 100, 8)
    ysmooth2on1[,i] <- s2$y[1,]
    ysmooth2on2[,i] <- s2$y[2,]
}

subplot2 <- function(ys,...) {
    plot(ys, plot.type = "single", ylim = c(-.7, 1.1), lwd = 1.5,
         bty = "n", xlab = "", ylab = "",...)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:8) {
        lines(c(i,i), c(-.6, 1), col = rgb(0,0,0,.2))
    }
}

pdf(file = "graphs/numeric2.pdf", width = 6, height = 7)
par(mfcol = c(4, 2), mar = c(2,3,3,1), fg = col,
    col.axis = "black", col.main = "black")
subplot2(ycoarse1on1, main = "y_1 shock on y_1", col = rgb(0,0,0,.05))
subplot2(ycoarse1on2, main = "y_1 shock on y_2", col = rgb(0,0,0,.05))
subplot2(ycoarse2on1, main = "y_2 shock on y_1", col = rgb(0,0,0,.05))
subplot2(ycoarse2on2, main = "y_2 shock on y_2", col = rgb(0,0,0,.05))
subplot2(ysmooth1on1, main = "y_1 shock on y_1 (smooth)", col = rgb(0,0,0,.05))
subplot2(ysmooth1on2, main = "y_1 shock on y_2 (smooth)", col = rgb(0,0,0,.05))
subplot2(ysmooth2on1, main = "y_2 shock on y_1 (smooth)", col = rgb(0,0,0,.05))
subplot2(ysmooth2on2, main = "y_2 shock on y_2 (smooth)", col = rgb(0,0,0,.05))
dev.off()
