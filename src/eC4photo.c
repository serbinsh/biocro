/*
 *  BioCro/src/eC4photo.c by Fernando Ezequiel Miguez  Copyright (C) 2007-2009
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 or 3 of the License
 *  (at your option).
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  A copy of the GNU General Public License is available at
 *  http://www.r-project.org/Licenses/
 *
 */

#include <R.h>
#include <math.h>
#include <Rmath.h>
#include <Rinternals.h>
#include "AuxBioCro.h"
#include "CanA.h"

int enObs;

/*%Second section for defining functions*/
double eC4photoC(double QP, double TEMP, double RH, double CA,
		double OA, double VCMAX, double VPMAX, double VPR,
		double JMAX);



/* This file will contain the function which will consolidate
 the previous functions into one. The idea is to go from
 existing LAI and weather conditions to canopy assimilation
 and transpiration */

SEXP eCanA(SEXP lai, SEXP Doy, SEXP Hr, SEXP SolarR, SEXP ATemp,
	  SEXP RelH, SEXP WindS, SEXP CA, SEXP OA,
	   SEXP VCMAX, SEXP VPMAX,
	  SEXP VPR, SEXP JMAX, SEXP STOMATAWS)
{
  /* const int NLAYERS = 3;  this should eventually be replaced with
			    an argument coming in from R */
  struct ET_Str tmp5, tmp6;


  int i;
  double Idir, Idiff, cosTh;
  double LAIc;
  double IDir, IDiff, Itot, rh, WS;
  double pLeafsun, pLeafshade;
  double Leafsun, Leafshade;

/*   double tmp5,tmp6; */
  double TempIdir,TempIdiff,AssIdir,AssIdiff;

  double CanopyA;
  double CanHeight;

  const double cf = 3600 * 1e-6 ;

  int DOY , hr;
  double LAI, solarR, Temp, RH, WindSpeed;
  double Ca, Oa, Vcmax, Vpmax, Vpr, Jmax;

  double lat = 40;
  int nlayers = 3;
  double kd = 0.1;
  double chil = 1;
  double stomataws;

  SEXP growth;

  PROTECT(growth = allocVector(REALSXP,1));


  LAI = REAL(lai)[0];
  DOY = INTEGER(Doy)[0];
  hr = INTEGER(Hr)[0];
  solarR = REAL(SolarR)[0];
  Temp = REAL(ATemp)[0];
  RH = REAL(RelH)[0];
  WindSpeed = REAL(WindS)[0];
  Ca = REAL(CA)[0];
  Oa = REAL(OA)[0];
  Vcmax = REAL(VCMAX)[0];
  Vpmax = REAL(VPMAX)[0];
  Vpr = REAL(VPR)[0];
  Jmax = REAL(JMAX)[0];
  stomataws = REAL(STOMATAWS)[0];

  lightME(lat,DOY,hr);

  Idir = tmp1[0] * solarR;
  Idiff = tmp1[1] * solarR;
  cosTh = tmp1[2];
    
  sunML(Idir,Idiff,LAI,nlayers,cosTh,kd,chil, 3);

  /* results from multilayer model */
  LAIc = LAI / nlayers;
  /* Next I need the RH and wind profile */
  RHprof(RH,nlayers);
  WINDprof(WindSpeed,LAI,nlayers);

  /* Next use the EvapoTrans function */
  CanopyA=0.0;
  for(i=0;i<nlayers;i++)
    {
      IDir = layIdir[--sp1];
      Itot = layItotal[--sp3];

      rh = tmp4[--tp4];
      WS = tmp3[--tp3];
      pLeafsun = layFsun[--sp4];
      CanHeight = layHeight[--sp6];
      Leafsun = LAIc * pLeafsun;
      tmp5 = EvapoTrans(IDir,Itot,Temp,rh,WS,Leafsun,CanHeight,stomataws,1,39,0.04,0.7,0.83,0.93,0.8,0.01,3);
      /* not the right thing to do here to add these values at the end of the ET function
but just a simple fix for now. The problem is that the eC4photoC function should have its own
EvapoTrans function. */
      TempIdir = Temp + tmp5.Deltat;
      AssIdir = eC4photoC(IDir,TempIdir,rh,Ca,Oa,Vcmax,
			 Vpmax,Vpr,Jmax);

      IDiff = layIdiff[--sp2];
      pLeafshade = layFshade[--sp5];
      Leafshade = LAIc * pLeafshade;
      tmp6 = EvapoTrans(IDiff,Itot,Temp,rh,WS,Leafshade,CanHeight,stomataws,1,39,0.04,0.7,0.83,0.93,0.8,0.01,3);
      /* not the right thing to do here to add these values at the end of the ET function
but just a simple fix for now*/
      TempIdiff = Temp + tmp6.Deltat;
      AssIdiff = eC4photoC(IDiff,TempIdiff,rh,Ca,Oa,Vcmax,
			  Vpmax,Vpr,Jmax);

     CanopyA += Leafsun * AssIdir + Leafshade * AssIdiff;
   }
  /* These are micro mols of CO2 per m2 per sec
    Need to convert to 
    3600 converts seconds to hours
    10^-6 converts micro mols to mols
    */
  REAL(growth)[0] = cf * CanopyA ;
  UNPROTECT(1);  
  return(growth);

   }

