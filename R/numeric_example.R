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

get_irfs <- function(A, v, N = 100, M = 12, xstart = 0) {
    k <- nrow(A)
    p <- ncol(A) / k
    if (p > 1) {
        A <- rbind(A, matrix(0, (p-1)*k, p*k))
        diag(A[(k + 1):(p*k), 1:((p-1)*k)]) <- 1
    }
    e <- eigen(A, symmetric = FALSE)
    V <- e$vectors
    Vi <- solve(V)
    
    xout <- seq(xstart, M + 1/N, by = 1/N)
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

A <- matrix(c(-0.5, 0.01, -0.2, 0.1, 0.3, 0.1, -0.1, 0.0),
            nrow = 2, byrow = TRUE)

## shock to y1
irf1 <- get_irfs(A, 1, 1, 8)
irf2 <- get_irfs(A, 1, 100, 8)
## shock to y2
irf3 <- get_irfs(A, 2, 1, 8)
irf4 <- get_irfs(A, 2, 100, 8)

makeplot <- function(irf, yvar,...) {
    plot(irf$x, irf$y[yvar,], "l", ylim = c(-.6, 1), lwd = 2,
         bty = "n", xlab = "", ylab = "", ...)
    abline(0, 0, col = rgb(0,0,0,.2))
    for (i in 0:9) {
        lines(c(i,i), c(-.6, 1), col = rgb(0,0,0,.2))
    }
}

pdf(file = "graphs/numeric.pdf", width = 6, height = 7)
par(mfcol = c(4, 2), mar = c(2,3,3,1))
makeplot(irf1, 1, main = "y_1 shock on y_1")
makeplot(irf1, 2, main = "y_1 shock on y_2")
makeplot(irf3, 1, main = "y_2 shock on y_1")
makeplot(irf3, 2, main = "y_2 shock on y_2")
makeplot(irf2, 1, main = "y_1 shock on y_1 (smoothed)")
makeplot(irf2, 2, main = "y_1 shock on y_2 (smoothed)")
makeplot(irf4, 1, main = "y_2 shock on y_1 (smoothed)")
makeplot(irf4, 2, main = "y_2 shock on y_2 (smoothed)")
dev.off()
