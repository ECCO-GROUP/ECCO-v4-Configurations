C----&------------------------------------------------------------------xxxxxxx|
C                           slr_corr_adjust_precip
C----&------------------------------------------------------------------xxxxxxx|

#include "SLR_CORR_OPTIONS.h"
#include "EXF_OPTIONS.h"
#include "ECCO_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: SLR_CORR_ADJUST_PRECIP

C !INTERFACE:
      SUBROUTINE SLR_CORR_ADJUST_PRECIP( myTime, myIter, myThid,
     &                                   precipArr)

C     !DESCRIPTION:
C     Initialize SLR_CORR parameters and constants.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "EXF_FIELDS.h"
#include "ECCO_SIZE.h"
#include "ECCO.h"

#include "SLR_CORR_PARAM.h"
#include "SLR_CORR_FIELDS.h"

C     !INPUT PARAMETERS:
      _RL     myTime
      INTEGER myIter
      INTEGER myThid
      _RL precipArr(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit
      INTEGER, PARAMETER :: debug = 1
      INTEGER n_average_points
      _RL max_obs_time
      _RL mean_SSH_target
      INTEGER valid_pts
      INTEGER count0, count1
      INTEGER i, j, bi, bj, n
      INTEGER kSrf
      _RL volume_above_zero_target
      _RL volume_above_zero
      _RL volume_above_zero_difference
      _RL precip_volume_flux
      _RL evap_volume_flux
      _RL wet_area, corr_area
#ifdef SCALE_PRECIP_TO_ADJUST
      _RL precip_volume_flux_pos
      _RL precip_adjustment_fac
#endif
      _RL next_volume_above_zero
      _RL precip_adjustment
      _RL alpha

CEOP
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOC

#ifdef ALLOW_SLR_CORR

C----&------------------------------------------------------------------xxxxxxx|
C     Define the slr_corr variables
C----&------------------------------------------------------------------xxxxxxx|
    
      if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN SLR_CORR_ADJUST_PRECIP DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

      _BEGIN_MASTER(myThid)

C----&------------------------------------------------------------------xxxxxxx|
C   Calculate the mean SSH target from provided observations
C----&------------------------------------------------------------------xxxxxxx|

C     First get the lower and upper bound steps in the obs
C     timeseries
      max_obs_time = slrc_obs_period*slrc_n_obs
      count0=1
      count1=slrc_n_obs
      DO i=1,slrc_n_obs
         if (
     &   ((myTime+deltaT) .ge. 
     &     slrc_obs_start_time+(i-1)*slrc_obs_period)
     &   .and.(i.ge.count0)) then
         count0 = i
         endif
      ENDDO
      count1 = count0 +1

C     Now, interpolate to get the target SSH
C     This is the target SSH to adjust the precip toward
      alpha = (myTime+deltaT
     &       -(slrc_obs_start_time+(count0-1)*slrc_obs_period))
     &       /  (slrc_obs_period)
      mean_SSH_target = (1-alpha) * slrc_obs_timeseries(count0) 
     &                   + alpha * slrc_obs_timeseries(count1)
     &                  + slrc_obs_ref

C      PRINT *, 'slrc_obs_timeseries',slrc_obs_timeseries
C      PRINT *, 'myTime', myTime
C      PRINT *, 'lTime',slrc_obs_start_time+(count0-1)*slrc_obs_period
C      PRINT *, 'uTime',slrc_obs_start_time+(count1-1)*slrc_obs_period
C      PRINT *, 'count0',count0
C      PRINT *, 'count1',count1
C      PRINT *, 'alpha', alpha
C      PRINT *, 'lSSH',slrc_obs_timeseries(count0)
C      PRINT *, 'uSSH',slrc_obs_timeseries(count1)
C      PRINT *, 'mean_SSH_target',mean_SSH_target

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A,I10)') "  myIter ", myIter
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3)') "  myTime ", myTime
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,I5)') "  count0 ", count0
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,I5)') "  count1 ", count1
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3)') "  alpha ", alpha
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3)') "  mean_SSH_target ", mean_SSH_target
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C----&------------------------------------------------------------------xxxxxxx|
C     Calculate the volume flux deficit/excess
C----&------------------------------------------------------------------xxxxxxx|

      volume_above_zero = 0.0
      precip_volume_flux = 0.0
      evap_volume_flux = 0.0
      wet_area = 0.0
      corr_area = 0.0
