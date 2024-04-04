C----&------------------------------------------------------------------xxxxxxx|
C                           slr_corr_write_bin
C----&------------------------------------------------------------------xxxxxxx|

#include "SLR_CORR_OPTIONS.h"

C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|
CBOP
C !ROUTINE: SLR_CORR_OUTPUT

C !INTERFACE:
      SUBROUTINE SLR_CORR_OUTPUT( myTime, myIter, myThid )

C     !USES:
      IMPLICIT NONE

#include "SIZE.h"
#include "EEPARAMS.h"
#include "EESUPPORT.h"
#include "PARAMS.h"
#include "SLR_CORR_PARAM.h"

C     !INPUT PARAMETERS:
      _RL     myTime
      INTEGER myThid
      INTEGER myIter

C     !LOCAL VARIABLES:

CEOP

C----&------------------------------------------------------------------xxxxxxx|
CBOC 
       character*2 dir
       integer, parameter :: debug = 0
       logical exists
       logical do_the_io
       integer LEN, i
       real*4 buffer_r4

       LEN = 1
       dir = "./"

#ifndef ALLOW_USE_MPI
      do_the_io = .TRUE.
#else
      if (mpiMyId.eq.0) then 
      do_the_io = .TRUE.
      else
      do_the_io = .FALSE.
      endif
#endif       

      if (do_the_io) then

       IF (slrc_filePrec .eq. 32) then

          buffer_r4 = slrc_precip_adjustment

C         call VEC_R8_to_R4(bufferR4_2D, bufferR4_3D,2,fld,vec_id)
C         call CREATE_FILENAME_VEC(dir, vec_flds2D(fld,vec_id), vec_id,
C     &                      filename,myIter)

C         Writing all time levels into a single binary file
          INQUIRE (IOLENGTH = LEN) 1
          INQUIRE (FILE=slrc_output_filename, EXIST=exists)
C         If file already exists, set status as 'old'. Otherwise, 'replace'
          if (exists) then
           open(1, FILE=slrc_output_filename, STATUS='OLD', 
     &          ACCESS='DIRECT', RECL = LEN )
          else
           open(1, FILE=slrc_output_filename, STATUS='REPLACE', 
     &          ACCESS='DIRECT', RECL = LEN )
          endif
          write(1, REC=myIter-nIter0+1) buffer_r4
         close(1)


       ELSE IF (slrc_filePrec .eq. 64) then

C       -----------------------------------------------------------------------
C       File precision: 64
C       Field dimension: 2
C       -----------------------------------------------------------------------
C         call CREATE_FILENAME_VEC(dir, vec_flds2D(fld,vec_id), vec_id,
C     &                      filename,myIter)

C          INQUIRE (IOLENGTH = LEN) global_vec2D(1:total_valid)
C          INQUIRE (FILE=filename, EXIST=exists)
C         If file already exists, set status as 'old'. Otherwise, 'replace'
C          if (exists) then
C           open( 1, FILE=filename, STATUS='OLD', ACCESS='DIRECT',
C     &          RECL = LEN )
C          else
C           open( 1, FILE=filename, STATUS='REPLACE', ACCESS='DIRECT',
C     &          RECL = LEN )
C          endif

C          write(1, REC=vec_time_levels(vec_id,1)) 
C     &                 global_vec2D(1:total_valid)

C         close(1)


       ENDIF

       endif

      END
CEOC
C----&------------------------------------------------------------------xxxxxxx|
C----&------------------------------------------------------------------xxxxxxx|