double eC4photoC(double QP, double TEMP, double RH, double CA,
		double OA, double VCMAX, double VPMAX, double VPR,
		double JMAX)
{
    /* CONSTANTS */
    const double  gs = 3 * 1e-3 ;
    /* mol m-2 s-1 physical conductance to CO2 leakage*/
    /* const double gammaStar = 0.000193  */
    const double gammaStar =  0.0002239473      ;
    /* half the reciprocal of Rubisco specificity */
    /*    const double go = 0.047 * gs     at 25 C */
    const double a = 0.01 ; /* alpha in the notes*/
    const double Kp = 80 ; /*  mu bar */
    /* const double Kc1 = 650 * 1e-3  mbar at 25 C */
    const double Kc1 = 1020 * 1e-3; /*  mbar at 25 C */

    const double theta = 0.7;

    /* ADDING THE TEMPERATURE RESPONSE FUNCTION */
    const double Epr = 46.8 ; /* Activation energy of PPDK kj/mol*/
    const double Ep  = 47.1 ; /* Activation energy of PEPc kj/mol */
    const double Erb = 72 ; /* Activation energy of Rubisco kj/mol */
    /*    const double Q10bf = 1.7 */
    const double ERd = 46.39;
    const double EKc = 79.43;
    const double EKo = 36.38;
    const double Q10cb = 1.7;

    /* double Ko = 450 ;  mbar at 25 C */
    double Ko = 532.9 ; /* mbar at 25 C */
    /* double Kc = 650   mu bar at 25 C */
    double Kc = 1020 ; /*  mu bar at 25 C */
    
    /* VAriables */ 
    double Idir, AirTemp, rh, Ca, Oa;
    double Vcmax, Vpmax, Vpr, Jmax;

    double Q10pr, Q10p, Q10rb, Q10Rd, Q10Kc, Q10Ko;
    double Cm, Om;
    double Rd, Rm, Rs;

    double I2, J, Aj0, Aj1, Aj;
    double Vp, Ko1 , Om1;
    double a1, b1, c1 , c3, Ac0;
    double AcLCO2, Ac, A;
    double Os, Cs;
    double Cs0, Cs1;


    Idir = QP;
    AirTemp = TEMP;
    rh = RH;
    Ca = CA;
    Oa = OA;
    Vcmax = VCMAX;
    Vpmax = VPMAX;
    Vpr = VPR;
    Jmax = JMAX;

    Q10pr = exp(Epr *(1/(0.008314*298.15)-1/(0.008314*(AirTemp+273.15))));
    Q10p = exp(Ep *(1/(0.008314*298.15)-1/(0.008314*(AirTemp+273.15))));
    Q10rb = exp(Erb *(1/(0.008314*298.15)-1/(0.008314*(AirTemp+273.15))));
    Q10Rd = exp(ERd *(1/(0.008314*298.15)-1/(0.008314*(AirTemp+273.15))));
    Q10Kc = exp(EKc *(1/(0.008314*298.15)-1/(0.008314*(AirTemp+273.15))));
    Q10Ko = exp(EKo *(1/(0.008314*298.15)-1/(0.008314*(AirTemp+273.15))));

    Vcmax = Vcmax * Q10rb;
    Kc = Kc * Q10Kc;
    Ko = Ko * Q10Ko;
    Vpmax = Vpmax * Q10p;        
    Jmax = Jmax * pow(Q10cb,(AirTemp-25)/10);

    Cm = 0.4 * Ca ; 
    Om = Oa ;
        
    /*    Rd = 0.01 * Vcmax; */
    Rd = 0.08;
    Rm = 0.5 * Rd ;
    Rs = 0.5 * Rd;
        
    /* Light limited */
    I2 = (Idir * 0.85)/2;
    J = (Jmax + I2  - sqrt(pow(Jmax+I2,2) - 4 * theta * I2 * Jmax ))/2*theta;        
    Aj0 = 0.4 * J - Rm + gs * Cm;        
    Aj1 = (1-0.4)*J/3-Rd;

    if(Aj0 < Aj1){
      Aj = Aj0;
    }else{
      Aj = Aj1;
    }
        

    /* Other part */
    Vp = (Cm * Vpmax) / (Cm + Kp) ;
    if(Vpr < Vp){
      Vp = Vpr;
    }
	        
    /* Alternative formula */
    Ko1 = Ko * 1e3;
    Om1 = Om * 1e3;

    a1 = 1 - a / 0.047 * Kc/Ko1 ;
    b1 = -((Vp - Rm + gs * Cm)+
	   (Vcmax - Rd)+
	   gs*(Kc*(1+Om1/Ko1))+
	   ((a/0.047)*(gammaStar*Vcmax+Rd*Kc/Ko1)));
    c1 = (Vcmax - Rd)*(Vp-Rm+gs*Cm)-
          (Vcmax * gs * gammaStar * Om1 + Rd*gs*Kc*(1+Om1/Ko1));
         
    c3 = pow(b1,2) - 4*a1*c1;
      if(c3 < 0){
	c3 = 0;
      }
    Ac0 = (-b1 - sqrt(c3)) / 2*a1 ;

    AcLCO2 = (Cm * Vpmax/(Cm+Kp)) - Rm + gs * Cm;
    
    if(Ac0 < AcLCO2){
      Ac = Ac0;
    }else{
      Ac = AcLCO2;
    }

    if(Aj < Ac){
      A = Aj;
    }else{
      A = Ac;
    }
        
    Os = a * A / 0.047 * gs + Om;
    if(Aj <= Ac){
      Cs0 = (gammaStar * Os)*(7/3*(Aj + Rd) + (1-0.4)*J/3);
      Cs1 = (1-0.4)*J/3-(Aj) ; 
      Cs = Cs0/Cs1;
    }else{
      Cs0 = gammaStar * Os + Kc1*(1+Os/Ko)*((Ac+Rd)/Vcmax);
          if((Ac+Rd) >= Vcmax){
	    Ac = Vcmax - Rd - 0.5 ;
	  }
	  Cs1 = 1 - (Ac+Rd)/Vcmax;
	  Cs = Cs0/Cs1;
    }
    return(A);
}



