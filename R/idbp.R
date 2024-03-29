## BioCro/R/idbp.R by Fernando Ezequiel Miguez Copyright (C) 2009
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the Free
## Software Foundation; either version 2 or 3 of the License (at your option).
## 
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
## more details.
## 
## A copy of the GNU General Public License is available at
## http://www.r-project.org/Licenses/
##' Initial Dry Biomass Partitioning Coefficients
##'
##' Atempts to guess good initial vales for dry biomass coefficients that can
##' be passed to \code{BioGro}, \code{OpBioGro}, \code{constrOpBioGro}, or
##' \code{MCMCBioGro}.  It is very fragile.
##'
##' This function will not accept missing values. It can be quite fragile and
##' it is rather inflexible in what it expects in terms of data.
##'
##' @param data Should have at least five columns with: ThermalT, Stem, Leaf,
##' Root, Rhizome and Grain.
##' @param phenoControl list that supplies mainly in this case the thrmal time
##' periods that delimit the phenological stages,
##' @export
##' @return It returns a vector of length 25 suitable for \code{BioGro},
##' \code{OpBioGro}, \code{constrOpBioGro}, or \code{MCMCBioGro}.
##' @note It is highly recommended that the results of this function are tested
##' with \code{\link{valid_dbp}}.
##' @author Fernando E. Miguez
##' @seealso \code{\link{valid_dbp}}
##' @keywords utilities
##' @examples
##'
##' ## See ?OpBioGro
##'
idbp <- function(data, phenoControl = list()) {
    ## should have t
    if (any(is.na(data))) 
        stop("missing data are not allowed")
    dnames <- c("ThermalT", "Stem", "Leaf", "Root", "Rhizome", "Grain", "LAI")
    if (any(is.na(unlist(lapply(names(data), pmatch, dnames))))) 
        warning("data names and/or order might be wrong")
    phenoP <- phenoParms()
    phenoP[names(phenoControl)] <- phenoControl
    TPcoefs <- as.vector(unlist(phenoP)[1:6])
    
    
    n1dat <- numeric(6)
    for (i in 1:6) n1dat[i] <- nrow(data[data[, 1] <= TPcoefs[i], ])
    ## coefficients for the first stage
    if (n1dat[1] > 1) {
        dat1 <- data[c(1, n1dat[1]), ]
        delta.dat1 <- dat1[2, ] - dat1[1, ]
        c1s.r <- (delta.dat1[5]/dat1[1, 5])/delta.dat1[1]
    } else {
        if (n1dat[1] == 1) {
            warning("only one row for phen stage 1")
        } else {
            warning("zero rows for phen stage 1")
        }
        dat1 <- data[1, ]
        delta.dat1 <- dat1
        c1s.r <- -1e-04
    }
    rsum.dat1 <- sum(delta.dat1[2:4])
    c1s <- c(delta.dat1[2:4]/rsum.dat1, c1s.r)
    c1s <- as.vector(unlist(c(c1s[2:1], c1s[3:4])))
    ## coefficients for the second stage
    dat2 <- data[n1dat[1:2], ]
    delta.dat2 <- dat2[2, ] - dat2[1, ]
    rsum.dat2 <- sum(delta.dat2[2:4])
    c2s.r <- (delta.dat2[5]/dat2[1, 5])/delta.dat2[1]
    c2s <- c(delta.dat2[2:4]/rsum.dat2, c2s.r)
    c2s <- as.vector(unlist(c(c2s[2:1], c2s[3:4])))
    ## coefficients for the third stage
    dat3 <- data[n1dat[2:3], ]  ## print(dat3)
    delta.dat3 <- dat3[2, ] - dat3[1, ]  ## print(delta.dat3)
    delta.dat3[delta.dat3 < 0] <- 1e-06
    rsum.dat3 <- sum(delta.dat3[2:5])
    c3s <- c(delta.dat3[2:5]/rsum.dat3)
    c3s <- as.vector(unlist(c(c3s[2:1], c3s[3:4])))
    ## coefficients for the fourth stage
    dat4 <- data[n1dat[3:4], ]
    delta.dat4 <- dat4[2, ] - dat4[1, ]  ##print(delta.dat4)
    delta.dat4[delta.dat4 < 0] <- 1e-06
    rsum.dat4 <- sum(delta.dat4[2:5])
    c4s <- c(delta.dat4[2:5]/rsum.dat4)
    c4s <- as.vector(unlist(c(c4s[2:1], c4s[3:4])))
    ## coefficients for the fifth stage
    dat5 <- data[n1dat[4:5], ]  ##print(dat5) print(n1dat[4:5])
    delta.dat5 <- dat5[2, ] - dat5[1, ]  ##print(delta.dat5)
    delta.dat5[delta.dat5 < 0] <- 1e-06
    rsum.dat5 <- sum(delta.dat5[2:5])
    c5s <- c(delta.dat5[2:5]/rsum.dat5)
    c5s <- as.vector(unlist(c(c5s[2:1], c5s[3:4])))
    ## coefficients for the sixth stage
    dat6 <- data[n1dat[5:6], ]
    delta.dat6 <- dat6[2, ] - dat6[1, ]
    delta.dat6[delta.dat6 < 0] <- 1e-06
    rsum.dat6 <- sum(delta.dat6[2:6])
    c6s <- c(delta.dat6[2:6]/rsum.dat6)
    c6s <- as.vector(unlist(c(c6s[2:1], c6s[3:5])))
    cfs <- as.vector(unlist(c(c1s, c2s, c3s, c4s, c5s, c6s)))
    cfs
} 
