## I have modified original weach function written by Fernando to accurately
## reflect day of year in the weach outout
##' Simulates the hourly conditions from daily
##'
##' Manipulates weather data in the format obtained from WARM (see link below)
##' and returns the format and units needed for most functions in this package.
##' This function should be used for one year at a time.  It returns hourly (or
##' sub-daily) weather information.
##'
##'
##' This function was originally used to transform daily data to hourly data.
##' Some flexibility has been added so that other units can be used. The input
##' data used originally looked as follows. \enumerate{
##'
##' \itemcol 1year \itemcol 2day of the year (1--365). Does not consider leap
##' years. \itemcol 3total daily solar radiation (MJ/m^2). \itemcol 4maximum
##' temperature (Fahrenheit). \itemcol 5minimum temperature (Fahrenheit).
##' \itemcol 6average temperature (Fahrenheit). \itemcol 7maximum relative
##' humidity (\%). \itemcol 8minimum relative humidity (\%). \itemcol 9average
##' relative humidity (\%). \itemcol 10average wind speed (miles per hour).
##' \itemcol 11precipitation (inches). }
##'
##' All the units above are the defaults but they can be changed as part of the
##' arguments.
##'
##' @param X a matrix (or data frame) containing weather information.  The
##' input format is strict but it is meant to be used with the data usually
##' obtained from weather stations in Illinois. The data frame should have 11
##' columns (see details).
##' @param lati latitude at the specific location
##' @param ts timestep for the simulation of sub-daily data from daily. For
##' example a value of 3 would return data every 3 hours. Only divisors of 24
##' work (i.e. 1,2,3,4, etc.).
##' @param temp.units Option to specify the units in which the temperature is
##' entered. Default is Farenheit.
##' @param rh.units Option to specify the units in which the relative humidity
##' is entered. Default is percent.
##' @param ws.units Option to specify the units in which the wind speed is
##' entered. Default is miles per hour.
##' @param pp.units Option to specify the units in which the precipitation is
##' entered. Default is inches.
##' @param list() additional arguments to be passed to \code{\link{lightME}}
##' @export
##' @return a \code{\link{matrix}} returning hourly (or sub-daily) weather
##' data. Dimensions 8760 (if hourly) by 8.
##' @returnItem year Year.
##' @returnItem doy Day of the year.
##' @returnItem hour Hour of the day (0--23, depending on the timestep).
##' @returnItem SolarR Direct solar radiation (\eqn{\mu mol \; m^{-2} \;
##' }{micro mol per meter squared per second}\eqn{ s^{-1}}{micro mol per meter
##' squared per second}).
##' @returnItem Temp Air temperature (Celsius).
##' @returnItem RH Relative humidity (0--1).
##' @returnItem WS Average wind speed (\eqn{m \;s^{-1}}{meter per second}).
##' @returnItem precip Precipitation (\eqn{mm}{mm})
##' @keywords datagen
##' @examples
##'
##' data(cmi0506)
##' tmp1 <- cmi0506[cmi0506$year == 2005,]
##' wet05 <- weach(tmp1,40)
##'
##' # Return data every 3 hours
##' wet05.3 <- weach(tmp1,40,ts=3)
##'
weach <- function(X, lati, ts = 1, temp.units = c("Farenheit", "Celsius"), rh.units = c("percent", 
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
        res <- lightME(DOY = DOYm[i], t.d = tseq, lat = lati, ...)
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
    DOY <- DOYm
    doy <- rep(DOY, each = tint)
    year <- rep(year, each = tint)
    ans <- cbind(year, doy, hour, SolarR, Temp, RH, WS, precip)
    ans
} 