/* Defining some constants */

SEXP eC4photo(SEXP QP, SEXP TEMP, SEXP RH, SEXP CA,
		SEXP OA, SEXP VCMAX, SEXP VPMAX, SEXP VPR,
		SEXP JMAX)
{
  int nqp, i;
  nqp = length(QP);
    /* CONSTANTS */
  double P = 101.3;
  double G1 = 3;
  double G0 = 0.08;

    const double  gs = 3 * 1e-3 ;
    /* mol m-2 s-1 physical conductance to CO2 leakage*/
    /* const double gammaStar = 0.000193  */
    const double gammaStar =  0.000193 ;
    /* half the reciprocal of Rubisco specificity */
    /*    const double go = 0.047 * gs     at 25 C */
    const double alpha = 0.01 ; /* alpha in the notes*/
    double Kp = 80 ; /*  mu bar */
    double theta = 0.7;
    const double R = 0.008314472; /* Gas constant J K-1 mol-1 */
    /* in the units stated should be 8.314 but 
       XGZ determined it is * 1e-3 */ 
    const double Kelvin0 = 273.15;
    const double Kelvin25 = 298.15;
    /* This is 0 and 25 Celsius degrees in the Kelvin scale */

    /* ADDING THE TEMPERATURE RESPONSE FUNCTION */
    double Epr = 46.8 ; /* Activation energy of PPDK kj/mol*/
    double Ep  = 47.1 ; /* Activation energy of PEPc kj/mol */
    double Erb = 72 ; /* Activation energy of Rubisco kj/mol */
    /*    const double Q10bf = 1.7 */
    double ERd = 46.39;
    double EKc = 79.43;
    double EKo = 36.38;
    double Q10cb = 1.7;

    /* double Ko = 450 ;  mbar at 25 C */
    double Ko2 = 450 ; /* mbar at 25 C */
    /* double Kc = 650   mu bar at 25 C */
    double Kc2 = 650 ; /*  mu bar at 25 C */
    
    /* VAriables */ 
    double Kc, Ko;
    double StomCond;
    double Idir, AirTemp, rh, Ca, Oa;
    double Vcmax1, Vpmax1, Jmax1;
    double Vcmax, Vpmax, Vpr, Jmax;

    double Q10pr, Q10p, Q10rb, Q10Rd, Q10Kc, Q10Ko;
    double Cm, Om;
    double Rd, Rm, Rs;

    double I2, J, Aj;
    double Vp, Ko1 , Om1;
    double a1, b1, c1 , c3, Ac0;
    double AcLCO2, Ac, A;
    double Os, Cs;
    double Cs0, Cs1;

    double aa, bb, cc;

    SEXP names, lists;
    SEXP Assim;
    SEXP Gs;
    SEXP Ci;
    SEXP Oxy;

    PROTECT(lists = allocVector(VECSXP,4));
    PROTECT(names = allocVector(STRSXP,4));

    PROTECT(Assim = allocVector(REALSXP,nqp));
    PROTECT(Gs = allocVector(REALSXP,nqp));
    PROTECT(Ci = allocVector(REALSXP,nqp));
    PROTECT(Oxy = allocVector(REALSXP,nqp));

    Ca = REAL(CA)[0];
    Oa = REAL(OA)[0];
    Vcmax1 = REAL(VCMAX)[0];
    Vpmax1 = REAL(VPMAX)[0];
    Vpr = REAL(VPR)[0];
    Jmax1 = REAL(JMAX)[0];

    for(i = 0;i < nqp;i++){

    Idir = REAL(QP)[i];
    AirTemp = REAL(TEMP)[i];
    rh = REAL(RH)[i];


    Q10pr = exp(Epr *(1/(R * Kelvin25)-1/(R * (AirTemp + Kelvin0))));
    Q10p = exp(Ep *(1/(R * Kelvin25)-1/(R * (AirTemp + Kelvin0))));
    Q10rb = exp(Erb *(1/(R * Kelvin25)-1/(R * (AirTemp + Kelvin0))));
    Q10Rd = exp(ERd *(1/(R * Kelvin25)-1/(R * (AirTemp + Kelvin0))));
    Q10Kc = exp(EKc *(1/(R * Kelvin25)-1/(R * (AirTemp + Kelvin0))));
    Q10Ko = exp(EKo *(1/(R * Kelvin25)-1/(R * (AirTemp + Kelvin0))));

    Vcmax = Vcmax1 * Q10rb;
    Kc = Kc2 * Q10Kc;
    Ko = Ko2 * Q10Ko;
    Vpmax = Vpmax1 * Q10p;        
    Jmax = Jmax1 * pow(Q10cb,(AirTemp-25)/10);

    Cm = 0.4 * Ca ; 
    Om = Oa ;
        
    /*    Rd = 0.01 * Vcmax; */
    Rd = 0.08;
    Rm = 0.5 * Rd ;
    Rs = 0.5 * Rd;
        
    /* Light limited */
    I2 = (Idir * 0.85)/2;
    J = (Jmax + I2  - sqrt(pow(Jmax+I2,2) - 4 * theta * I2 * Jmax ))/2*theta;        
    /* Long formula for light limited */

    aa = 1 - (7 * gammaStar * alpha )/3 * 0.047;
    bb = -(((0.4 * J)/2 - Rm + gs * Cm) + ((1-0.4)*J/3-Rd) + 
	   gs*(7*gammaStar*Om/3) + 
	   (alpha*gammaStar/0.047)*((1-0.04)*J/3 + 7*Rd/3));
    cc = ((0.4 * J)/2 - Rm + gs * Cm)*((1-0.4)*J/3-Rd) -
      gs * gammaStar * Om *((1-0.4)*J/3 + 7*Rd/3);

    Aj = (-bb - sqrt(pow(bb,2)-4*aa*cc))/2*aa;

    /* Other part */
    Vp = (Cm * Vpmax) / (Cm + Kp) ;
    if(Vpr < Vp){
      Vp = Vpr;
    }
	        
    /* Alternative formula */
    Ko1 = Ko * 1e3;
    Om1 = Om * 1e3;

    a1 = 1 - alpha / 0.047 * Kc/Ko1 ;
    b1 = -((Vp - Rm + gs * Cm)+
	   (Vcmax - Rd)+
	   gs*(Kc*(1+Om1/Ko1))+
	   ((alpha/0.047)*(gammaStar*Vcmax+Rd*Kc/Ko1)));
    c1 = (Vcmax - Rd)*(Vp-Rm+gs*Cm)-
          (Vcmax * gs * gammaStar * Om1 + Rd*gs*Kc*(1+Om1/Ko1));
         
    c3 = pow(b1,2) - 4*a1*c1;
      if(c3 < 0){
	c3 = 0;
      }
    Ac0 = (-b1 - sqrt(c3)) / 2*a1 ;

    AcLCO2 = (Cm * Vpmax/(Cm+Kp)) - Rm + gs * Cm;
    
    if(Ac0 < AcLCO2){
      Ac = Ac0;
    }else{
      Ac = AcLCO2;
    }

    if(Aj < Ac){
      A = Aj;
    }else{
      A = Ac;
    }
        
    Os = alpha * A / 0.047 * gs + Om;

     if(Aj <= Ac){ 
       Cs = Cm + (Vp - Aj - Rm)/gs;
      }else{ 
	  Cs0 = gammaStar * Os + Kc*(1+Os/Ko)*((Ac+Rd)/Vcmax); 
 	  Cs1 = 1 - (Ac+Rd)/Vcmax; 
	  Cs = Cs0/Cs1;
    	   }

    /* Calculating Gs */
     if(A < 0){
       StomCond = G0;
     }else{
       StomCond = G1 * (A * rh * P) / (Cm*1e-1) + G0;
     }
    /* Organizing the results */
    REAL(Assim)[i] = A;
    REAL(Gs)[i] = StomCond;
    REAL(Ci)[i] = Cs;
    REAL(Oxy)[i] = Os;
    }

    SET_VECTOR_ELT(lists,0,Assim);
    SET_VECTOR_ELT(lists,1,Gs);
    SET_VECTOR_ELT(lists,2,Ci);
    SET_VECTOR_ELT(lists,3,Oxy);

    SET_STRING_ELT(names,0,mkChar("Assim"));
    SET_STRING_ELT(names,1,mkChar("Gs"));
    SET_STRING_ELT(names,2,mkChar("Ci"));
    SET_STRING_ELT(names,3,mkChar("Oxy"));
    setAttrib(lists,R_NamesSymbol,names);
    UNPROTECT(6);
    return(lists);
}


