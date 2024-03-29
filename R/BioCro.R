## BioCro/R/BioCro.R by Fernando Ezequiel Miguez Copyright (C) 2007-2010
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
##' Biomass crops growth simulation
##'
##' Simulates dry biomass growth during an entire growing season.  It
##' represents an integration of the photosynthesis function
##' \code{\link{c4photo}}, canopy evapo/transpiration \code{\link{CanA}}, the
##' multilayer canopy model \code{\link{sunML}} and a dry biomass partitioning
##' calendar and senescence. It also considers, carbon and nitrogen cycles and
##' water and nitrogen limitations.
##'
##'
##' @aliases BioGro print.BioGro soilParms nitroParms phenoParms photoParms
##' canopyParms seneParms centuryParms showSoilType SoilType
##' @param WetDat weather data as produced by the \code{\link{weach}} function.
##' @param day1 first day of the growing season, (1--365).
##' @param dayn last day of the growing season, (1--365, but larger than
##' \code{day1}). See details.
##' @param timestep Simulation timestep, the default of 1 requires houlry
##' weather data. A value of 3 would require weather data every 3 hours.  This
##' number should be a divisor of 24.
##' @param lat latitude, default 40.
##' @param iRhizome initial dry biomass of the Rhizome (Mg \eqn{ha^{-1}}).
##' @param irtl Initial rhizome proportion that becomes leaf. This should not
##' typically be changed, but it can be used to indirectly control the effect
##' of planting density.
##' @param canopyControl List that controls aspects of the canopy simulation.
##' It should be supplied through the \code{canopyParms} function.
##'
##' \code{Sp} (specific leaf area) here the units are ha \eqn{Mg^{-1}}.  If you
##' have data in \eqn{m^2} of leaf per kg of dry matter (e.g. 15) then divide
##' by 10 before inputting this coefficient.
##'
##' \code{nlayers} (number of layers of the canopy) Maximum 50. To increase the
##' number of layers (more than 50) the \code{C} source code needs to be
##' changed slightly.
##'
##' \code{kd} (extinction coefficient for diffuse light) between 0 and 1.
##'
##' \code{mResp} (maintenance respiration) a vector of length 2 with the first
##' component for leaf and stem and the second component for rhizome and root.
##' @param seneControl List that controls aspects of senescence simulation. It
##' should be supplied through the \code{seneParms} function.
##'
##' \code{senLeaf} Thermal time at which leaf senescence will start.
##'
##' \code{senStem} Thermal time at which stem senescence will start.
##'
##' \code{senRoot} Thermal time at which root senescence will start.
##'
##' \code{senRhizome} Thermal time at which rhizome senescence will start.
##' @param photoControl List that controls aspects of photosynthesis
##' simulation. It should be supplied through the \code{photoParms} function.
##'
##' \code{vmax} Vmax passed to the \code{\link{c4photo}} function.
##'
##' \code{alpha} alpha parameter passed to the \code{\link{c4photo}} function.
##'
##' \code{kparm} kparm parameter passed to the \code{\link{c4photo}} function.
##'
##' \code{theta} theta parameter passed to the \code{\link{c4photo}} function.
##'
##' \code{beta} beta parameter passed to the \code{\link{c4photo}} function.
##'
##' \code{Rd} Rd parameter passed to the \code{\link{c4photo}} function.
##'
##' \code{Catm} Catm parameter passed to the \code{\link{c4photo}} function.
##'
##' \code{b0} b0 parameter passed to the \code{\link{c4photo}} function.
##'
##' \code{b1} b1 parameter passed to the \code{\link{c4photo}} function.
##' @param phenoControl List that controls aspects of the crop phenology. It
##' should be supplied through the \code{phenoParms} function.
##'
##' \code{tp1-tp6} thermal times which determine the time elapsed between
##' phenological stages. Between 0 and tp1 is the juvenile stage. etc.
##'
##' \code{kLeaf1-6} proportion of the carbon that is allocated to leaf for
##' phenological stages 1 through 6.
##'
##' \code{kStem1-6} proportion of the carbon that is allocated to stem for
##' phenological stages 1 through 6.
##'
##' \code{kRoot1-6} proportion of the carbon that is allocated to root for
##' phenological stages 1 through 6.
##'
##' \code{kRhizome1-6} proportion of the carbon that is allocated to rhizome
##' for phenological stages 1 through 6.
##'
##' \code{kGrain1-6} proportion of the carbon that is allocated to grain for
##' phenological stages 1 through 6. At the moment only the last stage (i.e. 6
##' or post-flowering) is allowed to be larger than zero. An error will be
##' returned if kGrain1-5 are different from zero.
##' @param soilControl List that controls aspects of the soil environment. It
##' should be supplied through the \code{soilParms} function.
##'
##' \code{FieldC} Field capacity. This can be used to override the defaults
##' possible from the soil types (see \code{\link{showSoilType}}).
##'
##' \code{WiltP} Wilting point.  This can be used to override the defaults
##' possible from the soil types (see \code{\link{showSoilType}}).
##'
##' \code{phi1} Parameter which controls the spread of the logistic function.
##' See \code{\link{wtrstr}} for more details.
##'
##' \code{phi2} Parameter which controls the reduction of the leaf area growth
##' due to water stress. See \code{\link{wtrstr}} for more details.
##'
##' \code{soilDepth} Maximum depth of the soil that the roots have access to
##' (i.e. rooting depth).
##'
##' \code{iWatCont} Initial water content of the soil the first day of the
##' growing season. It can be a single value or a vector for the number of
##' layers specified.
##'
##' \code{soilType} Soil type, default is 6 (a more typical soil would be 3).
##' To see details use the function \code{\link{showSoilType}}.
##'
##' \code{soilLayer} Integer between 1 and 50. The default is 5. If only one
##' soil layer is used the behavior can be quite different.
##'
##' \code{soilDepths} Intervals for the soil layers.
##'
##' \code{wsFun} one of 'logistic','linear','exp' or 'none'. Controls the
##' method for the relationship between soil water content and water stress
##' factor.
##'
##' \code{scsf} stomatal conductance sensitivity factor (default = 1). This is
##' an empirical coefficient that needs to be adjusted for different species.
##'
##' \code{rfl} Root factor lambda. A Poisson distribution is used to simulate
##' the distribution of roots in the soil profile and this parameter can be
##' used to change the lambda parameter of the Poisson.
##'
##' \code{rsec} Radiation soil evaporation coefficient. Empirical coefficient
##' used in the incidence of direct radiation on soil evaporation.
##'
##' \code{rsdf} Root soil depth factor. Empirical coefficient used in
##' calculating the depth of roots as a function of root biomass.
##' @param nitroControl List that controls aspects of the nitrogen environment.
##' It should be supplied through the \code{nitrolParms} function.
##'
##' \code{iLeafN} initial value of leaf nitrogen (g m-2).
##'
##' \code{kLN} coefficient of decrease in leaf nitrogen during the growing
##' season. The equation is LN = iLeafN * (Stem + Leaf)^-kLN .
##'
##' \code{Vmax.b1} slope which determines the effect of leaf nitrogen on Vmax.
##'
##' \code{alpha.b1} slope which controls the effect of leaf nitrogen on alpha.
##' @param centuryControl List that controls aspects of the Century model for
##' carbon and nitrogen dynamics in the soil. It should be supplied through the
##' \code{centuryParms} function.
##'
##' \code{SC1-9} Soil carbon pools in the soil.  SC1: Structural surface
##' litter.  SC2: Metabolic surface litter.  SC3: Structural root litter.  SC4:
##' Metabolic root litter.  SC5: Surface microbe.  SC6: Soil microbe.  SC7:
##' Slow carbon.  SC8: Passive carbon.  SC9: Leached carbon.
##'
##' \code{LeafL.Ln} Leaf litter lignin content.
##'
##' \code{StemL.Ln} Stem litter lignin content.
##'
##' \code{RootL.Ln} Root litter lignin content.
##'
##' \code{RhizomeL.Ln} Rhizome litter lignin content.
##'
##' \code{LeafL.N} Leaf litter nitrogen content.
##'
##' \code{StemL.N} Stem litter nitrogen content.
##'
##' \code{RootL.N} Root litter nitrogen content.
##'
##' \code{RhizomeL.N} Rhizome litter nitrogen content.
##'
##' \code{Nfert} Nitrogen from a fertilizer source.
##'
##' \code{iMinN} Initial value for the mineral nitrogen pool.
##'
##' \code{Litter} Initial values of litter (leaf, stem, root, rhizome).
##'
##' \code{timestep} currently either week (default) or day.
##' @export
##' @return
##'
##' a \code{\link{list}} structure with components
##' @returnItem DayofYear Day of the year
##' @returnItem Hour Hour for each day
##' @returnItem CanopyAssim Hourly canopy assimilation, (Mg \eqn{ha^-1} ground
##' \eqn{hr^-1}).
##' @returnItem CanopyTrans Hourly canopy transpiration, (Mg \eqn{ha^-1} ground
##' \eqn{hr^-1}).
##' @returnItem Leaf leaf dry biomass (Mg \eqn{ha^-1}).
##' @returnItem Stem stem dry biomass(Mg \eqn{ha^-1}).
##' @returnItem Root root dry biomass (Mg \eqn{ha^-1}).
##' @returnItem Rhizome rhizome dry biomass (Mg \eqn{ha^-1}).
##' @returnItem LAI leaf area index (\eqn{m^2} \eqn{m^-2}).
##' @returnItem ThermalT thermal time (Celsius \eqn{day^-1}).
##' @returnItem StomatalCondCoefs Coefficeint which determines the effect of
##' water stress on stomatal conductance and photosynthesis.
##' @returnItem LeafReductionCoefs Coefficient which determines the effect of
##' water stress on leaf expansion reduction.
##' @returnItem LeafNitrogen Leaf nitrogen.
##' @returnItem AboveLitter Above ground biomass litter (Leaf + Stem).
##' @returnItem BelowLitter Below ground biomass litter (Root + Rhizome).
##' @returnItem VmaxVec Value of Vmax during the growing season.
##' @returnItem AlphaVec Value of alpha during the growing season.
##' @returnItem SpVec Value of the specific leaf area.
##' @returnItem MinNitroVec Nitrogen in the mineral pool.
##' @returnItem RespVec Soil respiration.
##' @returnItem SoilEvaporation Soil Evaporation.
##' @keywords models
##' @examples
##'
##' \dontrun{
##' data(weather05)
##'
##' res0 <- BioGro(weather05)
##'
##' plot(res0)
##'
##' ## Looking at the soil model
##'
##' res1 <- BioGro(weather05, soilControl = soilParms(soilLayers = 6))
##' plot(res1, plot.kind='SW') ## Without hydraulic distribution
##' res2 <- BioGro(weather05, soilControl = soilParms(soilLayers = 6, hydrDist=TRUE))
##' plot(res2, plot.kind='SW') ## With hydraulic distribution
##'
##'
##' ## Example of user defined soil parameters.
##' ## The effect of phi2 on yield and soil water content
##'
##' ll.0 <- soilParms(FieldC=0.37,WiltP=0.2,phi2=1)
##' ll.1 <- soilParms(FieldC=0.37,WiltP=0.2,phi2=2)
##' ll.2 <- soilParms(FieldC=0.37,WiltP=0.2,phi2=3)
##' ll.3 <- soilParms(FieldC=0.37,WiltP=0.2,phi2=4)
##'
##' ans.0 <- BioGro(weather05,soilControl=ll.0)
##' ans.1 <- BioGro(weather05,soilControl=ll.1)
##' ans.2 <- BioGro(weather05,soilControl=ll.2)
##' ans.3 <-BioGro(weather05,soilControl=ll.3)
##'
##' xyplot(ans.0$SoilWatCont +
##'        ans.1$SoilWatCont +
##'        ans.2$SoilWatCont +
##'        ans.3$SoilWatCont ~ ans.0$DayofYear,
##'        type='l',
##'        ylab='Soil water Content (fraction)',
##'        xlab='DOY')
##'
##' ## Compare LAI
##'
##' xyplot(ans.0$LAI +
##'        ans.1$LAI +
##'        ans.2$LAI +
##'        ans.3$LAI ~ ans.0$DayofYear,
##'        type='l',
##'        ylab='Leaf Area Index',
##'        xlab='DOY')
##'
##'
##'
##' }
##' @export
BioGro <- function(WetDat, day1 = NULL, dayn = NULL, timestep = 1, lat = 40, iRhizome = 7, 
    irtl = 1e-04, canopyControl = list(), seneControl = list(), photoControl = list(), 
    phenoControl = list(), soilControl = list(), nitroControl = list(), sugarphenoControl = list(), 
    centuryControl = list()) {
    
    
    ## Trying to guess the first and last day of the growing season from weather
    ## data
    
    
    if (missing(day1)) {
        half <- as.integer(dim(WetDat)[1]/2)
        WetDat1 <- WetDat[1:half, c(2, 5)]
        if (min(WetDat1[, 2]) > 0) {
            day1 <- 90
        } else {
            WetDat1s <- WetDat1[which(WetDat1[, 2] < 0), ]
            day1 <- max(WetDat1s[, 1])
            if (day1 < 90) 
                day1 <- 90
        }
    }
    if (missing(dayn)) {
        half <- as.integer(dim(WetDat)[1]/2)
        WetDat1 <- WetDat[half:dim(WetDat)[1], c(2, 5)]
        if (min(WetDat1[, 2]) > 0) {
            dayn <- 330
        } else {
            WetDat1s <- WetDat1[which(WetDat1[, 2] < 0), ]
            dayn <- min(WetDat1s[, 1])
            if (dayn > 330) 
                dayn <- 330
        }
    }
    
    
    if ((day1 < 0) || (day1 > 365) || (dayn < 0) || (dayn > 365)) 
        stop("day1 and dayn should be between 0 and 365")
    if (day1 > dayn) 
        stop("day1 should be smaller than dayn")
    if ((timestep < 1) || (24%%timestep != 0)) 
        stop("timestep should be a divisor of 24 (e.g. 1,2,3,4,6,etc.)")
    ## Getting the Parameters
    canopyP <- canopyParms()
    canopyP[names(canopyControl)] <- canopyControl
    
    
    soilP <- soilParms()
    soilP[names(soilControl)] <- soilControl
    nitroP <- nitroParms()
    nitroP[names(nitroControl)] <- nitroControl
    phenoP <- phenoParms()
    phenoP[names(phenoControl)] <- phenoControl
    sugarphenoP <- SugarPhenoParms()
    sugarphenoP[names(sugarphenoControl)] <- sugarphenoControl
    photoP <- photoParms()
    photoP[names(photoControl)] <- photoControl
    seneP <- seneParms()
    seneP[names(seneControl)] <- seneControl
    centuryP <- centuryParms()
    centuryP[names(centuryControl)] <- centuryControl
    tint <- 24/timestep
    vecsize <- (dayn - (day1 - 1)) * tint
    indes1 <- (day1 - 1) * tint
    indesn <- (dayn) * tint
    
    
    doy <- WetDat[indes1:indesn, 2]
    hr <- WetDat[indes1:indesn, 3]
    solar <- WetDat[indes1:indesn, 4]
    temp <- WetDat[indes1:indesn, 5]
    rh <- WetDat[indes1:indesn, 6]
    windspeed <- WetDat[indes1:indesn, 7]
    precip <- WetDat[indes1:indesn, 8]
    if (max(rh) > 1) 
        stop("Rel Hum. should be 0 < rh < 1")
    if ((min(hr) < 0) | (max(hr) > 23)) 
        stop("hr should be between 0 and 23")
    
    
    DBPcoefs <- valid_dbp(as.vector(unlist(phenoP)[7:31]))
    TPcoefs <- as.vector(unlist(phenoP)[1:6])
    sugarcoefs <- as.vector(unlist(sugarphenoP))
    SENcoefs <- as.vector(unlist(seneP))
    soilCoefs <- c(unlist(soilP[1:5]), mean(soilP$iWatCont), soilP$scsf, soilP$transpRes, 
        soilP$leafPotTh)
    wsFun <- soilP$wsFun
    soilType <- soilP$soilType
    centCoefs <- as.vector(unlist(centuryP)[1:24])
    if (centuryP$timestep == "year") {
        stop("Not developed yet")
        centTimestep <- dayn - day1  ## This is really the growing season
    }
    if (centuryP$timestep == "week") 
        centTimestep <- 7
    if (centuryP$timestep == "day") 
        centTimestep <- 1
    
    
    vmax <- photoP$vmax
    alpha <- photoP$alpha
    kparm <- photoP$kparm
    theta <- photoP$theta
    beta <- photoP$beta
    Rd <- photoP$Rd
    Catm <- photoP$Catm
    b0 <- photoP$b0
    b1 <- photoP$b1
    ws <- photoP$ws
    mResp <- canopyP$mResp
    kd <- canopyP$kd
    chi.l <- canopyP$chi.l
    Sp <- canopyP$Sp
    SpD <- canopyP$SpD
    heightF <- canopyP$heightFactor
    nlayers <- canopyP$nlayers
    
    
    res <- .Call(MisGro, as.double(lat), as.integer(doy), as.integer(hr), as.double(solar), 
        as.double(temp), as.double(rh), as.double(windspeed), as.double(precip), 
        as.double(kd), as.double(c(chi.l, heightF)), as.integer(nlayers), as.double(iRhizome), 
        as.double(irtl), as.double(SENcoefs), as.integer(timestep), as.integer(vecsize), 
        as.double(Sp), as.double(SpD), as.double(DBPcoefs), as.double(TPcoefs), as.double(vmax), 
        as.double(alpha), as.double(kparm), as.double(theta), as.double(beta), as.double(Rd), 
        as.double(Catm), as.double(b0), as.double(b1), as.integer(ws), as.double(soilCoefs), 
        as.double(nitroP$iLeafN), as.double(nitroP$kLN), as.double(nitroP$Vmax.b1), 
        as.double(nitroP$alpha.b1), as.double(mResp), as.integer(soilType), as.integer(wsFun), 
        as.double(centCoefs), as.integer(centTimestep), as.double(centuryP$Ks), as.integer(soilP$soilLayers), 
        as.double(soilP$soilDepths), as.double(soilP$iWatCont), as.integer(soilP$hydrDist), 
        as.double(c(soilP$rfl, soilP$rsec, soilP$rsdf)), as.double(nitroP$kpLN), 
        as.double(nitroP$lnb0), as.double(nitroP$lnb1), as.integer(nitroP$lnFun), 
        as.double(sugarcoefs))
    
    
    res$cwsMat <- t(res$cwsMat)
    colnames(res$cwsMat) <- soilP$soilDepths[-1]
    res$rdMat <- t(res$rdMat)
    colnames(res$rdMat) <- soilP$soilDepths[-1]
    res$psimMat <- t(res$psimMat)
    colnames(res$psimMat) <- soilP$soilDepths[-1]
    structure(res, class = "BioGro")
}
canopyParms <- function(Sp = 1.7, SpD = 0, nlayers = 10, kd = 0.1, chi.l = 1, mResp = c(0.02, 
    0.03), heightFactor = 3) {
    if ((nlayers < 1) || (nlayers > 50)) 
        stop("nlayers should be between 1 and 50")
    if (Sp <= 0) 
        stop("Sp should be positive")
    if (heightFactor <= 0) 
        stop("heightFactor should be positive")
    
    
    list(Sp = Sp, SpD = SpD, nlayers = nlayers, kd = kd, chi.l = chi.l, mResp = mResp, 
        heightFactor = heightFactor)
}
photoParms <- function(vmax = 39, alpha = 0.04, kparm = 0.7, theta = 0.83, beta = 0.93, 
    Rd = 0.8, Catm = 380, b0 = 0.01, b1 = 3, ws = c("gs", "vmax")) {
    ws <- match.arg(ws)
    if (ws == "gs") 
        ws <- 1 else ws <- 0
    
    
    list(vmax = vmax, alpha = alpha, kparm = kparm, theta = theta, beta = beta, Rd = Rd, 
        Catm = Catm, b0 = b0, b1 = b1, ws = ws)
}
soilParms <- function(FieldC = NULL, WiltP = NULL, phi1 = 0.01, phi2 = 10, soilDepth = 1, 
    iWatCont = NULL, soilType = 6, soilLayers = 1, soilDepths = NULL, hydrDist = 0, 
    wsFun = c("linear", "logistic", "exp", "none", "lwp"), scsf = 1, transpRes = 5e+06, 
    leafPotTh = -800, rfl = 0.2, rsec = 0.2, rsdf = 0.44) {
    if (soilLayers < 1 || soilLayers > 50) 
        stop("soilLayers must be an integer larger than 0 and smaller than 50")
    if (missing(iWatCont)) {
        if (missing(FieldC)) 
            iWatCont <- rep(SoilType(soilType)$fieldc, soilLayers) else iWatCont <- rep(FieldC, soilLayers)
    } else {
        if (length(iWatCont) == 1) 
            iWatCont <- rep(iWatCont, soilLayers)
    }
    if (length(iWatCont) != soilLayers) {
        stop("iWatCont should be NULL, of length 1 or length == soilLayers")
    }
    if (missing(soilDepths)) {
        soilDepths <- seq(0, soilDepth, length.out = I(soilLayers + 1))
    } else {
        if (length(soilDepths) != I(soilLayers + 1)) 
            stop("soilDepths should be of length == soilLayers + 1")
    }
    if (missing(FieldC)) 
        FieldC <- -1
    if (missing(WiltP)) 
        WiltP <- -1
    
    
    wsFun <- match.arg(wsFun)
    if (wsFun == "linear") 
        wsFun <- 0 else if (wsFun == "logistic") 
        wsFun <- 1 else if (wsFun == "exp") 
        wsFun <- 2 else if (wsFun == "none") 
        wsFun <- 3 else if (wsFun == "lwp") 
        wsFun <- 4
    
    
    list(FieldC = FieldC, WiltP = WiltP, phi1 = phi1, phi2 = phi2, soilDepth = soilDepth, 
        iWatCont = iWatCont, soilType = soilType, soilLayers = soilLayers, soilDepths = soilDepths, 
        wsFun = wsFun, scsf = scsf, transpRes = transpRes, leafPotTh = leafPotTh, 
        hydrDist = hydrDist, rfl = rfl, rsec = rsec, rsdf = rsdf)
}
nitroParms <- function(iLeafN = 2, kLN = 0.5, Vmax.b1 = 0, alpha.b1 = 0, kpLN = 0.2, 
    lnb0 = -5, lnb1 = 18, lnFun = c("none", "linear")) {
    lnFun <- match.arg(lnFun)
    if (lnFun == "none") {
        lnFun <- 0
    } else {
        lnFun <- 1
    }
    
    
    list(iLeafN = iLeafN, kLN = abs(kLN), Vmax.b1 = Vmax.b1, alpha.b1 = alpha.b1, 
        kpLN = kpLN, lnb0 = lnb0, lnb1 = lnb1, lnFun = lnFun)
}
phenoParms <- function(tp1 = 562, tp2 = 1312, tp3 = 2063, tp4 = 2676, tp5 = 3211, 
    tp6 = 7000, kLeaf1 = 0.33, kStem1 = 0.37, kRoot1 = 0.3, kRhizome1 = -8e-04, kLeaf2 = 0.14, 
    kStem2 = 0.85, kRoot2 = 0.01, kRhizome2 = -5e-04, kLeaf3 = 0.01, kStem3 = 0.63, 
    kRoot3 = 0.01, kRhizome3 = 0.35, kLeaf4 = 0.01, kStem4 = 0.63, kRoot4 = 0.01, 
    kRhizome4 = 0.35, kLeaf5 = 0.01, kStem5 = 0.63, kRoot5 = 0.01, kRhizome5 = 0.35, 
    kLeaf6 = 0.01, kStem6 = 0.63, kRoot6 = 0.01, kRhizome6 = 0.35, kGrain6 = 0) {
    if (kGrain6 < 0) 
        stop("kGrain6 should be positive (zero is allowed)")
    list(tp1 = tp1, tp2 = tp2, tp3 = tp3, tp4 = tp4, tp5 = tp5, tp6 = tp6, kLeaf1 = kLeaf1, 
        kStem1 = kStem1, kRoot1 = kRoot1, kRhizome1 = kRhizome1, kLeaf2 = kLeaf2, 
        kStem2 = kStem2, kRoot2 = kRoot2, kRhizome2 = kRhizome2, kLeaf3 = kLeaf3, 
        kStem3 = kStem3, kRoot3 = kRoot3, kRhizome3 = kRhizome3, kLeaf4 = kLeaf4, 
        kStem4 = kStem4, kRoot4 = kRoot4, kRhizome4 = kRhizome4, kLeaf5 = kLeaf5, 
        kStem5 = kStem5, kRoot5 = kRoot5, kRhizome5 = kRhizome5, kLeaf6 = kLeaf6, 
        kStem6 = kStem6, kRoot6 = kRoot6, kRhizome6 = kRhizome6, kGrain6 = kGrain6)
    
    
}
SugarPhenoParms <- function(TT0 = 200, TTseed = 800, Tmaturity = 6000, Rd = 0.06, 
    Alm = 0.15, Arm = 0.08, Clstem = 0.04, Ilstem = 7, Cestem = -0.05, Iestem = 45, 
    Clsuc = 0.01, Ilsuc = 25, Cesuc = -0.02, Iesuc = 45) {
    # Think about Error conditions in parameter values TT0= End of germination
    # phase TTseed = seed cane stops providing nutrients/C for plant parts
    # Tmaturity = Thermal time required to reach the maturity for the crop Rd=
    # decline coefficients for root allocation Alm = minimum fraction to leaf
    # minimum fraction to root Clstem and Ilstem togetehr determines when the
    # linear phase of stem allocation ends Cestem and Iestem togetger determines
    # when the log phase of stem allocation ends Clsuc and Ilsuc determines when
    # the linear phase of sugar fraction ends Cesuc and Iesuc determines when the
    # log phase of sugar fraction ends
    
    
    list(TT0 = TT0, TTseed = TTseed, Tmaturity = Tmaturity, Rd = Rd, Alm = Alm, Arm = Arm, 
        Clstem = Clstem, Ilstem = Ilstem, Cestem = Cestem, Iestem = Iestem, Clsuc = Clsuc, 
        Ilsuc = Ilsuc, Cesuc = Cesuc, Iesuc = Iesuc)
    
    
}
seneParms <- function(senLeaf = 3000, senStem = 3500, senRoot = 4000, senRhizome = 4000) {
    list(senLeaf = senLeaf, senStem = senStem, senRoot = senRoot, senRhizome = senRhizome)
}
## Function to automatically plot objects of BioGro class Colors Stem, Leaf,
## Root, Rhizome, LAI
##' Plotting function for BioGro objects
##'
##' By default it plots stem, leaf, root, rhizome and LAI for a \code{BioGro}
##' object. Optionally, the observed data can be plotted.
##'
##' This function uses internally \code{\link[lattice]{xyplot}} in the
##' 'lattice' package.
##'
##' @param x \code{\link{BioGro}} object.
##' @param obs optional observed data object (format following the
##' \code{\link{OpBioGro}} function .
##' @param stem whether to plot simulated stem (default = TRUE).
##' @param leaf whether to plot simulated leaf (default = TRUE).
##' @param root whether to plot simulated root (default = TRUE).
##' @param rhizome whether to plot simulated rhizome (default = TRUE).
##' @param grain whether to plot simulated grain (default = TRUE).
##' @param LAI whether to plot simulated LAI (default = TRUE).
##' @param pch point character.
##' @param lty line type.
##' @param lwd line width.
##' @param col Control of colors.
##' @param x1 position of the legend. x coordinate (0-1).
##' @param y1 position of the legend. y coordinate (0-1).
##' @param plot.kind DB plots dry biomass and SW plots soil water.
##' @param \dots Optional arguments.
##' @seealso \code{\link{BioGro}} \code{\link{OpBioGro}}
##' @keywords hplot
##' @export
##' @S3method plot BioGro
plot.BioGro <- function(x, obs = NULL, stem = TRUE, leaf = TRUE, root = TRUE, rhizome = TRUE, 
    LAI = TRUE, grain = TRUE, xlab = NULL, ylab = NULL, pch = 21, lty = 1, lwd = 1, 
    col = c("blue", "green", "red", "magenta", "black", "purple"), x1 = 0.1, y1 = 0.8, 
    plot.kind = c("DB", "SW"), ...) {
    if (missing(xlab)) {
        xlab <- expression(paste("Thermal Time (", degree, "C d)"))
    }
    if (missing(ylab)) {
        ylab <- expression(paste("Dry Biomass (Mg ", ha^-1, ")"))
    }
    pchs <- rep(pch, length = 6)
    ltys <- rep(lty, length = 6)
    cols <- rep(col, length = 6)
    lwds <- rep(lwd, length = 6)
    plot.kind <- match.arg(plot.kind)
    if (plot.kind == "DB") {
        if (missing(obs)) {
            sim <- x
            plot1 <- xyplot(sim$Stem ~ sim$ThermalT, type = "l", ..., ylim = c(0, 
                I(max(sim$Stem, na.rm = TRUE) + 5)), xlab = xlab, ylab = ylab, panel = function(x, 
                y, ...) {
                if (stem == TRUE) {
                  panel.xyplot(sim$ThermalT, sim$Stem, col = cols[1], lty = ltys[1], 
                    lwd = lwds[1], ...)
                }
                if (leaf == TRUE) {
                  panel.xyplot(sim$ThermalT, sim$Leaf, col = cols[2], lty = ltys[2], 
                    lwd = lwds[2], ...)
                }
                if (root == TRUE) {
                  panel.xyplot(sim$ThermalT, sim$Root, col = cols[3], lty = ltys[3], 
                    lwd = lwds[3], ...)
                }
                if (rhizome == TRUE) {
                  panel.xyplot(sim$ThermalT, sim$Rhizome, col = cols[4], lty = ltys[4], 
                    lwd = lwds[4], ...)
                }
                if (grain == TRUE) {
                  panel.xyplot(sim$ThermalT, sim$Grain, col = cols[5], lty = ltys[5], 
                    lwd = lwds[5], ...)
                }
                if (LAI == TRUE) {
                  panel.xyplot(sim$ThermalT, sim$LAI, col = cols[6], lty = ltys[6], 
                    lwd = lwds[6], ...)
                }
            }, key = list(text = list(c("Stem", "Leaf", "Root", "Seedcane", "Grain", 
                "LAI")), col = cols, lty = ltys, lwd = lwds, lines = TRUE, x = x1, 
                y = y1))
            print(plot1)
        } else {
            if (ncol(obs) != 7) 
                stop("obs should have 7 columns")
            sim <- x
            ymax <- I(max(c(sim$Stem, obs[, 2]), na.rm = TRUE) + 5)
            plot1 <- xyplot(sim$Stem ~ sim$ThermalT, ..., ylim = c(0, ymax), xlab = xlab, 
                ylab = ylab, panel = function(x, y, ...) {
                  if (stem == TRUE) {
                    panel.xyplot(sim$ThermalT, sim$Stem, col = cols[1], lty = ltys[1], 
                      lwd = lwds[1], type = "l", ...)
                  }
                  if (leaf == TRUE) {
                    panel.xyplot(sim$ThermalT, sim$Leaf, col = cols[2], lty = ltys[2], 
                      lwd = lwds[2], type = "l", ...)
                  }
                  if (root == TRUE) {
                    panel.xyplot(sim$ThermalT, sim$Root, col = cols[3], lty = ltys[3], 
                      lwd = lwds[3], type = "l", ...)
                  }
                  if (rhizome == TRUE) {
                    panel.xyplot(sim$ThermalT, sim$Rhizome, col = cols[4], lty = ltys[4], 
                      lwd = lwds[4], type = "l", ...)
                  }
                  if (grain == TRUE) {
                    panel.xyplot(sim$ThermalT, sim$Grain, col = cols[5], lty = ltys[5], 
                      lwd = lwds[5], type = "l", ...)
                  }
                  if (LAI == TRUE) {
                    panel.xyplot(sim$ThermalT, sim$LAI, col = cols[6], lty = ltys[6], 
                      lwd = lwds[6], type = "l", ...)
                  }
                  
                  
                  panel.xyplot(obs[, 1], obs[, 2], col = cols[1], pch = pchs[1], 
                    ...)
                  panel.xyplot(obs[, 1], obs[, 3], col = cols[2], pch = pchs[2], 
                    ...)
                  panel.xyplot(obs[, 1], obs[, 4], col = cols[3], pch = pchs[3], 
                    ...)
                  panel.xyplot(obs[, 1], obs[, 5], col = cols[4], pch = pchs[4], 
                    ...)
                  panel.xyplot(obs[, 1], obs[, 6], col = cols[5], pch = pchs[5], 
                    ...)
                  panel.xyplot(obs[, 1], obs[, 7], col = cols[6], pch = pchs[6], 
                    ...)
                }, key = list(text = list(c("Stem", "Leaf", "Root", "Seedcane", "Grain", 
                  "LAI")), col = cols, lines = TRUE, points = TRUE, lty = ltys, pch = pchs, 
                  lwd = lwds, x = x1, y = y1))
            print(plot1)
        }
    } else if (plot.kind == "SW") {
        matplot(x$ThermalT, as.matrix(x$cwsMat), type = "l", ylab = "Soil Water Content", 
            xlab = "Thermal Time")
    }
}
##' @export
##' @S3method print BioGro
print.BioGro <- function(x, level = 1, ...) {
    if (level == 0) {
        print(summary(as.data.frame(unclass(x)[1:23])))
    } else if (level == 1) {
        print(summary(as.data.frame(unclass(x)[c(1, 2, 5:11)])))
    } else if (level == 2) {
        print(summary(as.data.frame(unclass(x)[c(1, 2, 11, 12, 23)])))
    } else if (level == 3) {
        print(summary(as.data.frame(unclass(x)[c(1, 2, 11:23)])))
    }
} 
