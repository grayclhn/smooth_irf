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
icoarse1 <- get_irfs(A, 1, 1, 5)
ismooth1 <- get_irfs(A, 1, 100, 5)
## shock to y2
icoarse2 <- get_irfs(A, 2, 1, 5)
ismooth2 <- get_irfs(A, 2, 100, 5)

subplot1 <- function(irf, yvar,...) {
    plot(irf$x, irf$y[yvar,], "l", ylim = c(-.6, 1.1), lwd = 1,
        yaxp = c(-.5, 1, 3), bty = "n", xlab = "", ylab = "", col = "black", las=1,...)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:5) {
        lines(c(i,i), c(-.6, 1), col = rgb(0,0,0,.2))
    }
}

subplot1b <- function(irf, yvar,...) {
    plot(irf$x, irf$y[yvar,], "l", ylim = c(-.6, 1.1), lwd = 1,
        yaxp = c(-.5, 1, 3), bty = "n", xlab = "", ylab = "", col = "dark gray", las=1,...)
    points(0:5, irf$y[yvar,irf$x %in% 0:5], col = "black", lwd = 1.2)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:5) {
        lines(c(i,i), c(-.6, 1), col = rgb(0,0,0,.2))
    }
}

col <- "dark gray"
pdf(file = "graphs/numeric.pdf", width = 6.5, height = 7)
par(mfcol = c(4, 3), mar = c(2,3,3,1), fg = col,
    col.axis = "black", col.main = "black")
subplot1(icoarse1, 1, main = expression(underline(paste(epsilon[1], "-shock on ", y[1]))))
subplot1(icoarse1, 2, main = expression(underline(paste(epsilon[1], "-shock on ", y[2]))))
subplot1(icoarse2, 1, main = expression(underline(paste(epsilon[2], "-shock on ", y[1]))))
subplot1(icoarse2, 2, main = expression(underline(paste(epsilon[2], "-shock on ", y[2]))))
subplot1(ismooth1, 1, main = expression(underline(paste(epsilon[1], "-shock on ", y[1], " (smooth)"))))
subplot1(ismooth1, 2, main = expression(underline(paste(epsilon[1], "-shock on ", y[2], " (smooth)"))))
subplot1(ismooth2, 1, main = expression(underline(paste(epsilon[2], "-shock on ", y[1], " (smooth)"))))
subplot1(ismooth2, 2, main = expression(underline(paste(epsilon[2], "-shock on ", y[2], " (smooth)"))))
subplot1b(ismooth1, 1, main = expression(underline(paste(epsilon[1], "-shock on ", y[1], " (both)"))))
subplot1b(ismooth1, 2, main = expression(underline(paste(epsilon[1], "-shock on ", y[2], " (both)"))))
subplot1b(ismooth2, 1, main = expression(underline(paste(epsilon[2], "-shock on ", y[1], " (both)"))))
subplot1b(ismooth2, 2, main = expression(underline(paste(epsilon[2], "-shock on ", y[2], " (both)"))))
dev.off()

## Graphs for Figure 2
nsim <- 150
ycoarse1on1 <- ycoarse1on2 <- ycoarse2on1 <- ycoarse2on2 <-
    ts(matrix(nrow = 6, ncol = nsim), start = 0, frequency = 1)
ysmooth1on1 <- ysmooth1on2 <- ysmooth2on1 <- ysmooth2on2 <-
    ts(matrix(nrow = 501, ncol = nsim), start = 0, frequency = 100)

for (i in 1:nsim) {
    Ai <- A + rnorm(length(A), 0, .15)
    c1 <- get_irfs(Ai, 1, 1, 5)
    ycoarse1on1[,i] <- c1$y[1,]
    ycoarse1on2[,i] <- c1$y[2,]
    s1 <- get_irfs(Ai, 1, 100, 5)
    ysmooth1on1[,i] <- s1$y[1,]
    ysmooth1on2[,i] <- s1$y[2,]
    c2 <- get_irfs(Ai, 2, 1, 5)
    ycoarse2on1[,i] <- c2$y[1,]
    ycoarse2on2[,i] <- c2$y[2,]
    s2 <- get_irfs(Ai, 2, 100, 5)
    ysmooth2on1[,i] <- s2$y[1,]
    ysmooth2on2[,i] <- s2$y[2,]
}

subplot2 <- function(ys,...) {
    plot(ys, plot.type = "single", ylim = c(-1.3, 1.7), lwd = 1,
    yaxp = c(-1, 1.5, 5), bty = "n", xlab = "", ylab = "", las=1, col=rgb(0.1,0.1,0.1,0.175),...)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:5) {
        lines(c(i,i), c(-.6, 1), col = rgb(0,0,0,.2))
    }
}

subplot2b <- function(ys,...) {
    plot(ys, plot.type = "single", ylim = c(-1.3, 1.7), lwd = 1,
        yaxp = c(-1, 1.5, 5), bty = "n", xlab = "", ylab = "", las=1, col=rgb(.25,.25,.25,.1),...)
    points(rep(0:5, ncol(ys)), c(ys[time(ys) %in% 0:5,]), col = rgb(0,0,0,.1), lwd = 1)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:5) {
        lines(c(i,i), c(-.6, 1), col = rgb(0,0,0,.2))
    }
}

pdf(file = "graphs/numeric2.pdf", width = 6.5, height = 7)
par(mfcol = c(4, 3), mar = c(2,3,3,1), fg = col,
    col.axis = "black", col.main = "black")
subplot2(ycoarse1on1, main = expression(underline(paste(epsilon[1], "-shock on ", y[1]))))
subplot2(ycoarse1on2, main = expression(underline(paste(epsilon[1], "-shock on ", y[2]))))
subplot2(ycoarse2on1, main = expression(underline(paste(epsilon[2], "-shock on ", y[1]))))
subplot2(ycoarse2on2, main = expression(underline(paste(epsilon[2], "-shock on ", y[2]))))
subplot2(ysmooth1on1, main = expression(underline(paste(epsilon[1], "-shock on ", y[1], " (smooth)"))))
subplot2(ysmooth1on2, main = expression(underline(paste(epsilon[1], "-shock on ", y[2], " (smooth)"))))
subplot2(ysmooth2on1, main = expression(underline(paste(epsilon[2], "-shock on ", y[1], " (smooth)"))))
subplot2(ysmooth2on2, main = expression(underline(paste(epsilon[2], "-shock on ", y[2], " (smooth)"))))
subplot2b(ysmooth1on1, main = expression(underline(paste(epsilon[1], "-shock on ", y[1], " (both)"))))
subplot2b(ysmooth1on2, main = expression(underline(paste(epsilon[1], "-shock on ", y[2], " (both)"))))
subplot2b(ysmooth2on1, main = expression(underline(paste(epsilon[2], "-shock on ", y[1], " (both)"))))
subplot2b(ysmooth2on2, main = expression(underline(paste(epsilon[2], "-shock on ", y[2], " (both)"))))
dev.off()
