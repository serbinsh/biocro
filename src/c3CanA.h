/*
 *  BioCro/src/c3CanA.c by Fernando Ezequiel Miguez  Copyright (C) 2010
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


/* EvapoTrans function */
struct ET_Str c3EvapoTrans(double Rad, 
			   double Itot, 
			   double Airtemperature, 
			   double RH,
			   double WindSpeed,
			   double LeafAreaIndex, 
			   double CanopyHeight, 
			   double vcmax2, 
			   double jmax2, 
			   double Rd2, 
			   double b02, 
			   double b12,
			   double Catm2,
			   double O2,
			   double theta2);
