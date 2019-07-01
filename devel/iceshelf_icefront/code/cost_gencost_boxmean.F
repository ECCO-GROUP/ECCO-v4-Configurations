C $Header: /u/gcmpack/MITgcm/pkg/ecco/cost_gencost_boxmean.F,v 1.7 2015/03/23 21:10:04 gforget Exp $
C $Name:  $

#include "ECCO_OPTIONS.h"

      subroutine cost_gencost_boxmean(mythid)

c     ==================================================================
c     SUBROUTINE cost_gencost_boxmean
c     ==================================================================
c
c     o Evaluate cost function contributions of box mean THETA.
c
c     ==================================================================
c     SUBROUTINE cost_gencost_boxmean
c     ==================================================================

      implicit none

c     == global variables ==

#include "EEPARAMS.h"
#include "SIZE.h"
#include "PARAMS.h"
#include "GRID.h"
#ifdef ALLOW_CAL
# include "cal.h"
#endif
#ifdef ALLOW_ECCO
# include "ecco.h"
#endif

c     == routine arguments ==
      integer mythid

#ifdef ALLOW_GENCOST_CONTRIBUTION

c     == local variables ==

      integer kgen
      _RL mybar(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      _RL mymsk(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      _RL tmpmsk(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)

      _RL mySumTile(nSx,nSy),myVolTile(nSx,nSy)
      _RL mySumGlo,myVolGlo,myMeanGlo

      _RL tmpSumTile(nSx,nSy),tmpVolTile(nSx,nSy)
      _RL tmpSumGlo,tmpVolGlo,tmpMeanGlo

      _RL mymean(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      _RL mycount(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      _RL mymsk2(1-olx:snx+olx,1-oly:sny+oly,nr,nsx,nsy)
      _RL offset, offset_sum

      integer bi,bj
      integer i,j,k
      integer irec,il
      integer nrtmp, k2, iskip, irec2, ibeg
      character*(80) myfname
      _RL mydummy
      logical doglobalread
      logical ladinit
      logical doskip, doanom, doglosum
      logical domaskw, domasks
      character*(MAX_LEN_MBUF) msgbuf

c     == external functions ==

      integer  ilnblnk
      external ilnblnk

      LOGICAL  MASTER_CPU_THREAD
      EXTERNAL MASTER_CPU_THREAD

c     == end of interface ==

c-- detect the relevant gencost indices
      kgen=0
      do k=1,NGENCOST
        if ( (gencost_name(k).EQ.'boxmean').AND.
     &     (using_gencost(k)) ) then
           kgen=k
           nrtmp = nr
           if (.NOT.gencost_is3d(k))nrtmp = 1
        endif
      enddo

      if (kgen.NE.0) then

c ========

c set bar field params
      doglobalread = .false.
      ladinit      = .false.
      mydummy=gencost_dummy(kgen)
      il = ilnblnk( gencost_barfile(kgen) )
      write(myfname(1:80),'(2a,i10.10)')
     &    gencost_barfile(kgen)(1:il),'.',eccoiter

      doskip=.FALSE.
      iskip = 0
      ibeg = 0
      doanom=.FALSE.
      doglosum=.FALSE.
      domaskw=.FALSE.
      domasks=.FALSE.
      do k2 = 1, NGENPPROC
          if (gencost_preproc(k2,kgen).EQ.'skip') then 
           doskip=.TRUE.
           iskip = gencost_preproc_i(k2,kgen)
          endif
          if (gencost_preproc(k2,kgen).EQ.'anom') then 
           doanom=.TRUE.
           ibeg = gencost_preproc_i(k2,kgen)
          endif
          if (gencost_preproc(k2,kgen).EQ.'glosum') then 
           doglosum=.TRUE.
          endif
          if (gencost_preproc(k2,kgen).EQ.'usingmaskw') then 
           domaskw=.TRUE.
          endif
          if (gencost_preproc(k2,kgen).EQ.'usingmasks') then 
           domasks=.TRUE.
          endif
      enddo

        WRITE(msgBuf,'(A,5L2,3i5)') 'cost_gencost_boxmean.F: ',
     &   doskip, doanom, doglosum, domaskw, domasks, iskip, ibeg,
     &   nrtmp
        CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &                    SQUEEZE_RIGHT , 1)


c initialize various things to 0
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          mySumTile(bi,bj)=0. _d 0
          myVolTile(bi,bj)=0. _d 0
          mySumGlo=0. _d 0
          myVolGlo=0. _d 0
          do k = 1,nr
          do j = 1,sNy
          do i =  1,sNx
          tmpmsk(i,j,k,bi,bj)=0. _d 0
          if(doanom)then
           mymean(i,j,k,bi,bj)=0. _d 0
           mycount(i,j,k,bi,bj)=0. _d 0
          endif

           mymsk2(i,j,k,bi,bj)=hFacC(i,j,k,bi,bj)
           if(domaskw)
     &       mymsk2(i,j,k,bi,bj)=hFacW(i,j,k,bi,bj)
           if(domasks)
     &       mymsk2(i,j,k,bi,bj)=hFacS(i,j,k,bi,bj)
          enddo
          enddo
          enddo
       ENDDO
      ENDDO

c initialize maximum mask for time series display
      do irec = 1,nmonsrec
       if(.NOT.(doskip).OR.irec.GT.iskip)then 
       if(gencost_timevaryweight(kgen).or.irec.eq.(iskip+1)) then
        irec2 = irec-iskip
        call mdsreadfield( gencost_errfile(kgen),
     &                     cost_iprec, cost_yftype,
     &                     nrtmp, 
     &                     mymsk(:,:,1:nrtmp,:,:), 
     &                     irec2, mythid)
       endif
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
        do k = 1,nrtmp
         do j = 1,sNy
          do i =  1,sNx
      tmpmsk(i,j,k,bi,bj)=mymsk(i,j,k,bi,bj)+mymsk(i,j,k,bi,bj)
          enddo
         enddo
        enddo
       enddo
      enddo
      endif
      enddo

c ========
c main loop where cost is computed and time series is displayed
      do irec = 1,nmonsrec

c read bar field
       if(nr.eq.nrtmp) then
#ifdef ALLOW_AUTODIFF
        call active_read_xyz( myfname, mybar, irec,
     &                        doglobalread, ladinit,
     &                        eccoiter, mythid,
     &                        mydummy )
#else
        CALL READ_REC_XYZ_RL( myfname, mybar,
     &                        iRec, 1, myThid )
#endif
       else 
#ifdef ALLOW_AUTODIFF
        call active_read_xy( myfname, 
     &                        mybar(:,:,1:nrtmp,:,:), 
     &                        irec,
     &                        doglobalread, ladinit,
     &                        eccoiter, mythid,
     &                        mydummy )
#else
        CALL READ_REC_XY_RL( myfname, mybar(:,:,1:nrtmp,:,:),
     &                        iRec, 1, myThid )
#endif
       endif

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          tmpSumTile(bi,bj)=0. _d 0
          tmpVolTile(bi,bj)=0. _d 0
          tmpSumGlo=0. _d 0
          tmpVolGlo=0. _d 0
        enddo
      enddo

      if(doanom)then
c accumulate mymean and mycount 
      if(ibeg .eq. 0 .or. irec.ge.ibeg) then 
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          do k = 1,nrtmp
            do j = 1,sNy
              do i =  1,sNx
c sum that is actually be used in cost function
      mymean(i,j,k,bi,bj) = mymean(i,j,k,bi,bj) 
     &  +mybar(i,j,k,bi,bj)
      mycount(i,j,k,bi,bj) = mycount(i,j,k,bi,bj) 
     &  +1.
              enddo
            enddo
          enddo
        enddo
      enddo
      endif
      endif

      enddo

      if(doanom)then
c compute mymean
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          do k = 1,nrtmp
            do j = 1,sNy
              do i =  1,sNx
                 if(mycount(i,j,k,bi,bj).NE.0. _d 0) then
                    mymean(i,j,k,bi,bj) = mymean(i,j,k,bi,bj) 
     &                / mycount(i,j,k,bi,bj)
                 endif
              enddo
            enddo
          enddo
        enddo
      enddo
      endif
CZZZZZZZZZ

c main loop where cost is computed and time series is displayed
      do irec = 1,nmonsrec

       if(.NOT.(doskip).OR.irec.GT.iskip)then 
c read bar field
       if(nr.eq.nrtmp) then
#ifdef ALLOW_AUTODIFF
        call active_read_xyz( myfname, mybar, irec,
     &                        doglobalread, ladinit,
     &                        eccoiter, mythid,
     &                        mydummy )
#else
        CALL READ_REC_XYZ_RL( myfname, mybar,
     &                        iRec, 1, myThid )
#endif
       else 
#ifdef ALLOW_AUTODIFF
        call active_read_xy( myfname, 
     &                        mybar(:,:,1:nrtmp,:,:), 
     &                        irec,
     &                        doglobalread, ladinit,
     &                        eccoiter, mythid,
     &                        mydummy )
#else
        CALL READ_REC_XY_RL( myfname, mybar(:,:,1:nrtmp,:,:),
     &                        iRec, 1, myThid )
#endif
       endif

       if(gencost_timevaryweight(kgen).or.irec.eq.(iskip+1)) then
c read mask for averaging (3d, time series)
        irec2 = irec-iskip
        call mdsreadfield( gencost_errfile(kgen),
     &                     cost_iprec, cost_yftype,
     &                     nrtmp, mymsk(:,:,1:nrtmp,:,:),irec2,mythid)
       endif

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          tmpSumTile(bi,bj)=0. _d 0
          tmpVolTile(bi,bj)=0. _d 0
          tmpSumGlo=0. _d 0
          tmpVolGlo=0. _d 0
        enddo
      enddo

      if(doanom)then
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          do k = 1,nrtmp
            do j = 1,sNy
              do i =  1,sNx
       if ( mymsk2(i,j,k,bi,bj).NE. 0. _d 0) then
        mybar(i,j,k,bi,bj) = mybar(i,j,k,bi,bj)-mymean(i,j,k,bi,bj) 
       endif
              enddo
            enddo
          enddo
        enddo
      enddo
      endif

      if(doglosum) then 
      offset     = 0. _d 0
      offset_sum = 0. _d 0

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          do k = 1,nrtmp
            do j = 1,sNy
              do i =  1,sNx
       if ( mymsk2(i,j,k,bi,bj).NE. 0. _d 0) then
          if(nrtmp.EQ.Nr)then
           offset  = offset + RA(i,j,bi,bj)*mybar(i,j,k,bi,bj)
     &       * mymsk2(i,j,k,bi,bj) * drf(k)
           offset_sum = offset_sum + RA(i,j,bi,bj)
     &       * mymsk2(i,j,k,bi,bj) * drf(k)
          else
           offset  = offset + RA(i,j,bi,bj)*mybar(i,j,k,bi,bj)
           offset_sum = offset_sum + RA(i,j,bi,bj)
          endif
       endif
              enddo
            enddo
          enddo
        enddo
      enddo
      _GLOBAL_SUM_RL( offset     , mythid )
      _GLOBAL_SUM_RL( offset_sum , mythid )

      if (offset_sum.GT. 0. _d 0)then
         offset = offset / offset_sum
      endif

      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          do k = 1,nrtmp
            do j = 1,sNy
              do i =  1,sNx
       if ( mymsk2(i,j,k,bi,bj).NE. 0. _d 0) then
          mybar(i,j,k,bi,bj) = mybar(i,j,k,bi,bj) - offset      
       endif
              enddo
            enddo
          enddo
        enddo
      enddo
C     if(doglosum) then 
      endif

c compute cost
      DO bj=myByLo(myThid),myByHi(myThid)
       DO bi=myBxLo(myThid),myBxHi(myThid)
          do k = 1,nrtmp
            do j = 1,sNy
              do i =  1,sNx
c sum that is actually be used in cost function
      
      objf_gencost(bi,bj,kgen)=
     &   objf_gencost(bi,bj,kgen)
     &  +mybar(i,j,k,bi,bj)*mymsk(i,j,k,bi,bj)
      num_gencost(1,1,kgen)=
     &   num_gencost(1,1,kgen)
     &  +mymsk(i,j,k,bi,bj)

c sum for display of time series
      tmpSumTile(bi,bj)=tmpSumTile(bi,bj)
     &  +mybar(i,j,k,bi,bj)*tmpmsk(i,j,k,bi,bj)
      tmpVolTile(bi,bj)=tmpVolTile(bi,bj)
     &  +tmpmsk(i,j,k,bi,bj)

              enddo
            enddo
          enddo
        enddo
      enddo


c global sums for display of time series
      CALL GLOBAL_SUM_TILE_RL( tmpSumTile, tmpSumGlo, myThid )
      CALL GLOBAL_SUM_TILE_RL( tmpVolTile, tmpVolGlo, myThid )
      tmpMeanGlo=0. _d 0
      if ( tmpVolGlo.GT.0. _d 0) 
     &   tmpMeanGlo=tmpSumGlo/tmpVolGlo

      WRITE(msgBuf,'(A,I3,1PE21.14,1PE21.14)')
     &    'boxmean :',irec,tmpMeanGlo,tmpVolGlo
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &    SQUEEZE_RIGHT, myThid )

       endif ! if(.NOT.(doskip) .OR. irec.GT. iskip)
      enddo

c ========


c global sums for cost function
      CALL GLOBAL_SUM_TILE_RL( objf_gencost(1,1,kgen),
     &   mySumGlo, myThid )
      CALL GLOBAL_SUM_TILE_RL( num_gencost(1,1,kgen),
     &   myVolGlo, myThid )
      myMeanGlo=0. _d 0
      if ( myVolGlo.GT.0. _d 0)
     &   myMeanGlo=mySumGlo/myVolGlo

      WRITE(msgBuf,'(A,I3,1PE21.14,1PE21.14)') 
     &    'boxmean fc :',irec,myMeanGlo,myVolGlo
      CALL PRINT_MESSAGE( msgBuf, standardMessageUnit,
     &    SQUEEZE_RIGHT, myThid )

c ========

      endif !if (kgen.NE.0)

#endif /* ALLOW_GENCOST_CONTRIBUTION */

      end
