/*
 *  /src/c3photo.c by Fernando Ezequiel Miguez  Copyright (C) 2009
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
#include "c3photo.h"

SEXP c3photo(SEXP Qp1, SEXP Tl1, SEXP RH1, SEXP VCMAX, SEXP JMAX,
	     SEXP RD, SEXP CA, SEXP B0, SEXP B1, SEXP OX2, SEXP THETA)
{
	struct c3_str tmp;

	double Qp, Tl, RH, Catm;
	double Bet0,Bet1;

	double vcmax, jmax, Rd, Ca, O2, theta;

	vcmax = REAL(VCMAX)[0];
	jmax = REAL(JMAX)[0];
	Bet0 = REAL(B0)[0];
	Bet1 = REAL(B1)[0];
	Rd = REAL(RD)[0];
	O2 = REAL(OX2)[0];
	theta = REAL(THETA)[0];

	int nq , nt, nr, i;

	SEXP lists, names;
	SEXP GsV;
	SEXP ASSV;
	SEXP CiV;

	nq = length(Qp1);nt = length(Tl1);nr = length(RH1);

	PROTECT(lists = allocVector(VECSXP,3));
	PROTECT(names = allocVector(STRSXP,3));

	PROTECT(GsV = allocVector(REALSXP,nq));
	PROTECT(ASSV = allocVector(REALSXP,nq));
	PROTECT(CiV = allocVector(REALSXP,nq));

	Ca = REAL(CA)[0]; /* partial pressure of CO2 at the leaf surface */
 
	/* Start of the loop */
	for(i = 0; i < nq ; i++)
	{
		/*pick the right element*/
		Qp = REAL(Qp1)[i];
		Tl = REAL(Tl1)[i];
		RH = REAL(RH1)[i];
		Catm = REAL(CA)[i];

		tmp = c3photoC(Qp, Tl, RH, vcmax, jmax, Rd, Bet0, Bet1, Catm, O2, theta);

		REAL(GsV)[i] = tmp.Gs;
		REAL(ASSV)[i] = tmp.Assim;    
		REAL(CiV)[i] = tmp.Ci;
	}

	SET_VECTOR_ELT(lists,0,GsV);
	SET_VECTOR_ELT(lists,1,ASSV);
	SET_VECTOR_ELT(lists,2,CiV);
	SET_STRING_ELT(names,0,mkChar("Gs"));
	SET_STRING_ELT(names,1,mkChar("Assim"));
	SET_STRING_ELT(names,2,mkChar("Ci"));
	setAttrib(lists,R_NamesSymbol,names);
	UNPROTECT(5);   
	return(lists);
}



/* Solubility of CO2 and O2 */

/* This function returns the solubility of CO2 at temperature t relative to CO2 */
/* solubility at 25C it does this by using a polynomial which has been fitted to */
/* experimental data. */

/* Function result units: micro mol mol^-1 */
/* Function found: */
/* Plant cell and Environment, (1991) 14, 729-739. */
/* Modification of the response of photosynthetic activity to */
/* rising temperature by atmospheric CO2 concentrations: Has its */
/* importance been underestimated? */

double solc(double LeafT){

	double tmp;

	if(LeafT > 24 && LeafT < 26){
		tmp = 1;
	}else{
		tmp = (1.673998 - 0.0612936 * LeafT + 0.00116875 * pow(LeafT,2) - 8.874081e-06 * pow(LeafT,3)) / 0.735465;
	}

	return(tmp);
}

double solo(double LeafT){

	double tmp;

	if(LeafT > 24 && LeafT < 26){
		tmp = 1;
	}else{
		tmp = (0.047 - 0.0013087 * LeafT + 2.5603e-05 * pow(LeafT,2) - 2.1441e-07 * pow(LeafT,3)) / 0.026934;
	}

	return(tmp);
}



