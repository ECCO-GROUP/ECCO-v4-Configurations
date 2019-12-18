
      subroutine lsline( 
     &     simul
     &     , nn, ifail, lphprint
     &     , ifunc, nfunc
     &     , ff, dotdg
     &     , tmin, tmax, tact, epsx
     &     , dd, gg, xx, xdiff
     &     )

c     ==================================================================
c     SUBROUTINE lsline
c     ==================================================================
c
c     o line search algorithm for determining control vector update;
c       After computing updated control vector from given gradient,
c       a forward and adjoint model run are performed (simul.F)
c       using the updated control vector.
c       Tests are then applied to see whether solution has improved.
c
c     o Reference: J.C. Gilbert & C. Lemarechal
c                  Some numerical experiments with variable-storage
c                  quasi-Newton algorithms
c                  Mathematical Programming 45 (1989), pp. 407-435
c
c     o started: ??? not reproducible
c
c     o changed: Patrick Heimbach, MIT/EAPS
c
c     o Version: 2.0, 24-Feb-2000: Patrick Heimbach, MIT/EAPS
c                   - severe changes in structure including various
c                     shifts of variables which are only used in this
c                     routine
c                   - number of 3 control flags for error handling
c                     (indic, moderl, ifail) reduced to 1 (ifail)
c                     and homogenized with routine lsoptv
c
c     o Version: 2.1.0, 02-Mar-2000: Patrick Heimbach, MIT/EAPS
c                   - initial computation of tact and
c                     xdiff = xx + tact*dd 
c                     moved to new routine lsupdxx
c                     tmin, tmax, tact needed as parameters
c
c     ==================================================================
c     SUBROUTINE lsline
c     ==================================================================

#include "blas1.h"

      implicit none

c----------------------------------
c declare arguments
c----------------------------------
      integer nn, ifail, ifunc, nfunc
      double precision ff, dotdg, tmin, tmax, tact, epsx
      double precision xx(nn), dd(nn), gg(nn), xdiff(nn)

      logical lphprint

      external simul

c----------------------------------
c declare local variables
c----------------------------------

      double precision xpara1, xpara2
      parameter( xpara1 = 0.000001, xpara2=0.99999 )

      double precision    factor
      parameter( factor = 0.2 )

      double precision    barmax
      parameter( barmax = 0.3 )
      double precision    barmul
      parameter( barmul = 5.0 )
      double precision    barmin
      parameter( barmin = 0.01 )

      integer i, indic

      double precision    tg, fg, td, ta
      double precision    fa, fpa, fp
      double precision    fnew, fdiff
      double precision    z, test, barr
      double precision    left, right, told

      external DDOT
      double precision     DDOT

c----------------------------------
c check parameters
c----------------------------------

      if (  (nn.le.0)
     &     .or. (dotdg.ge.0.0)  
     &     .or. (xpara1.le.0.0) .or. (xpara1.ge.0.5)
     &     .or. (xpara2.le.xpara1)  .or. (xpara2.ge.1.0) ) then
         ifail = 9
         go to 999
      endif

c----------------------------------
c initialization
c----------------------------------
      indic = 0

      barr   = barmin
      fg     = ff
      fa     = ff
      fpa    = dotdg

      td     = 0.0
      tg     = 0.0
      ta     = 0.0

c=======================================================================
c begin of simulation iter.
c=======================================================================

      do ifunc = 1, nfunc

         if (lphprint) 
     &        print *, 'pathei-lsopt: ', ifunc, ' simul.'

c------------------------------------
c compute cost function and gradient
c------------------------------------
         call simul( indic, nn, xdiff, fnew, gg )

C compute tact (could be different from 1)
         do i = 1, nn
          if(dd(i) .ne. 0.and.(xdiff(i) - xx(i)).ne.0) then
          tact = (xdiff(i) - xx(i))/ dd(i)
          goto 301
          endif
         end do
301      continue
C if tact is only slightly different from 1., then it 
C is set to 1. The difference is likely caused by trunction error.
         if(abs(tact-1.).le.1.d-6) tact = 1.


C compute fp = direction(dd) . gradient(gg)
         fp = DDOT( nn, dd, 1, gg, 1 )
         fdiff = fnew - ff

          if (lphprint) 
     &        print *, 'Wolfe test ', ifail, fnew,ff, 
     &        fdiff, tact, dotdg, tact*xpara1*dotdg, 
     &        fp,  xpara2*dotdg 

         print*, 'pathei-lsopt: '
         if(fdiff .gt. tact*xpara1*dotdg) then
          print*, 'Wolfe test 1: failed'
         else
          print*, 'Wolfe test 1: passed'
         endif


         if (fp .gt. xpara2*dotdg) then
          print*, 'Wolfe test 2: passed'
         else
          print*, 'Wolfe test 2: failed'
         endif


c-----------------------------------------
c apply 1st Wolfe test
c-----------------------------------------

         if (fdiff .gt. tact*xpara1*dotdg) then
          if (lphprint) 
     &        print *, 'Wolfe test 1 (Armijo Rule) Failed' 
            td     = tact
            ifail  = 0
            go to 500
         endif

