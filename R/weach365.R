## BioCro/R/weach.R by Fernando Ezequiel Miguez Copyright (C) 2007-2009
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
weach365 <- function(X, lati, ts = 1, temp.units = c("Farenheit", "Celsius"), rh.units = c("percent", 
    "fraction"), ws.units = c("mph", "mps"), pp.units = c("in", "mm"), ...) {
    
    if (missing(lati)) 
        stop("latitude is missing")
    
    if ((ts < 1) || (24%%ts != 0)) 
        stop("ts should be a divisor of 24 (e.g. 1,2,3,4,6,etc.)")
    
    if (dim(X)[2] != 11) 
        stop("X should have 11 columns")
    
    MPHTOMPERSEC <- 0.447222222222222
    
    temp.units <- match.arg(temp.units)
    rh.units <- match.arg(rh.units)
    ws.units <- match.arg(ws.units)
    pp.units <- match.arg(pp.units)
    
    year <- X[, 1]
    DOYm <- X[, 2]
    solar <- X[, 3]
    maxTemp <- X[, 4]
    minTemp <- X[, 5]
    avgTemp <- X[, 6]
    maxRH <- X[, 7]
    minRH <- X[, 8]
    avgRH <- X[, 9]
    WindSpeed <- X[, 10]
    precip <- X[, 11]
    
    tint <- 24/ts
    tseq <- seq(0, 23, ts)
    
    ## Solar radiation
    solarR <- (0.12 * solar) * 2.07 * 10^6/3600
    solarR <- rep(solarR, each = tint)
    
    ltseq <- length(tseq)
    resC2 <- numeric(ltseq * 365)
    for (i in 1:365) {
        res <- lightME(DOY = i, t.d = tseq, lat = lati, ...)
        Itot <- res$I.dir + res$I.diff
        indx <- 1:ltseq + (i - 1) * ltseq
        resC2[indx] <- (Itot - min(Itot))/max(Itot)
    }
    
    SolarR <- solarR * resC2
    
    ## Temperature
    if (temp.units == "Farenheit") {
        minTemp <- (minTemp - 32) * (5/9)
        minTemp <- rep(minTemp, each = tint)
        maxTemp <- (maxTemp - 32) * (5/9)
        maxTemp <- rep(maxTemp, each = tint)
        rangeTemp <- maxTemp - minTemp
        # avgTemp <- rep((avgTemp - 32)*(5/9),each=tint)
    } else {
        minTemp <- rep(minTemp, each = tint)
        maxTemp <- rep(maxTemp, each = tint)
        rangeTemp <- maxTemp - minTemp
    }
    
    xx <- rep(tseq, 365)
    temp1 <- sin(2 * pi * (xx - 10)/tint)
    temp1 <- (temp1 + 1)/2
    Temp <- minTemp + temp1 * rangeTemp
    
    ## Relative humidity avgRH <- rep(avgRH,each=tint)
    minRH <- rep(minRH, each = tint)
    maxRH <- rep(maxRH, each = tint)
    
    temp2 <- cos(2 * pi * (xx - 10)/tint)
    temp2 <- (temp2 + 1)/2
    if (rh.units == "percent") {
        RH <- (minRH + temp2 * (maxRH - minRH))/100
    } else {
        RH <- (minRH + temp2 * (maxRH - minRH))
    }
    
    ## Wind Speed
    if (ws.units == "mph") {
        WS <- rep(WindSpeed, each = tint) * MPHTOMPERSEC
    } else {
        WS <- rep(WindSpeed, each = tint)
    }
    
    ## Precipitation
    if (pp.units == "in") {
        precip <- rep(I((precip * 2.54 * 10)/tint), each = tint)
    } else {
        precip <- rep(I(precip/tint), each = tint)
    }
    
    hour <- rep(tseq, 365)
    DOY <- 1:365
    doy <- rep(DOY, each = tint)
    
    
    ans <- cbind(year, doy, hour, SolarR, Temp, RH, WS, precip)
    ans
} 
