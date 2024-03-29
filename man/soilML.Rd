\name{soilML}
\alias{rootDist}
\alias{soilML}
\title{soil multi-layered}
\usage{
  soilML(precipt, CanopyT, cws, soilDepth, FieldC, WiltP,
    phi1 = 0.01, phi2 = 10,
    wsFun = c("linear", "logistic", "exp", "none"), rootDB,
    soilLayers = 3, LAI, k, AirTemp, IRad, winds, RelH,
    soilType = 10, hydrDist = 0, rfl = 0.3)
}
\arguments{
  \item{precipt}{Precipitation (mm).}

  \item{CanopyT}{Canopy transpiration.}

  \item{cws}{Current water status. Vector of length equal
  to soilLayers.}

  \item{soilDepth}{Rooting depth.}

  \item{FieldC}{Field capacity.}

  \item{WiltP}{Wilting point.}

  \item{phi1}{See \code{\link{wtrstr}}.}

  \item{phi2}{See \code{\link{wtrstr}}.}

  \item{wsFun}{See \code{\link{wtrstr}}.}

  \item{rootDB}{Root biomass (Mg/ha).}

  \item{soilLayers}{Integer used to specify the number of
  soil layers.}

  \item{LAI}{Leaf area index.}

  \item{k}{Light extinction coefficient.}

  \item{AirTemp}{Air temperature (Celsius).}

  \item{IRad}{Direct irradiance (\eqn{\mu} \eqn{m^-2}
  \eqn{s^-1}).}

  \item{winds}{Wind speed (m/s).}

  \item{RelH}{Relative humidity (0-1).}

  \item{soilType}{See \code{\link{showSoilType}}.}

  \item{hydrDist}{Zero or otherwise positive integer. Zero
  does not calculate hydraulic distribution, otherwise
  does.}

  \item{rfl}{Root factor lambda. A Poisson distribution is
  used to simulate the distribution of roots in the soil
  profile and this parameter can be used to change the
  lambda parameter of the Poisson.}
}
\value{
  matrix with 8 (if hydrDist=0) or 12 (if hydrDist > 0).
}
\description{
  Simulates soil water content for a layered soil.
}
\examples{
layers <- 5
ans <- soilML(precipt=2, CanopyT=2, cws = rep(0.3,layers),
soilDepth=1.5, FieldC=0.33, WiltP=0.13, rootDB=2, soilLayers=layers,
LAI=3, k=0.68, AirTemp=25,IRad=500, winds=2, RelH=0.8, soilType=6,
hydrDist=1)
ans
}
\author{
  Fernando E. Miguez
}
\seealso{
  See Also \code{\link{wtrstr}}.
}
\keyword{models}