#ifdef SCALE_PRECIP_TO_ADJUST
      precip_volume_flux_pos = 0.0
#endif

      IF ( fluidIsAir ) THEN
       kSrf = 0
      ELSEIF ( usingPCoords ) THEN
       kSrf = Nr
      ELSE
       kSrf = 1
      ENDIF

      DO bi=1,nSx
      DO bj=1,nSy
      DO i=1,sNx
      DO j=1,sNy
            volume_above_zero = volume_above_zero
#ifdef ALLOW_ECCO
#if (defined ATMOSPHERIC_LOADING && defined ALLOW_IB_CORR)
     &       + m_eta_dyn(i,j,bi,bj)
#else
     &       + m_eta(i,j,bi,bj)
#endif
#else
     &       + EtaN(i,j,bi,bj)
#endif
     &       * rA(i,j,bi,bj) * maskC(i,j,kSrf,bi,bj)
            precip_volume_flux = precip_volume_flux
     &       + precip(i,j,bi,bj) * rA(i,j,bi,bj) * maskC(i,j,kSrf,bi,bj)
            evap_volume_flux = evap_volume_flux
     &       + evap(i,j,bi,bj) * rA(i,j,bi,bj) * maskC(i,j,kSrf,bi,bj)
            wet_area = wet_area + rA(i,j,bi,bj) * maskC(i,j,kSrf,bi,bj)
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
            IF(precip(i,j,bi,bj).GT.0. _d 0)THEN
             corr_area = corr_area + rA(i,j,bi,bj)*maskC(i,j,kSrf,bi,bj)
            ENDIF
#endif
#ifdef SCALE_PRECIP_TO_ADJUST
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
            IF(precip(i,j,bi,bj).GT.0. _d 0)THEN
             precip_volume_flux_pos = precip_volume_flux_pos
     &        + precip(i,j,bi,bj) * rA(i,j,bi,bj)*maskC(i,j,kSrf,bi,bj)
            ENDIF
#endif
#endif

      ENDDO 
      ENDDO
      ENDDO
      ENDDO

      _GLOBAL_SUM_RL( volume_above_zero, mythid )
      _GLOBAL_SUM_RL( precip_volume_flux, mythid )
      _GLOBAL_SUM_RL( evap_volume_flux, mythid )
      _GLOBAL_SUM_RL( wet_area, mythid )
      _GLOBAL_SUM_RL( corr_area, mythid )
#ifdef SCALE_PRECIP_TO_ADJUST
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
      _GLOBAL_SUM_RL( precip_volume_flux_pos, mythid )
#endif
#endif

      volume_above_zero_target = mean_SSH_target*wet_area

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A,F20.3,A)') "  volume_above_zero",
     &                          volume_above_zero, " m^3"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3,A)') "  volume_above_zero_target",
     &                          volume_above_zero_target, " m^3"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3,A)') "  precip_volume_flux",
     &                          precip_volume_flux, " m^3/s"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
#ifdef SCALE_PRECIP_TO_ADJUST
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
      WRITE(msgBuf,'(A,F20.3,A)') "  precip_volume_flux_pos",
     &                          precip_volume_flux_pos, " m^3/s"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
#endif
#endif
      WRITE(msgBuf,'(A,F20.3,A)') "  evap_volume_flux",
     &                          evap_volume_flux, " m^3/s"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3,A)') "  wet_area",
     &                          wet_area, " m^2"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3,A)') "  corr_area",
     &                          corr_area, " m^2"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C----&------------------------------------------------------------------xxxxxxx|
C     Estimate what the next volume above 0 will be
C----&------------------------------------------------------------------xxxxxxx|

C     Deactivated this section for now
C     This idea is to estimate the next target volume based on the 
C     past few values
C     This code could be used for improvements later

C     Here, we will estimate V at the next timestep (V(i+1))
C     based on the current timestep (V(i))
C     i.e. V(i+1) = V(i) + dV/dt(i) * deltaT
C     dV/dt can be calculated with a backward difference or higher 
C     order versions of this 
C     the variable slrc_est_order is used to set the order of the approximation
C     the default is set to 2 in SLR_CORR_SIZE (linear approximation)

