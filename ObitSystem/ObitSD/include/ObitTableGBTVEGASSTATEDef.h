/* $Id$  */
/* DO NOT EDIT - file generated by ObitSDTables.pl                    */
/*--------------------------------------------------------------------*/
/*;  Copyright (C)  2013                                              */
/*;  Associated Universities, Inc. Washington DC, USA.                */
/*;                                                                   */
/*;  This program is free software; you can redistribute it and/or    */
/*;  modify it under the terms of the GNU General Public License as   */
/*;  published by the Free Software Foundation; either version 2 of   */
/*;  the License, or (at your option) any later version.              */
/*;                                                                   */
/*;  This program is distributed in the hope that it will be useful,  */
/*;  but WITHOUT ANY WARRANTY; without even the implied warranty of   */
/*;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    */
/*;  GNU General Public License for more details.                     */
/*;                                                                   */
/*;  You should have received a copy of the GNU General Public        */
/*;  License along with this program; if not, write to the Free       */
/*;  Software Foundation, Inc., 675 Massachusetts Ave, Cambridge,     */
/*;  MA 02139, USA.                                                   */
/*;                                                                   */
/*;Correspondence about this software should be addressed as follows: */
/*;         Internet email: bcotton@nrao.edu.                        */
/*;         Postal address: William Cotton                            */
/*;                         National Radio Astronomy Observatory      */
/*;                         520 Edgemont Road                         */
/*;                         Charlottesville, VA 22903-2475 USA        */
/*--------------------------------------------------------------------*/
/*  Define the basic components of the ObitTableGBTVEGASSTATE  structure          */
/*  This is intended to be included in a class structure definition   */
/**
 * \file ObitTableGBTVEGASSTATEDef.h
 * ObitTableGBTVEGASSTATE structure members for derived classes.
 */
#include "ObitTableDef.h"  /* Parent class definitions */
/** Number of phases if only internal switching sig */
oint  numphase;
/** witching period */
ofloat  swperiod;
/** Switching Signals Master */
gchar  master[MAXKEYCHARTABLESTATE];
/** Column offset for blanking time in table record */
olong  blanktimOff;
/** Physical column number for blanking time in table record */
olong  blanktimCol;
/** Column offset for Phase of start of state(?) in table record */
olong  phsestrtOff;
/** Physical column number for Phase of start of state(?) in table record */
olong  phsestrtCol;
/** Column offset for signal or ref (logical) in table record */
olong  sigrefOff;
/** Physical column number for signal or ref (logical) in table record */
olong  sigrefCol;
/** Column offset for cal on/off (logical) in table record */
olong  calOff;
/** Physical column number for cal on/off (logical) in table record */
olong  calCol;
