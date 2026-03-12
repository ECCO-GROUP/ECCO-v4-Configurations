C----&------------------------------------------------------------------xxxxxxx|
C                           slr_corr_readparms
C----&------------------------------------------------------------------xxxxxxx|

#include "SLR_CORR_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: SLR_CORR_READPARMS

C !INTERFACE:
      SUBROUTINE SLR_CORR_READPARMS( myThid )

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
      
      NAMELIST / SLR_CORR_PARM01 /
     &     slrc_obs_filename,
     &     slrc_output_filename,
     &     slrc_filePrec,
     &     slrc_obs_startdate_1,
     &     slrc_obs_startdate_2,
     &     slrc_obs_period,
     &     slrc_balancePeriod, 
     &     slrc_obs_ref
    
      if (debug .eq. 1) then
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "  BEGIN SLR_CORR_READPARMS DEBUG "
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        WRITE(msgBuf,'(A)') "========================================="
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
        endif

C----&------------------------------------------------------------------xxxxxxx|
C   Initialize local variables and variables from SLR_CORR_INPUT_VARS NAMELIST
C   with default values
C----&------------------------------------------------------------------xxxxxxx|

      _BEGIN_MASTER(myThid)

      slrc_obs_filename = ' '
      slrc_output_filename = ' '

      slrc_filePrec = 64
      slrc_obs_startdate_1    = 0
      slrc_obs_startdate_2    = 0

      slrc_obs_period = 0.
      slrc_balancePeriod = 0.
      slrc_obs_start_time = 0.
      slrc_obs_ref = 0.

C----&------------------------------------------------------------------xxxxxxx|
C     Write out status to main output and fill in the parameters
C----&------------------------------------------------------------------xxxxxxx|

      WRITE(msgBuf,'(A)')
     &      'SLR_CORR_READPARMS: opening data.slr_corr'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      CALL OPEN_COPY_DATA_FILE(
     I             'data.slr_corr', 'SLR_CORR_READPARMS',
     O              iUnit,
     I              myThid )

C     Read parameters from open data file
      WRITE(msgBuf,'(2A)') 'S/R SLR_CORR_READPARMS,',
     &     ' read namelist "SLR_CORR_PARM01": start'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)
      READ  (UNIT=iUnit,NML=SLR_CORR_PARM01)
      WRITE(msgBuf,'(2A)') 'S/R SLR_CORR_READPARMS,',
     &     ' read namelist "SLR_CORR_PARM01": OK'
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)

C     Close the open data file
#ifdef SINGLE_DISK_IO
      CLOSE(iUnit)
#else
      CLOSE(iUnit,STATUS='DELETE')
#endif /* SINGLE_DISK_IO */

      if (debug .eq. 1) then
      WRITE(msgBuf,'(A,A)') "  slrc_obs_filename: ", slrc_obs_filename
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,I9)') "  slrc_obs_startdate_1: ",
     &                       slrc_obs_startdate_1
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,I9)') "  slrc_obs_startdate_2: ",
     &                       slrc_obs_startdate_2
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F10.3)') "  slrc_obs_period: ",
     &                       slrc_obs_period
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F10.3)') "  slrc_balancePeriod: ",
     &                       slrc_balancePeriod
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,A)') "  slrc_output_filename: ",
     &                       slrc_output_filename
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      WRITE(msgBuf,'(A,F10.3)') "  slrc_obs_start_time: ",
     &                       slrc_obs_start_time
      WRITE(msgBuf,'(A,E10.3)') "  slrc_obs_ref: ",
     &                       slrc_obs_ref
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                     SQUEEZE_RIGHT, myThid )
      endif

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
        WRITE(msgBuf,'(A)') "  END SLR_CORR_READPARMS DEBUG "
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
