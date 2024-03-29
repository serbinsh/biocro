\name{sunML}
\alias{sunML}
\title{Sunlit shaded multi-layer model}
\usage{
  sunML(I.dir, I.diff, LAI = 8, nlayers = 8, kd = 0.1,
    chi.l = 1, cos.theta = 0.5)
}
\arguments{
  \item{I.dir}{direct light (quantum flux), (\eqn{\mu mol
  \; m^{-2} \; s^{-1}}{micro mol /m2/s}).}

  \item{I.diff}{indirect light (diffuse), (\eqn{\mu mol \;
  m^{-2} \; s^{-1}}{micro mol /m2/s}).}

  \item{LAI}{leaf area index, default 8.}

  \item{nlayers}{number of layers in which the canopy is
  partitioned, default 8.}

  \item{kd}{extinction coefficient for diffuse light.}

  \item{chi.l}{The ratio of horizontal:vertical projected
  area of leaves in the canopy segment.}

  \item{cos.theta}{cosine of \eqn{\theta}{theta}, solar
  zenith angle.}
}
\value{
  a \code{\link{list}} structure with components

  Vectors size equal to the number of layers.
}
\description{
  Simulates the light microenvironment in the canopy based
  on the sunlit-shade model and the multiple layers.
}
\examples{
res2 <- sunML(1500,200,3,10)

xyplot(Fsun + Fshade ~ c(1:10), data=res2,
       ylab='LAI',
       xlab='layer',
       type='l',lwd=2,col=c('blue','green'),
       lty=c(1,2),
       key=list(text=list(c('Direct','Diffuse')),lty=c(1,2),
                cex=1.2,lwd=2,lines=TRUE,x=0.7,y=0.5,
                col=c('blue','green')))
}
\keyword{models}

