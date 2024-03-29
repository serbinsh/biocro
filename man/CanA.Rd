\name{CanA}
\alias{CanA}
\alias{lnParms}
\title{Simulates canopy assimilation}
\usage{
  CanA(lai, doy, hr, solar, temp, rh, windspeed, lat = 40,
    nlayers = 8, kd = 0.1, StomataWS = 1, heightFactor = 3,
    photoControl = list(), lnControl = list(),
    units = c("kg/m2/hr", "Mg/ha/hr"))
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

  \item{StomataWS}{coefficient controlling the effect of
  water stress on stomatal conductance and assimilation.}

  \item{heightFactor}{Height Factor. Divide LAI by this
  number to get the height of a crop.}

  \item{photoControl}{list that sets the photosynthesis
  parameters. See \code{\link{BioGro}}.}

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

  \item{units}{Whether to return units in kg/m2/hr or
  Mg/ha/hr. This is typically run at hourly intervals, that
  is why the hr is kept, but it could be used with data at
  finer timesteps and then convert the results.}
}
\value{
  \code{\link{list}}

  returns a list with several elements

  CanopyAssim: hourly canopy assimilation (\eqn{kg
  m^{-2}}{kg/m2} \eqn{hr^{-1}}{per hour}) or canopy
  assimilation (\eqn{Mg ha^{-1}}{Mg/ha} \eqn{hr^{-1}}{per
  hour})

  CanopyTrans: hourly canopy transpiration (\eqn{kg
  m^{-2}}{kg/m2} \eqn{hr^{-1}}{per hour}) or canopy
  transpiration (\eqn{Mg ha^{-1}}{Mg/ha} \eqn{hr^{-1}}{per
  hour})

  CanopyCond: hourly canopy conductance (units ?)

  TranEpen: hourly canopy transpiration according to Penman
  (\eqn{kg m^{-2}} \eqn{hr^{-1}}{per hour}) or canopy
  transpiration according to Penman (\eqn{Mg ha^{-1}}
  \eqn{hr^{-1}}{per hour})

  TranEpen: hourly canopy transpiration according to
  Priestly (\eqn{kg m^{-2}}{kg/m2} \eqn{hr^{-1}}{per hour})
  canopy transpiration according to Priestly (\eqn{Mg
  ha^{-1}}{Mg/ha} \eqn{hr^{-1}}{per hour})

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
  function \code{\link{c4photo}}, canopy
  evapo/transpiration and the multilayer canopy model
  \code{\link{sunML}}.
}
\examples{
\dontrun{
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

  tmp[i] <- CanA(lai,doy,hr,solar,temp,rh,ws)$CanopyAssim

}

plot(c(0:23),tmp,
            type='l',lwd=2,
            xlab='Hour',
            ylab=expression(paste('Canopy assimilation (kg  ',
            m^-2,' ',h^-1,')')))

}
}
\keyword{models}

