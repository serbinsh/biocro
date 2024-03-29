\name{c3CanA}
\alias{c3CanA}
\title{Simulates canopy assimilation for C3 canopies}
\usage{
  c3CanA(lai, doy, hr, solar, temp, rh, windspeed,
    lat = 40, nlayers = 8, kd = 0.1, heightFactor = 3,
    c3photoControl = list(), lnControl = list())
}
\arguments{
  \item{lai}{leaf area index.}

  \item{doy}{day of the year, (1--365).}

  \item{hr}{hour of the day, (0--23).}

  \item{solar}{solar radiation (\eqn{\mu}{micro} mol
  \eqn{m^{-2}}{m-2} \eqn{s^{-1}}{s-1}).}

  \item{temp}{temperature (Celsius).}

  \item{rh}{relative humidity (0--1).}

  \item{windspeed}{wind speed (m \eqn{s^{-1}}{s-1}).}

  \item{lat}{latitude.}

  \item{nlayers}{number of layers in the simulation of the
  canopy (max allowed is 50).}

  \item{kd}{Ligth extinction coefficient for diffuse
  light.}

  \item{heightFactor}{Height Factor. Divide LAI by this
  number to get the height of a crop.}

  \item{c3photoControl}{list that sets the photosynthesis
  parameters for c3 plants through the c3photoParms
  function}

  \item{lnControl}{list that sets the leaf nitrogen
  parameters.

  LeafN: Initial value of leaf nitrogen (g m-2).

  kpLN: coefficient of decrease in leaf nitrogen during the
  growing season. The equation is LN = iLeafN * exp(-kLN *
  TTc).

  lnFun: controls whether there is a decline in leaf
  nitrogen with the depth of the canopy. 'none' means no
  decline, 'linear' means a linear decline controlled by
  the following two parameters.

  lnb0: Intercept of the linear decline of leaf nitrogen in
  the depth of the canopy.

  lnb1: Slope of the linear decline of leaf nitrogen in the
  depth of the canopy. The equation is 'vmax = leafN_lay *
  lnb1 + lnb0'.}
}
\value{
  \code{\link{list}}

  returns a list with several elements

  CanopyAssim: hourly canopy assimilation (\eqn{Mg
  ha^{-1}}{Mg/ha} \eqn{hr^{-1}}{per hour})

  CanopyTrans: hourly canopy transpiration (\eqn{Mg
  ha^{-1}}{Mg/ha} \eqn{hr^{-1}}{per hour})

  CanopyCond: hourly canopy conductance (units ?)

  TranEpen: hourly canopy transpiration according to Penman
  (\eqn{Mg ha^{-1}} \eqn{hr^{-1}}{per hour})

  TranEpen: hourly canopy transpiration according to
  Priestly (\eqn{Mg ha^{-1}}{Mg/ha} \eqn{hr^{-1}}{per
  hour})

  LayMat: hourly by Layer matrix containing details of the
  calculations by layer (each layer is a row).  col1:
  Direct Irradiance col2: Diffuse Irradiance col3: Leaf
  area in the sun col4: Leaf area in the shade col5:
  Transpiration of leaf area in the sun col6: Transpiration
  of leaf area in the shade col7: Assimilation of leaf area
  in the sun col8: Assimilation of leaf area in the shade
  col9: Difference in temperature between the leaf and the
  air (i.e. TLeaf - TAir) for leaves in sun.  col10:
  Difference in temperature between the leaf and the air
  (i.e. TLeaf - TAir) for leaves in shade.  col11: Stomatal
  conductance for leaves in the sun col12: Stomatal
  conductance for leaves in the shade col13: Nitrogen
  concentration in the leaf (g m^-2) col14: Vmax value as
  depending on leaf nitrogen
}
\description{
  It represents an integration of the photosynthesis
  function \code{\link{c3photo}}, canopy
  evapo/transpiration and the multilayer canopy model
  \code{\link{sunML}}.
}
\details{
  The photosynthesis function is modeled after the version
  in WIMOVAC.  This is based on the well known Farquar
  model.
}
\note{
  %% ~~further notes~~
}
\examples{
data(doy124)
tmp <- numeric(24)

for(i in 1:24){
   lai <- doy124[i,1]
   doy <- doy124[i,3]
   hr  <- doy124[i,4]
 solar <- doy124[i,5]
  temp <- doy124[i,6]
    rh <- doy124[i,7]
    ws <- doy124[i,8]

  tmp[i] <- c3CanA(lai,doy,hr,solar,temp,rh,ws)$CanopyAssim

}

plot(c(0:23),tmp,
            type='l',lwd=2,
            xlab='Hour',
            ylab=expression(paste('Canopy assimilation (Mg  ',
            ha^-2,' ',h^-1,')')))
}
\author{
  Fernando E. Miguez
}
\references{
  Farquhar model %% ~put references to the literature/web
  site here ~
}
\seealso{
  %% ~~objects to See Also as \code{\link{help}}, ~~~
}
\keyword{models}

