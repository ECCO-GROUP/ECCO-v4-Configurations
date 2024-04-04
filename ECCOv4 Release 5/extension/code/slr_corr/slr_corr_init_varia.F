C----&------------------------------------------------------------------xxxxxxx|
C                           slr_corr_init_varia
C----&------------------------------------------------------------------xxxxxxx|

#include "SLR_CORR_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: SLR_CORR_INIT_VARIA

C !INTERFACE:
      SUBROUTINE SLR_CORR_INIT_VARIA( myThid )

C     !DESCRIPTION:
C     Initialize SLR_CORR parameters and constants.

C     !USES:
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "SLR_CORR_PARAM.h"
#include "SLR_CORR_FIELDS.h"

C     !INPUT PARAMETERS:
      INTEGER myThid

C     !LOCAL VARIABLES:
      CHARACTER*(MAX_LEN_MBUF) msgBuf
      INTEGER iUnit
      INTEGER, PARAMETER :: debug = 0

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
        WRITE(msgBuf,'(A)') "  BEGIN SLR_CORR_INIT_VARIA DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif


      _BEGIN_MASTER(myThid)

C----&------------------------------------------------------------------xxxxxxx|
C   Enter init_varia code here
C----&------------------------------------------------------------------xxxxxxx|

C   Currently nothing to do in this script - deltete if not necessary      

C----&------------------------------------------------------------------xxxxxxx|
C     Wrap up the code
C----&------------------------------------------------------------------xxxxxxx|

      _END_MASTER(myThid)

C--   Everyone must wait
      _BARRIER

#endif /* ALLOW_SLR_CORR */

      if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  END SLR_CORR_INIT_VARIA DEBUG "
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