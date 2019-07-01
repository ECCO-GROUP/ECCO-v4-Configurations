C $Header: /home/ubuntu/mnt/e9_copy/MITgcm/pkg/shelfice/shelfice_thermodynamics.F,v 1.47 2015/12/17 01:52:05 jmc Exp $
C $Name:  $

#include "SHELFICE_OPTIONS.h"
#ifdef ALLOW_AUTODIFF
# include "AUTODIFF_OPTIONS.h"
#endif
#ifdef ALLOW_CTRL
# include "CTRL_OPTIONS.h"
#endif

CBOP
C     !ROUTINE: SHELFICE_THERMODYNAMICS
C     !INTERFACE:
      SUBROUTINE SHELFICE_THERMODYNAMICS(
     I                        myTime, myIter, myThid )
C     !DESCRIPTION: \bv
C     *=============================================================*
C     | S/R  SHELFICE_THERMODYNAMICS
C     | o shelf-ice main routine.
C     |   compute temperature and (virtual) salt flux at the
C     |   shelf-ice ocean interface
C     |
C     | stresses at the ice/water interface are computed in separate
C     | routines that are called from mom_fluxform/mom_vecinv

CIGF  | ASSUMES 
C---  |   * SHELFICEconserve = true
C     *=============================================================*
C     \ev

C     !USES:
      IMPLICIT NONE

C     === Global variables ===
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DYNVARS.h"
#include "FFIELDS.h"
#include "SHELFICE.h"
#include "SHELFICE_COST.h"
#ifdef ALLOW_AUTODIFF
# include "CTRL_SIZE.h"
# include "ctrl.h"
# include "ctrl_dummy.h"
#endif /* ALLOW_AUTODIFF */
#ifdef ALLOW_AUTODIFF_TAMC
# ifdef SHI_ALLOW_GAMMAFRICT
#  include "tamc.h"
#  include "tamc_keys.h"
# endif /* SHI_ALLOW_GAMMAFRICT */
#endif /* ALLOW_AUTODIFF_TAMC */

C     !INPUT/OUTPUT PARAMETERS:
C     === Routine arguments ===
C     myIter :: iteration counter for this thread
C     myTime :: time counter for this thread
C     myThid :: thread number for this instance of the routine.
      _RL  myTime
      INTEGER myIter
      INTEGER myThid

#ifdef ALLOW_SHELFICE
C     !LOCAL VARIABLES :
C     === Local variables ===
C     I,J,K,Kp1,bi,bj  :: loop counters
C     tLoc, sLoc, pLoc :: local potential temperature, salinity, pressure
C     theta/saltFreeze :: temperature and salinity of water at the
C                         ice-ocean interface (at the freezing point)
C     freshWaterFlux   :: local variable for fresh water melt flux due
C                         to melting in kg/m^2/s
C                         (negative density x melt rate)
C     iceFrontCellThickness   :: the ratio of the horizontal length
C                         of the ice front in each model grid cell 
C                         divided by the grid cell area.  The "thickness"
C                         of the colum perpendicular to the front
C     iceFrontWidth    :: the width of the ice front.

      INTEGER I,J,K,Kp1
      INTEGER bi,bj
      INTEGER CURI, CURJ, FRONT_K

      _RL tLoc(1:sNx,1:sNy)
      _RL sLoc(1:sNx,1:sNy)
      _RL pLoc(1:sNx,1:sNy)

#ifndef SHI_USTAR_WETPOINT
      _RL uLoc(1:sNx,1:sNy)
      _RL vLoc(1:sNx,1:sNy)
#endif
      _RL velSq(1:sNx,1:sNy)
      
      _RL freshWaterFlux
       
      _RL ice_bottom_Z_C, seafloor_N 
      _RL wet_top_Z_N, wet_bottom_Z_N
      _RL iceFrontWetContact_Z_max, iceFrontContact_Z_min 
      _RL iceFrontContact_H   
      _RL iceFrontVertContactFrac, iceFrontCellThickness
      _RL iceFrontWidth, iceFrontFaceArea
      _RL thermalConductionDistance, thermalConductionTemp
      _RL tmpHeatFlux, tmpFWFLX
      _RL tmpForcingT, tmpForcingS
      INTEGER SI