c-----------------------------------------
c 1st Wolfe test 1 ok, apply 2nd Wolf test
c-----------------------------------------
         if (fp .gt. xpara2*dotdg) then
          if (lphprint) 
     &        print *, 'Pass Wolfe test 2 (Curvature condition)' 
            ifail = 0
            go to 320
         endif

         if (ifail.eq.0) go to 350

c-----------------------------------------
c 2nd Wolfe test 2 ok, donc pas serieux, on sort
c-----------------------------------------

 320     continue

         ff = fnew
         do i = 1, nn
            xx(i) = xdiff(i)
         end do
cph(
         if (lphprint) 
     &        print *, 'pathei-lsopt: no inter-/extrapolation in lsline'
cph)
         go to 888


c-----------------------------------------
c extrapolation
c-----------------------------------------

 350     continue

         tg  = tact
         fg  = fnew
         if (td .ne. 0.0) go to 500

         told    = tact
         left = (1.0+barmin)*tact
         right = 10.*tact
         if (lphprint) 
     &        print *, 'pathei-lsopt: extra before cubic: ',
     &        'tact, fnew, fp, ta, fa, fpa, left, right,told = ', 
     &        tact, fnew, fp, ta, fa, fpa, left, right, told
         call cubic( tact, fnew, fp, ta, fa, fpa, left, right )
         ta     = told
         if (tact.ge.tmax) then
            ifail = 7
            tact     = tmax
         endif

         if (lphprint) 
     &        print *, 'pathei-lsopt: extrapolation: ',
     &        'td, tg, tact, ifail = ', td, tg, tact, ifail

         go to 900

c-----------------------------------------
c interpolation
c-----------------------------------------

 500     continue

C td: tact (step size) 
C tg: was set to zero
C So the limits are between 0.01 * tg and tact-0.01*tg (0 and tact for isuml = 1)
         test   = barr*(td-tg)
         left = tg+test
         right = td-test
         told    = tact
C input:
C tact: was set to 1 when input, but in output store the new step size
C fnew: the new cost function in input
C fp: new dotdg: dd . gg ( direction DOT gradient)
C ta:  set to zero (namely set x0 = 0 so tact is distance between x1 and x0)   
C fa:  old cost function 
C fpa: old dotdg: dd . gg (diretion DOT gradient)
         call cubic( tact, fnew, fp, ta, fa, fpa, left, right )
         ta = told
         if (tact.gt.left .and. tact.lt.right) then
C falling within left and right brackets. Keep the same barr
            barr = dmax1( barmin, barr/barmul )
         else
C outside of the left and right brackets. Reduce barr by half
            barr = dmin1( barmul*barr, barmax )
         endif

         if (lphprint) 
     &        print *, 'pathei-lsopt: interpolation: ',
     &        'td, tg, tact, ifail = ', td, tg, tact, ifail

c-----------------------------------------
c end of iteration loop
c     - tact peut etre bloque sur tmax
c       (venant de lextrapolation avec ifail=7)
c-----------------------------------------

 900     continue

         fa  = fnew
         fpa = fp

c-----------------------------------------
c --- faut-il continuer ?
c-----------------------------------------
         if (td .eq. 0.0)     go to 950
         if (td-tg .lt. tmin) go to 920

c-----------------------------------------
c limit due to machine precision
c-----------------------------------------
         do i = 1, nn
            z = xx(i) + tact*dd(i)
            if ((z.ne.xx(i)) .and. (z.ne.xdiff(i))) go to 950
         end do

c-----------------------------------------
c arret sur dxmin ou de secours
c-----------------------------------------
 920     continue
         ifail = 8

c-----------------------------------------
c     si tg=0, xx = xx_depart,
c     sinon on prend xx=x_left qui fait decroitre f
c-----------------------------------------
         if (tg .ne. 0.0) then
            ff = fg
            do i = 1, nn
               xx(i) = xx(i) + tg*dd(i)
            end do
         endif

         go to 999

c-----------------------------------------
c update vector for new simulation
c-----------------------------------------
 950     continue

         do i = 1, nn
            xdiff(i) = xx(i) + tact*dd(i)
         end do

c=======================================================================
c end of simulation iter.
c=======================================================================
         if (lphprint) 
     &        print *, 'pathei-lsopt: end of simulation iter: ',
     &        'td, tg, tact, ifail = ', td, tg, tact, ifail
      end do

c-----------------------------------------
c too many function evaluations
c-----------------------------------------
      ifail = 6
      ff    = fg
      do i = 1, nn
         xx(i) = xx(i) + tg*dd(i)
      end do


  999 continue
C Set ifail=99 so we do not modify OPWARMD and OPWARMI
C We modify OPWARMD and OPWARMI Only if the result 
C passes both Wolfe condtions

      ifail = 99

c-----------------------------------------
c end of routine
c-----------------------------------------
  888 continue

         if (lphprint) 
     &        print *, 'pathei-lsopt: end of lsline: ',
     &        'td, tg, tact, ifail = ', td, tg, tact, ifail
      return

      end
