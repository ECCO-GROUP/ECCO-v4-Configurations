C------------------------------------------------------------------------------|
C                           SLR_CORR_PARAM.h
C------------------------------------------------------------------------------|

#ifdef ALLOW_SLR_CORR

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
C     Define the global slr_corr variables
C------------------------------------------------------------------------------|

C     These are the dates that correspond to the input file
      INTEGER slrc_obs_startdate_1
      INTEGER slrc_obs_startdate_2

C     This is the interval between obs in the input file
      _RL slrc_obs_period

C     This is the time interval over which the running average is computed
      _RL slrc_balancePeriod
      _RL slrc_obs_start_time

C     This is the precip adjustment, updated at each time step
      _RL slrc_precip_adjustment

C     This is the scaling factor to adjust precip, updated at each time step
      _RL slrc_precip_adjustment_fac

C     This is the reference to be added to obs to account for bias btw obs and md 
      _RL slrc_obs_ref

C     These are some i/o parameters
      INTEGER slrc_filePrec

C     Input file names
      CHARACTER*(128) slrc_obs_filename
      CHARACTER*(128) slrc_output_filename

C------------------------------------------------------------------------------|
C     Create COMMON blocks for the slr_corr variables
C------------------------------------------------------------------------------|

      COMMON /SLR_CORR_PARAM_I/
     & slrc_obs_startdate_1,
     & slrc_obs_startdate_2,
     & slrc_filePrec

      COMMON /SLR_CORR_PARAM_C/
     & slrc_obs_filename,
     & slrc_output_filename

      COMMON /SLR_CORR_PARAM_R/
     & slrc_obs_period,
     & slrc_balancePeriod,
     & slrc_obs_start_time,
     & slrc_precip_adjustment,
     & slrc_obs_ref

      COMMON /SLR_CORR_PARAM_R2/
     & slrc_precip_adjustment_fac
#endif /* ALLOW_SLR_CORR */