/* In this section the McMCec4photo is included this is a work in 
progress!*/

double RsqeC4photo(double oAssim[enObs], double oQp[enObs], 
		  double oTemp[enObs],  double oRH[enObs],
		  double Ca, double Oa,  double Vcmax,
		  double Vpmax, double Vpr, double Jmax );

SEXP McMCEc4photo(SEXP oASSIM, SEXP oQP, SEXP oTEMP,
		  SEXP oRelH, SEXP NITER, SEXP iCA,
		  SEXP iOA,  SEXP iVCMAX,  SEXP iVPMAX,
		  SEXP iJMAX,  SEXP THRESH, SEXP SCALE){
  /* First manipulate R objects */
  int niter;
  enObs = length(oASSIM);
  niter = INTEGER(NITER)[0];

  /* Second define the needed variables */
  double oldRsq = 0.5;
  int n1 = 0;
  int n2 = 0;
  int n3 = 0;
  int iters = 0;
  int i, k;
  double crit = 1 ;
  double thresh = REAL(THRESH)[0];
  double scale = REAL(SCALE)[0];
  double sd1, sd2, sd3;

  double index;
  double rlnum , rlden;
  double ratio;
  double U;

  double Rsq;
  double poldRsq;
  double Ca, Oa;
  double  poldVcmax, poldVpmax, poldVpr, poldJmax;
  double rnewVcmax, rnewVpmax, rnewVpr, rnewJmax;
  double  oldVcmax, oldVpmax, oldVpr, oldJmax;

  double assim[enObs], qp[enObs];
  double  temp[enObs], rh[enObs];

  for(k = 0; k < enObs; k++){
     assim[k] = REAL(oASSIM)[k];
     qp[k] = REAL(oQP)[k];
     temp[k] = REAL(oTEMP)[k];
     rh[k] = REAL(oRelH)[k];
  }

  SEXP lists;
  SEXP names;

  SEXP mat1;
  SEXP mat2;

  SEXP accept1;
  SEXP accept2;
  SEXP accept3;

  SEXP RsqBI;
  SEXP CoefBI;

  PROTECT(lists = allocVector(VECSXP,7));
  PROTECT(names = allocVector(STRSXP,7));

  PROTECT(mat1 = allocMatrix(REALSXP,4,niter));
  PROTECT(mat2 = allocMatrix(REALSXP,4,niter));

  PROTECT(accept1 = allocVector(REALSXP,1));
  PROTECT(accept2 = allocVector(REALSXP,1));
  PROTECT(accept3 = allocVector(REALSXP,1));

  PROTECT(RsqBI = allocVector(REALSXP,1));
  PROTECT(CoefBI = allocVector(REALSXP,3));

  GetRNGstate();

  Ca = REAL(iCA)[0];
  Oa = REAL(iOA)[0];
  oldVcmax = REAL(iVCMAX)[0];
  oldVpmax = REAL(iVPMAX)[0];
  oldVpr   = 80;
  /* Vpr is not optimized */
  oldJmax = REAL(iJMAX)[0];
  sd1 = 0.05 * oldVcmax * scale;
  sd2 = 0.05 * oldVpmax * scale;
  sd3 = 0.05 * oldJmax * scale;
 
   while((iters < niter) && (crit > thresh)){ 
     iters++;
     /* Replacing the rnormCV */
     index = floor(runif(1,4)); 

       rnewVcmax = oldVcmax;
       rnewVpmax = oldVpmax;
       rnewVpr = oldVpr;
       rnewJmax = oldJmax;

     if(index == 1){ 
       rnewVcmax = oldVcmax + rnorm(0,sd1);
     }
     if(index == 2){ 
       rnewVpmax = oldVpmax  + rnorm(0,sd2);
     }
     /*     if(index == 3){ 
       rnewVpr = oldVpr + rnorm(0,0.8);
       } */ 
     if(index == 3){ 
       rnewJmax = oldJmax + rnorm(0,sd3);
     }  

     /* Finish of the rnormCV function */
      Rsq = RsqeC4photo(assim,qp,temp,rh,Ca,Oa,
		       rnewVcmax,rnewVpmax,rnewVpr,
		       rnewJmax);

      if(Rsq > oldRsq){
	oldRsq = Rsq;
	oldVcmax = rnewVcmax;
	oldVpmax = rnewVpmax;
	oldVpr = rnewVpr;
	oldJmax = rnewJmax;
	REAL(mat1)[n1*4] = oldVcmax;
	REAL(mat1)[1 + n1*4] = oldVpmax;
	/*	REAL(mat1)[2 + n1*5] = oldVpr;*/
	REAL(mat1)[2 + n1*4] = oldJmax;
	REAL(mat1)[3 + n1*4] = oldRsq;
	crit = (1 - Rsq)/Rsq;
	n1++;
      }
     }

    poldRsq = oldRsq;
    poldVcmax = oldVcmax;
    poldVpmax = oldVpmax;
    poldVpr = oldVpr;
    poldJmax = oldJmax;

    for(i = 0; i < niter; i++){

      /* Replacing the rnormC4 function */
     index = floor(runif(1,4)); 

       rnewVcmax = oldVcmax;
       rnewVpmax = oldVpmax;
       rnewVpr = oldVpr;
       rnewJmax = oldJmax;

     if(index == 1){ 
       rnewVcmax = oldVcmax + rnorm(0,sd1);
     }
     if(index == 2){ 
       rnewVpmax = oldVpmax  + rnorm(0,sd2);
     }
     /*     if(index == 3){ 
       rnewVpr = oldVpr + rnorm(0,0.8);
     }  */
     if(index == 3){ 
       rnewJmax = oldJmax + rnorm(0,sd3);
     }  
      /* This is the end of the random generation */

      Rsq = RsqeC4photo(assim,qp,temp,rh,Ca,Oa,
		       rnewVcmax,rnewVpmax,rnewVpr,
		       rnewJmax);

        if(Rsq > poldRsq){
	  /* This time I'm suming to avoid overflow */
	  /* So I've taken the log */
	  rlnum = dnorm(rnewVcmax,oldVcmax,sd1,0) +
	          dnorm(rnewVpmax,oldVpmax,sd2,0) +
	    /*          dnorm(rnewVpr,oldVpr,1.2,0) +*/
	          dnorm(rnewJmax,oldJmax,sd3,0);

	  rlden = dnorm(oldVcmax,oldVcmax,sd1,0) +
	          dnorm(oldVpmax,oldVpmax,sd2,0) +
	    /*	          dnorm(oldVpr,oldVpr,1.2,0) +*/
	          dnorm(oldJmax,oldJmax,sd3,0);
	  
	  /* This is in the log scale */
	  ratio = (rlnum - rlden);

	  U = runif(0,1);
	  if(ratio > log(U)){
	    oldVcmax = rnewVcmax;
	    oldVpmax = rnewVpmax;
	    oldVpr = rnewVpr;
	    oldJmax = rnewJmax;
	    n3++;
	  }
	  REAL(mat2)[n2*4] = rnewVcmax;
	  REAL(mat2)[n2*4 + 1] = rnewVpmax;
	  /*	  REAL(mat2)[n2*4 + 2] = rnewVpr; */
	  REAL(mat2)[n2*4 + 2] = rnewJmax;
	  REAL(mat2)[n2*4 + 3] = Rsq;
	  n2++;
	}
     
    }

    REAL(accept1)[0] = n1;
    REAL(accept2)[0] = n2;
    REAL(accept3)[0] = n3;
    REAL(RsqBI)[0] = poldRsq;
    REAL(CoefBI)[0] = poldVcmax;
    REAL(CoefBI)[1] = poldVpmax;
    /*    REAL(CoefBI)[2] = poldVpr;*/
    REAL(CoefBI)[2] = poldJmax;


    SET_VECTOR_ELT(lists,0,RsqBI);
    SET_VECTOR_ELT(lists,1,CoefBI);
    SET_VECTOR_ELT(lists,2,accept1);
    SET_VECTOR_ELT(lists,3,mat1);
    SET_VECTOR_ELT(lists,4,mat2);
    SET_VECTOR_ELT(lists,5,accept2);
    SET_VECTOR_ELT(lists,6,accept3);

    SET_STRING_ELT(names,0,mkChar("RsqBI"));
    SET_STRING_ELT(names,1,mkChar("CoefBI"));
    SET_STRING_ELT(names,2,mkChar("accept1"));
    SET_STRING_ELT(names,3,mkChar("resuBI"));
    SET_STRING_ELT(names,4,mkChar("resuMC"));
    SET_STRING_ELT(names,5,mkChar("accept2"));
    SET_STRING_ELT(names,6,mkChar("accept3"));
    setAttrib(lists,R_NamesSymbol,names);
    UNPROTECT(9);
    PutRNGstate();
    return(lists);
}

/* Calculates R-sq according to the Collatz model */
/* and given values for the two most important */
/* parameters Vcmax and alpha */
double RsqeC4photo(double oAssim[enObs], double oQp[enObs], 
		  double oTemp[enObs],  double oRH[enObs],
		  double COa, double O2a,  double Vcmax,
		  double Vpmax, double Vpr, double Jmax ){

  double vec1[enObs];
  int i, j;
  double SST = 0.0, SSE = 0.0, diff;
  double Rsquare = 0.0;

  for(i = 0;i < enObs; i++){

    vec1[i] = eC4photoC(oQp[i],oTemp[i],
		       oRH[i],COa,O2a,Vcmax,Vpmax,
		       Vpr,Jmax);
  }
   
  for(j = 0 ; j < enObs; j++){
    SST += pow(oAssim[j],2);
    diff = oAssim[j] - vec1[j];
    SSE += pow(diff,2);
  }

  Rsquare = (SST - SSE)/SST ; 
  return(Rsquare);
}
