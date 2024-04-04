C CPP options file for SLR_CORR package
C Use this file for selecting options within the SLR_CORR package

#ifndef SLR_CORR_OPTIONS_H
#define SLR_CORR_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_SLR_CORR

C balance sea level rise (each time step by default)
#define ALLOW_SLR_CORR_BALANCE

CC When adjusting GMSL, only adjust precipitation
CC where precipitation is positive
C#define MODIDY_POSITIVE_PRECIP_ONLY
 
C Instead of using a spatially-invariant precipitation
C adjustment, apply a scaling factor to precipitation
#define SCALE_PRECIP_TO_ADJUST

#endif /* ALLOW_SLR_CORR */
#endif /* ALLOW_SLR_OPTIONS_H */

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
