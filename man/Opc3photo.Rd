\name{Opc3photo}
\alias{Opc3photo}
\alias{plot.Opc3photo}
\alias{predict.Opc3photo}
\alias{print.Opc3photo}
\title{Optimize parameters of the C3 photosynthesis model.}
\usage{
  Opc3photo(data, ivcmax = 100, ijmax = 180, iRd = 1.1,
    Catm = 380, O2 = 210, ib0 = 0.08, ib1 = 9.58,
    itheta = 0.7, op.level = 1,
    op.method = c("optim", "nlminb"),
    response = c("Assim", "StomCond"), level = 0.95,
    hessian = TRUE, curve.kind = c("Ci", "Q"),
    op.ci = FALSE, ...)
}
\arguments{
  \item{data}{should be a \code{data.frame} or
  \code{matrix} with x columns

  col 1: measured assimilation (CO2 uptake) col 2:
  Incomming PAR (photosynthetic active radiation) col 3:
  Leaf temperature col 4: Relative humidity col 5:
  Intercellular CO2 (for A/Ci curves) col 6: Reference CO2
  level}

  \item{ivcmax}{Initial value for \code{vcmax}.}

  \item{ijmax}{Initial value for \code{jmax}.}

  \item{iRd}{Initial value for \code{Rd}.}

  \item{Catm}{Reference CO2.}

  \item{O2}{Reference level of O2.}

  \item{ib0}{Initial value for the intercept to the
  Ball-Berry model.}

  \item{ib1}{Initial value for the slope to the Ball-Berry
  model.}

  \item{itheta}{Initial value for \code{theta}.}

  \item{op.level}{Level 1 will optimize \code{Vcmax} and
  \code{Jmax} and level 2 will optimize \code{Vcmax},
  \code{Jmax} and \code{Rd}.}

  \item{op.method}{optimization method. At the moment only
  optim is implemented.}

  \item{response}{\code{'Assim'} for assimilation and
  \code{'StomCond'} for stomatal conductance.}

  \item{level}{Confidence interval level.}

  \item{hessian}{Whether the hessian should be computed}

  \item{curve.kind}{Whether an A/Ci curve is being
  optimized or an A/Q curve.}

  \item{op.ci}{whether to optimize intercellular CO2.}

  \item{\dots}{Additioanl arguments to be passed to
  \code{\link{optim}}.}
}
\value{
  An object of class \code{Opc3photo}.

  The following components can be extracted:
}
\description{
  Applies the \code{optim} function to C3 photosynthesis.
}
\note{
  ~~further notes~~ Additional notes about the assumptions.
}
\examples{
## Load fabricated data
data(simA100)
## Look at it
head(simA100)

op <- Opc3photo(simA100[,1:5],Catm=simA100[,9], op.level = 2)

## If faced with a difficult problem
## This can give starting values
op100 <- Opc3photo(simA100[,1:5],Catm=simA100[,9],
                   op.level = 2, method='SANN',
                   hessian=FALSE)

op100 <- Opc3photo(simA100[,1:5],Catm = simA100[,9],
                   op.level = 2,
                   ivcmax = op100$bestVmax,
                   ijmax = op100$bestJmax,
                   iRd = op100$bestRd)
op100
}
\author{
  Fernando E. Miguez
}
\seealso{
  See Also \code{\link{mOpc3photo}}
}
\keyword{optimize}

