\name{MCMCBioGro}
\alias{MCMCBioGro}
\alias{print.MCMCBioGro}
\title{Simulated Annealing and Markov chain Monte Carlo for estimating parameters
for Biomass Growth}
\usage{
  MCMCBioGro(niter = 10, niter2 = 10, phen = 6,
    iCoef = NULL, saTemp = 5, coolSamp = 20, scale = 0.5,
    WetDat, data, day1 = NULL, dayn = NULL, timestep = 1,
    lat = 40, iRhizome = 7, irtl = 1e-04,
    canopyControl = list(), seneControl = list(),
    photoControl = list(), phenoControl = list(),
    soilControl = list(), nitroControl = list(),
    centuryControl = list(), sd = c(0.02, 1e-06))
}
\arguments{
  \item{niter}{number of iterations for the simulated
  annealing portion of the optimization.}

  \item{niter2}{number of iterations for the Markov chain
  Monte Carlo portion of the optimization.}

  \item{phen}{Phenological stage being optimized.}

  \item{iCoef}{initial coefficients for dry biomass
  partitioning.}

  \item{saTemp}{simulated annealing temperature.}

  \item{coolSamp}{number of cooling samples.}

  \item{scale}{scale parameter to control the standard
  deviations.}

  \item{WetDat}{weather data.}

  \item{data}{observed data.}

  \item{day1}{first day of the growing season.}

  \item{dayn}{last day of the growing season.}

  \item{timestep}{Timestep see \code{\link{BioGro}}.}

  \item{lat}{latitude.}

  \item{iRhizome}{initial rhizome biomass.}

  \item{irtl}{See \code{\link{BioGro}}.}

  \item{canopyControl}{See \code{\link{canopyParms}}.}

  \item{seneControl}{See \code{\link{seneParms}}.}

  \item{photoControl}{See \code{\link{photoParms}}.}

  \item{phenoControl}{See \code{\link{phenoParms}}.}

  \item{soilControl}{See \code{\link{soilParms}}.}

  \item{nitroControl}{See \code{\link{nitroParms}}.}

  \item{centuryControl}{See \code{\link{centuryParms}}.}

  \item{sd}{standard deviations for the parameters to be
  optimized. The first (0.02) is for the positive dry
  biomass partitioning coefficients. The second (1e-6) is
  for the negative dry biomass partitioning coefficients.}
}
\value{
  An object of class MCMCBioGro consisting of a list with
  23 components.  The easiest way of accessing the
  information is with the print and plot methods.
}
\description{
  This function atempts to implement the simulated
  annealing method for estimating parameters of a generic
  C4 crop growth.
}
\details{
  This function implements a hybrid algorithm where the
  first portion is simulated annealing and the second
  portion is a Markov chain Monte Carlo. The user controls
  the number of iterations in each portion of the chain
  with niter and niter2.
}
\note{
  The automatic method for guessing the last day of the
  growing season differs slightly from that in
  \code{BioGro}. To prevent error due to a shorter
  simulated growing season than the observed one the method
  in \code{MCMCBioGro} adds one day to the last day of the
  growing season. Although the upper limit is fixed at 330.
}
\examples{
\dontrun{

data(weather05)

## Some coefficients
pheno.ll <- phenoParms(kLeaf1=0.48,kStem1=0.47,kRoot1=0.05,kRhizome1=-1e-4,
                       kLeaf2=0.14,kStem2=0.65,kRoot2=0.21, kRhizome2=-1e-4,
                       kLeaf3=0.01, kStem3=0.56, kRoot3=0.13, kRhizome3=0.3,
                       kLeaf4=0.01, kStem4=0.56, kRoot4=0.13, kRhizome4=0.3,
                       kLeaf5=0.01, kStem5=0.56, kRoot5=0.13, kRhizome5=0.3,
                       kLeaf6=0.01, kStem6=0.56, kRoot6=0.13, kRhizome6=0.3)

system.time(ans <- BioGro(weather05, phenoControl = pheno.ll))

ans.dat <- as.data.frame(unclass(ans)[1:11])
sel.rows <- seq(1,nrow(ans.dat),400)
simDat <- ans.dat[sel.rows,c('ThermalT','Stem','Leaf','Root','Rhizome','Grain','LAI')]
plot(ans,simDat)

## Residual sum of squares before the optimization

ans0 <- BioGro(weather05)
RssBioGro(simDat,ans0)


op1.mc <- MCMCBioGro(phen=1, niter=200,niter2=200,
                     WetDat=weather05,
                     data=simDat)


plot(op1.mc)

plot(op1.mc, plot.kind='trace', subset = nams \%in\%
\\t\\t\\t\\tc('kLeaf_1','kStem_1','kRoot_1'))

}
}
\author{
  Fernando E. Miguez
}
\seealso{
  See Also as \code{\link{BioGro}}, \code{\link{OpBioGro}}
  and \code{\link{constrOpBioGro}}.
}
\keyword{optimize}