C      DO n=1,slrc_est_order
C      volumes_above_zero(n+1) = volumes_above_zero(n)
C      ENDDO
C      volumes_above_zero(1) = volume_above_zero

C      IF (myIter.eq.nIter0) then
C      DO n=1,slrc_est_order
C      volumes_above_zero(n+1) = volume_above_zero
C      ENDDO
C      ENDIF

C     Linear approximation (backwards difference)
C      next_volume_above_zero = volume_above_zero
C     & + volumes_above_zero(1)-volumes_above_zero(2)

C      PRINT *, 'next_volume_above_zero',next_volume_above_zero
C      PRINT *, 'volumes_above_zero(1)',volumes_above_zero(1)
C      PRINT *, 'volumes_above_zero(2)',volumes_above_zero(2)
C      PRINT *, 'next/current',next_volume_above_zero/volume_above_zero

C----&------------------------------------------------------------------xxxxxxx|
C     Calculate the precip adjustment
C----&------------------------------------------------------------------xxxxxxx|

C     Calculate the precip adjustment (m3/s)
      precip_adjustment = 
     & (volume_above_zero_target-volume_above_zero)/deltaT
C     & - precip_volume_flux + evap_volume_flux

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A,E20.3,A)') "  precip_adjustment", 
     &                          precip_adjustment, " m^3/s"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

C     Convert precip adjustment to a mean per area cell
C     Total area (denominator) is wet_area by default and corr_area if
C     MODIDY_POSITIVE_PRECIP_ONLY is defined in EXF_OPTIONS.h
#ifdef SCALE_PRECIP_TO_ADJUST
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
      precip_adjustment_fac = precip_adjustment/precip_volume_flux_pos
#else
      precip_adjustment_fac = precip_adjustment/precip_volume_flux
#endif
#else
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
      precip_adjustment = precip_adjustment/corr_area
#else
      precip_adjustment = precip_adjustment/wet_area
#endif
#endif

#ifdef SCALE_PRECIP_TO_ADJUST
      slrc_precip_adjustment_fac = precip_adjustment_fac
#else
      slrc_precip_adjustment = precip_adjustment
#endif

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A,E20.3,A)') "  precip_adjustment", 
     &                          precip_adjustment, " m/s"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3,A)') "  deltaT", 
     &                          deltaT, " s"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
#ifdef SCALE_PRECIP_TO_ADJUST
      WRITE(msgBuf,'(A,F20.3,A)') "  precip_adjustment_fac",
     &                          precip_adjustment_fac, " nondim"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F20.3,A)') "  slrc_precip_adjustment_fac",
     &                          slrc_precip_adjustment_fac, " nondim"
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
#endif
      endif

C----&------------------------------------------------------------------xxxxxxx|
C     Apply the precip adjustment to the precip grid
C----&------------------------------------------------------------------xxxxxxx|

C      print *,'slrc_precip_adjustment',slrc_precip_adjustment

      DO bi=1,nSx
      DO bj=1,nSy
      DO i=1,sNx
      DO j=1,sNy
#ifdef SCALE_PRECIP_TO_ADJUST
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
           IF(precip(i,j,bi,bj).GT.0. _d 0)THEN
#endif
            precipArr(i,j,bi,bj) = precip(i,j,bi,bj)
     &       + (slrc_precip_adjustment_fac-1. _d 0) * precip(i,j,bi,bj) 
     &       * maskC(i,j,kSrf,bi,bj) 
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
           ENDIF
#endif
#else
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
           IF(precip(i,j,bi,bj).GT.0. _d 0)THEN
#endif
            precipArr(i,j,bi,bj) = precip(i,j,bi,bj)
     &       + slrc_precip_adjustment * maskC(i,j,kSrf,bi,bj) 
#ifdef MODIDY_POSITIVE_PRECIP_ONLY
           ENDIF
#endif
#endif
      ENDDO 
      ENDDO
      ENDDO
      ENDDO

C----&------------------------------------------------------------------xxxxxxx|
C     Wrap up the code
C----&------------------------------------------------------------------xxxxxxx|

      _END_MASTER(myThid)

C--   Everyone must wait for the parameters to be loaded
      _BARRIER

#endif /* ALLOW_SLR_CORR */

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END SLR_CORR_ADJUST_PRECIP DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

      RETURN

      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
