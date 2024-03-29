\name{SoilEvapo}
\alias{SoilEvapo}
\title{Soil Evaporation}
\usage{
  SoilEvapo(LAI, k, AirTemp, IRad, awc, FieldC, WiltP,
    winds, RelH)
}
\arguments{
  \item{LAI}{Leaf Area Index.}

  \item{k}{~~Describe \code{k} here~~}

  \item{AirTemp}{Air temperature.}

  \item{IRad}{Incident radiation.}

  \item{awc}{Available water content.}

  \item{FieldC}{Field capacity.}

  \item{WiltP}{Wilting point.}

  \item{winds}{Wind speed.}

  \item{RelH}{Relative humidty.}
}
\value{
  Returns a single value of soil Evaporation in Mg H20 per
  hectare.
}
\description{
  Calculates soil evaporation
}
\details{
  The style of the code is \code{C} like because this is a
  prototype for the underlying \code{C} (like so many other
  functions in this package). I leave it here for future
  development.
}
\examples{
SoilEvapo(LAI=3,k=0.68,AirTemp=20,IRad=1000,awc=0.3,FieldC=0.4,WiltP=0.2,winds=3,RelH=0.8)
}
\author{
  Fernando Miguez
}
\seealso{
  Source code :)
}
\keyword{models}