#ifdef ALLOW_DIAGNOSTICS
      _RL uStarDiag(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
#endif /* ALLOW_DIAGNOSTICS */

      _RL epsilon_H

#ifdef ALLOW_SHIFWFLX_CONTROL
      _RL xx_shifwflx_loc(1-olx:snx+olx,1-oly:sny+oly,nsx,nsy)
#endif

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|

C--   minimum fraction of a cell adjacent to an ice front that must be 
C--   wet for exchange to happen
      epsilon_H = 1. _d -03

C--   hard coded for now.
      thermalConductionDistance = 100.0 _d 0
      thermalConductionTemp     = -20.0 _d 0

C     heat flux into the ice shelf, default is diffusive flux
C     (Holland and Jenkins, 1999, eq.21)

      DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
          DO J = 1-OLy,sNy+OLy
            DO I = 1-OLx,sNx+OLx
              shelfIceHeatFlux      (I,J,bi,bj) = 0. _d 0
              shelfIceFreshWaterFlux(I,J,bi,bj) = 0. _d 0
              shelficeForcingT      (I,J,bi,bj) = 0. _d 0
              shelficeForcingS      (I,J,bi,bj) = 0. _d 0
          
              DO K = 1, NR
                iceFrontHeatFlux(I,J,K,bi,bj)       = 0. _d 0
                iceFrontFreshWaterFlux(I,J,K,bi,bj) = 0. _d 0
                iceFrontForcingT(I,J,K,bi,bj)       = 0. _d 0
                iceFrontForcingS(I,J,K,bi,bj)       = 0. _d 0
              ENDDO /* K */
              
            ENDDO /* I */
          ENDDO /* J */

C--   First ice front then ice shelf.  Loop through each i,j point
C--   process ice fronts in k, then process ice shelf.
          DO J = 1, sNy
            DO I = 1, sNx

C--   The K index where the ice front ends (0 if no ice front)
              FRONT_K = K_icefront(I,J,bi,bj)

C--   If there is an ice front at this (I,J) continue
              IF (FRONT_K .GT. 0) THEN

C--   Loop through all depths where the ice front is fround
                DO K = 1, FRONT_K
C--   Loop around the four laterally neighboring cells of the ice front.
C--   If any neighboring points has wet volume in contact with the ice
C--   front at (I,J) then calculate ice-ocean exchanges.  
C--   The four laterally neighboring point are at (CURI,CURJ)
                  DO SI = 1,4
                    IF     (SI .EQ. 1) THEN
C--   Looking to right                  
                      CURI = I+1
                      CURJ = J

                      iceFrontWidth     = dyG(I+1,J,bi,bj)
                      
                    ELSEIF (SI .EQ. 2) THEN
C--   Looking to LEFT                  
                      CURI = I-1
                      CURJ = J

                      iceFrontWidth     = dyG(I,J,bi,bj)
                    ELSEIF (SI .EQ. 3) THEN
C--   Looking to NORTH                                    
                      CURI = I
                      CURJ = J+1

                      iceFrontWidth     = dxG(I,J+1,bi,bj)
                    ELSEIF (SI .EQ. 4) THEN
C--   Looking to south                   
                      CURI = I
                      CURJ = J-1
                  
                      iceFrontWidth     = dxG(I,J,bi,bj)
                    endif
                    
C--                 cell depth describes the average distance 
C--                 perpendicular to the ice front fact

                    iceFrontCellThickness = RA(CURI,CURJ,bi,bj)
     &                                  /iceFrontWidth
                    iceFrontFaceArea  = DRF(K)*iceFrontWidth

C--   First, make sure the adjacent point has at least some water in it.
                    IF (_hFacC(CURI,CURJ,K,bi,bj) .GT. zeroRL) THEN

C--   we need to determine how much of the ice front is in contact with
C--   water in the neighboring grid cell at this depth level.

C--   1. Determine the top depth with water in the current cell 
C--   2. Determine the top depth with water in the neighbor cell
C--   3. Determine the depth where water  gap between (1) and (2).  
C--   4. If there is a gap then ice front is in contact with water in 
C--      the neighboring cell

C--   ice_bottom_Z_C: the depth (m) of the bottom of the ice in the 
C--               current cell.  Bounded between rF(K) and rF(K+1).  
C--               * If the ice extends past the bottom of the cell then 
C--                 ice_bottom_Z_C = rF(K+1)
C--               [rF(k) >= ice_bottom_Z_C >= rF(K+1)]  (rF is negative)
                      ice_bottom_Z_C = max(rF(K+1), 
     &                  min(Ro_surf(I,J, bi,bj), rF(K)))

C--   wet_top_Z_N: the depth (m) of the bottom of the ice in the 
C--              neighboring grid.  If the neighboring cell has ice in
C--              (in the form of a shelf or front) then wet_top_Z_N is 
C--              the depth of this neighboring ice.
C--  
C--              * If neighbor cell has no ice, then Ro_surf = 0 and 
C--                wet_top_Z_N = rF(K)
C--              [rF(k) >= wet_top_Z_N >= rF(K+1)]     (rF is negative)

                      wet_top_Z_N = max(rF(K+1), 
     &                 min(Ro_surf(CURI,CURJ, bi,bj), rF(K)))

C--   wet_bottom_Z_N: the depth (m) of the bottom of the wet part of the 
C--              neighboring cell.  If the seafloor reaches into 
C--              the grid cell then the bottom of the wet part of the 
C--              grid cell is at the seafloor.
C--  
C--              * If the seafloor is deeper than this grid cell then 
C--                wet_bottom_Z = rF(K+1) 
C--              * If the seafloor is shallower than this grid cell then 
C--                wet_bottom_Z = rF(K) 
C--              * If the seafloor reaches partly into this grid cell
C--                then wet_bottom_Z = R_low

C--              [rF(k) >= wet_bottom_Z >= rF(K+1)]     (rF is negative)

                      wet_bottom_Z_N = min(rF(K), 
     &                  max(R_low(CURI,CURJ, bi,bj), rF(K+1)))

C--   iceFrontWetContact_Z_max:  The deepest point where the 
C--              the ice front at (I,J) is in contact with water
C--              in the neighboring cell.  The shallower of  
C--              wet_bottom_Z_N (seafloor depth of neighboring point) and 
C--              ice_bottom_Z_C (bottom of ice front in this center cell). 

C--              * wet_bottom_Z_N if the seafloor of the neighboring 
C--                cell is shallower than the ice draft at (I,J).  
C--              * ice_bottom_Z_C if the ice draft at (I,J) is shallower
C--                than the seafloor of the neighboring cell.

                      IF (ice_bottom_Z_C .GT. wet_bottom_Z_N) THEN
                        iceFrontWetContact_Z_max = ice_bottom_Z_C
                      ELSE 
                        iceFrontWetContact_Z_max = wet_bottom_Z_N
                      ENDIF

C--   The shallowest depth where the ice front at (I,J) is in contact 
C--   with water in the neighboring cell.  If the neighboring cell has 
C--   no ice draft then wet_top_Z_N = rF(k), the top of the cell.
C--   Otherwise, the shallowest depth where the ice front at (I,J) can 
C--   be in in contact with water (not ice) in (CURI, CURJ) 
C--   is wet_top_Z_N. 

C--   the fraction of the grid cell height that has ice draft in contact
C--   with water in the neighboring cell.
                      iceFrontVertContactFrac = 
     &                  (wet_top_Z_N - iceFrontWetContact_Z_max)/ DRF(K)


C--   Only proceed if iceFrontVertContactFrac is > 0, the 
C--   ice draft at (I,J) 
C--   is in contact with some water in the neighboring grid cell.
                      IF (iceFrontVertContactFrac .GT. epsilon_H) THEN
                        
                        tLoc = theta(CURI,CURJ,K,bi,bj)
                        sLoc = MAX(salt(CURI,CURJ,K,bi,bj), zeroRL)

C--   use pressure at the halfway point between the top and bottom of
C--   points of the ice front where the ice front is in contact with 
C--   open water.
                        pLoc = 0.5 _d 0 * ABS(wet_top_Z_N +
     &                    iceFrontWetContact_Z_max)
                    
                        CALL SHELFICE_SOLVE4FLUXES(
     I                    tLoc, sLoc, pLoc, 
     I                    shiTransCoeffT(CURI,CURJ,bi,bj), 
     I                    shiTransCoeffS(CURI,CURJ,bi,bj),
     I                    thermalConductionDistance, 
     I                    thermalConductionTemp,
     O                    tmpHeatFlux, tmpFWFLX,
     O                    tmpForcingT, tmpForcingS,
     I                    bi, bj, myTime, myIter, myThid )

C--   fluxes and forcing must be scaled by iceFrontVertContactFract and
C--   iceFrontContactFrac some fraction of the heigth and width of the
C--   grid cell face may not ice in contact with water.

C     tmpHeatFlux and tmpFWFLX come as W/m^2 and kg/m^2/s respectively
C--   but these rates only apply to the 
C--   fraction of the grid cell that has ice in contact with seawater.
C--   we must scale by iceFrontVertContactFrac to get to the average
C--   fluxes in this grid cell.

C--   In units W/m^2
                        iceFrontHeatFlux(CURI,CURJ,K,bi,bj) = 
     &                    iceFrontHeatFlux(CURI,CURJ,K,bi,bj) + 
     &                    tmpHeatFlux*iceFrontVertContactFrac

C     In units of kg/s/m^2
                        iceFrontFreshWaterFlux(CURI,CURJ,K,bi,bj) = 
     &                    iceFrontFreshWaterFlux(CURI,CURJ,K,bi,bj) + 
     &                    tmpFWFLX*iceFrontVertContactFrac

C     iceFrontForcing[T,S] X m/s but these rates only apply to the 
C--   fraction of the grid cell that has ice in contact with seawater.
C--   we must scale by iceFrontVertContactFrac to get to the average
C--   fluxes in this grid cell.  We must also divide the by the length 
C--   of the grid cell perpendicular to the face.

C     In units of K / s 
                        iceFrontForcingT(CURI,CURJ,K,bi,bj) = 
     &                    iceFrontForcingT(CURI,CURJ,K,bi,bj) + 
     &                    tmpForcingT/iceFrontCellThickness*
     &                    iceFrontVertContactFrac

C     In units of psu /s
                        iceFrontForcingS(CURI,CURJ,K,bi,bj) = 
     &                    iceFrontForcingS(CURI,CURJ,K,bi,bj) + 
     &                    tmpForcingS/iceFrontCellThickness*
     &                    iceFrontVertContactFrac

C     In units of kg /s     
                         addMass(CURI,CURJ,K,bi,bj) = 
     &                     addMass(CURI,CURJ,K,bi,bj) - 
     &                     tmpFWFLX*RA(CURI,CURJ,bi,bj)
                        ENDIF /* iceFrontCellThickness */
                      ENDIF /* hFacC(CURI,CURJ,K,bi,bj) */
                    ENDDO /* SI loop for adjacent cells */
                ENDDO /* K LOOP */
              ENDIF /* FRONT K */

C--   ice shelf 
              K = kTopC(I,J,bi,bj)  

C--   If there is an ice front at this (I,J) continue 
C--   I am assuming K is only .GT. when there is at least some
C--   nonzero wet point below the shelf in the grid cell.
              IF (K .GT. 0) THEN
C--   Initialize these values to zero          
                pLoc = 0 _d 0
                tLoc = 0 _d 0
                sLoc = 0 _d 0

C--   make local copies of temperature, salinity and depth 
C--   (pressure in deci-bar) underneath the ice
C--   for the ice shelf case we use hydrostatic pressure at the ice 
C--   base of the ice shelf, top of the cavity.

                pLoc = ABS(R_shelfIce(I,J,bi,bj))
                tLoc = theta(I,J,K,bi,bj)
                sLoc = MAX(salt(I,J,K,bi,bj), zeroRL)

                CALL SHELFICE_SOLVE4FLUXES(
     I            tLoc, sLoc, pLoc, 
     I            shiTransCoeffT(I,J,bi,bj), 
     I            shiTransCoeffS(I,J,bi,bj),
     I            pLoc, thermalConductionTemp,
     O            tmpHeatFlux, tmpFWFLX,
     O            tmpForcingT, tmpForcingS,                
     I            bi, bj, myTime, myIter, myThid )

C     In units of W/m^2
                shelficeHeatFlux(I,J,bi,bj) = tmpHeatFlux
C     In units of kg/m^2/s 
                shelfIceFreshWaterFlux(I,J,bi,bj) = tmpFWFLX

C     In units of K/s -- division by drF required first
                shelficeForcingT(I,J,bi,bj) = tmpForcingT*
     &              recip_drF(K)* _recip_hFacC(i,j,K,bi,bj)                            
C     In units of psu/s  -- division by drF required first
                shelficeForcingS(I,J,bi,bj) = tmpForcingS*
     &              recip_drF(K)* _recip_hFacC(i,j,K,bi,bj)
C     In units of kg/s  -- multiplication of area required first        
                addMass(I,J,K, bi,bj) = addMass(I,J,K, bi,bj) - 
     &              tmpFWFLX*RA(I,J,bi,bj)
              ENDIF /* SHELF K > 0 */
            ENDDO /* i */ 
          ENDDO /* j */
        ENDDO /* bi */
      ENDDO /* bj */


C--  Calculate new loading anomaly (in case the ice-shelf mass was updated)
#ifndef ALLOW_AUTODIFF
c     IF ( SHELFICEloadAnomalyFile .EQ. ' ' ) THEN
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j = 1-OLy, sNy+OLy
          DO i = 1-OLx, sNx+OLx
           shelficeLoadAnomaly(i,j,bi,bj) = gravity
     &      *( shelficeMass(i,j,bi,bj) + rhoConst*Ro_surf(i,j,bi,bj) )
          ENDDO
         ENDDO
        ENDDO
       ENDDO
c     ENDIF
#endif /* ndef ALLOW_AUTODIFF */


#endif /* ALLOW_SHELFICE */
      RETURN
      END
