C------------------------------------------------------------------------------|
C                           SLR_CORR_FIELDS.h
C------------------------------------------------------------------------------|

#ifdef ALLOW_SLR_CORR

#include "SLR_CORR_SIZE.h"

CBOP
C     !ROUTINE: SLRC_CORR.h
C     !INTERFACE:
C     #include "SLR_CORR.h"

C     !DESCRIPTION:
C     *==========================================================*
C     | SLR_CORR_FIELDS.h
C     | o Header file containing fields to provide adjustments
C     |   to the precip field to balance EtaN online
C     *==========================================================*
CEOP


C------------------------------------------------------------------------------|
C     Create COMMON blocks for the diagnostics_vec variables
C------------------------------------------------------------------------------|

      COMMON /SLR_CORR_FIELDS_R/
     & slrc_obs_timeseries, slr_average_etans,
     & volumes_above_zero
      _RL slrc_obs_timeseries(slrc_n_obs)
      _RL slr_average_etans(slrc_max_average_recs)
      _RL volumes_above_zero(slrc_est_order+1)
#endif /* ALLOW_SLR_CORR */