/* c4photo function */ 
struct c3_str c3photoC(double Qp, double Tleaf, double RH, double Vcmax0, double Jmax, 
		       double Rd0, double bb0, double bb1, double Ca, double O2, double thet)
{

	struct c3_str tmp;
	/* Constants */
	const double AP = 101325; /*Atmospheric pressure According to wikipedia (Pa)*/
	const double R = 0.008314472; /* Gas constant */
	const double Spectral_Imbalance = 0.25;
	const double Leaf_Reflectance = 0.2;
	const double Rate_TPu = 23;
	/* Defining biochemical variables */


	double Ci = 0.0, Oi;
	double Kc, Ko, Gstar;
	double Vc = 0.0;
	double Vcmax, Rd;
	double Ac1, Ac2, Ac;
	double Aj1, Aj2, Aj;
	double Ap;
	double Assim, J, I2;
	double FEII;
	double theta;
	double Citr1, Citr2, Citr;

	int iterCounter = 0;
	double Gs ;
	double diff, OldCi = 0.0, Tol = 0.5;

	if(Ca <= 0)
		Ca = 1e-4;

	/* From Dubois from Bernacchi. Improved temperature response functions. */
	Kc = exp(38.05-79.43/(R*(Tleaf+273.15))); 
	Ko = exp(20.30-36.38/(R*(Tleaf+273.15))); 
	Gstar = exp(19.02-37.83/(R*(Tleaf+273.15))); 

	Vcmax = Vcmax0 * exp(26.35 - 65.33/(R * (Tleaf+273.15)));
	Rd = Rd0 * exp(18.72 - 46.39/(R * (Tleaf+273.15)));

        /* Effect of temperature on theta */
	theta = thet + 0.018 * Tleaf - 3.7e-4 * pow(Tleaf,2);

	/* Rprintf("Vcmax, %.1f, Rd %.1f, Gstar %.1f, theta %.1f \n",Vcmax,Rd,Gstar,theta); */

	/* Light limited */
	I2 = Qp * (1 - Spectral_Imbalance) * (1 - Leaf_Reflectance)/2;
	FEII = 0.352 + 0.022 * Tleaf - 3.4 * pow(Tleaf,2) / 10000;
	I2 = Qp * FEII * (1 - Leaf_Reflectance) / 2;

	J = (Jmax + I2  - sqrt(pow(Jmax+I2,2) - 4 * theta * I2 * Jmax ))/2*theta; 

	/* Rprintf("I2, %.1f, FEII %.1f, J %.1f \n",I2,FEII,J); */

	Citr1 = Kc * J * (Ko + O2) - 8*Ko*Gstar*Vcmax;
	Citr2 = Ko * (4 * Vcmax - J);
	Citr = Citr1 / Citr2;

	OldCi = Ca * solc(Tleaf) * 0.7; /* Initial guesstimate */
	Oi = O2 * solo(Tleaf);

	while(iterCounter < 20)
	  {

		  /* Rubisco limited carboxylation */
		  Ac1 =  Vcmax * (Ci - Gstar) ;
		  Ac2 = Ci + Kc * (1 + Oi/Ko);
		  Ac = Ac1/Ac2;


		  /* Light lmited portion */ 
		  Aj1 = J * (Ci - Gstar) ;
		  Aj2 = 4.5*Ci + 10.5*Gstar ;
		  Aj = Aj1/Aj2;

		  /* Limited by tri phos utilization */
		  Ap = (3 * Rate_TPu) / (1 - Gstar / Ci);


		  if(Ac < Aj && Ac < Ap){
			  Vc = Ac;
		  }else
			  if(Aj < Ac && Aj < Ap){
				  Vc = Aj;
			  }else
				  if(Ap < Ac && Ap < Aj){
					  if(Ap < 0) Ap = 0;
					  Vc = Ap;
				  }

		  Assim = Vc - Rd; /* micro mol m^-2 s^-1 */

		  /* milimole per meter square per second*/
		  Gs =  ballBerry(Assim,Ca, Tleaf, RH, bb0, bb1);
		  
		  if( Gs <= 0 )
			  Gs = 1e-5;

		  if(Gs > 800)
			  Gs = 800;

		  Ci = Ca - (Assim * 1e-6 * 1.6 * AP) / (Gs * 0.001);
		  /*Ci = Ca - (Assim * 1.6 * 100) / Gs ; Harley pg 272 eqn 10. PCE 1992 */

		  if(Ci < 0)
			  Ci = 1e-5;

		  diff = OldCi - Ci;
		  if(diff < 0) diff = -diff;
		  if(diff < Tol){
			  break;
		  }else{
			  OldCi = Ci;
		  }
		  
		  iterCounter++;
		  
	  }

	tmp.Assim = Assim;
	tmp.Gs = Gs;
	tmp.Ci = Ci;
	return(tmp);
}


/* Calculate Quantum Yield */

/* double quant_yield(double sp_im, double leaf_ref, double leaf_fna, */




