/* $Id$  */
/*--------------------------------------------------------------------*/
/*;  Copyright (C) 2005-2010                                          */
/*;  Associated Universities, Inc. Washington DC, USA.                */
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
/*;         Internet email: bcotton@nrao.edu.                         */
/*;         Postal address: William Cotton                            */
/*;                         National Radio Astronomy Observatory      */
/*;                         520 Edgemont Road                         */
/*;                         Charlottesville, VA 22903-2475 USA        */
/*--------------------------------------------------------------------*/
/*  Define the basic components of the ObitUVImager ClassInfo structure */
/* This is intended to be included in a classInfo structure definition  */
#include "ObitClassDef.h"  /* Parent class ClassInfo definition file */
/** Function pointer to Constructor from ObitInfo. */
ObitUVImagerFromInfoFP ObitUVImagerFromInfo;
/** Function pointer to Constructor. */
ObitUVImagerCreateFP ObitUVImagerCreate;
/** Function pointer to Constructor.given mosaic  */
ObitUVImagerCreate2FP ObitUVImagerCreate2;
/** Function pointer to Weight function. */
ObitUVImagerWeightFP ObitUVImagerWeight;
/** Function pointer to Image function. */
ObitUVImagerImageFP ObitUVImagerImage;
/** Function pointer to 2D Shift function. */
ObitUVImagerShiftyFP ObitUVImagerShifty;
/** Function pointer to Flatten function. */
ObitUVImagerFlattenFP ObitUVImagerFlatten;
/** Function pointer to get ImageMosaic function. */
ObitUVImagerGetMosaicFP ObitUVImagerGetMosaic;
/** Function pointer to Extract information about underlying structures 
    to ObitInfoList. */
ObitUVImagerGetInfoFP ObitUVImagerGetInfo;
/** Function pointer to get number or parallel images function. */
ObitUVImagerGetNumParFP ObitUVImagerGetNumPar;
