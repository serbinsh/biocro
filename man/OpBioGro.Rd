\name{OpBioGro}
\alias{constrOpBioGro}
\alias{OpBioGro}
\alias{summary.OpBioGro}
\title{Optimization of dry biomass partitioning coefficients.}
\usage{
  OpBioGro(phen = 1, iCoef = NULL, WetDat, data,
    day1 = NULL, dayn = NULL, timestep = 1, lat = 40,
    iRhizome = 7, irtl = 1e-04, canopyControl = list(),
    seneControl = list(), photoControl = list(),
    phenoControl = list(), soilControl = list(),
    nitroControl = list(), centuryControl = list(),
    op.method = c("optim", "nlminb"), verbose = FALSE, ...)
}
\arguments{
  \item{phen}{integer taking values 1 through 6 which
  indicate the phenological stage being optimized. If all
  of the phenological stages need to be optimized then use
  zero (0).}

  \item{iCoef}{initial vector of size 24 for the dry
  biomass partitioning coefficients.}

  \item{WetDat}{Weather data.}

  \item{data}{observed data.}

  \item{day1}{first day of the growing season.}

  \item{dayn}{last day of the growing season.}

  \item{timestep}{see \code{\link{BioGro}}}

  \item{lat}{see \code{\link{BioGro}}}

  \item{iRhizome}{see \code{\link{BioGro}}}

  \item{irtl}{see \code{\link{BioGro}}}

  \item{canopyControl}{see \code{\link{BioGro}}}

  \item{seneControl}{see \code{\link{BioGro}}}

  \item{photoControl}{see \code{\link{BioGro}}}

  \item{phenoControl}{see \code{\link{BioGro}}}

  \item{soilControl}{see \code{\link{BioGro}}}

  \item{nitroControl}{see \code{\link{BioGro}}}

  \item{centuryControl}{see \code{\link{BioGro}}}

  \item{op.method}{Optimization method. Whether to use
  optim or nlminb}

  \item{verbose}{Displays additional information,
  originally used for debugging.}

  \item{\dots}{additional arguments passed to
  \code{\link{optim}} or \code{\link{constrOptim}}.}
}
\value{
  \code{\link{list}} of class \code{OpBioGro} with
  components
}
\description{
  Optimizes dry biomass partitioning coefficients using
  constrained optimization (see below).
}
\details{
  The optimization is done over the \code{\link{BioGro}}
  function. The \code{OpBioGro} function is a wrapper for
  \code{optim} and the \code{constrOpBioGro} is a wrapper
  for \code{constrOptim}.
}
\section{Warning}{
  This function has not had enough testing.
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
sel.rows <- seq(1,nrow(ans.dat),length.out=8)
simDat <- ans.dat[sel.rows,c('ThermalT','Stem','Leaf','Root','Rhizome','Grain','LAI')]
plot(ans,simDat)

## Residual sum of squares before the optimization

ans0 <- BioGro(weather05)
RssBioGro(simDat,ans0)

## This will optimize only the first phenological stage
idb <- valid_dbp(idbp(simDat))
op1 <- OpBioGro(phen=0, WetDat=weather05, data = simDat, iCoef=idb)
## or
cop1 <- constrOpBioGro(phen=0, WetDat=weather05, data = simDat)

}
}
\references{
  no references yet.
}
\seealso{
  \code{\link{BioGro}} \code{\link{constrOptim}}
  \code{\link{optim}} \code{\link{c4photo}}
}
\keyword{optimize}

