
      subroutine cubic( t, f, fp, ta, fa, fpa, tlower, tupper )

c-----------------------------------------
c arguments
c-----------------------------------------
      double precision    t, f, fp, ta, fa, fpa, tlower, tupper

c-----------------------------------------
c local variables
c-----------------------------------------
      double precision sign, den, anum
      double precision z1, b, discri

c-----------------------------------------
c Using f and fp at t and ta,
c computes new t by cubic formula
c safeguarded inside [tlower,tupper].
c-----------------------------------------
C beta1
      z1 = dble(fp) + dble(fpa) - 3.d0*dble(fa-f)/dble(ta-t)
      b  = z1 + dble(fp)
      print*, 'Cubic ',t, f, fp, ta, fa, fpa, tlower, tupper 
      print*, 'Cubic z1,b ',z1, b

c-----------------------------------------
c first compute the discriminant
c (without overflow)
c-----------------------------------------
      if (abs(z1).le.1.) then
C beta2
         discri = z1*z1-dble(fp)*dble(fpa)
         print*, 'Cubic abs(z1)< 1 ', abs(z1)
         if (discri .lt. 0.d0) then
            if (fp.lt.0.) t = tupper
            if (fp.ge.0.) t = tlower
            print*, 'ZZZ3 discri .lt. 0.d0 ',t, fp
            return
         else
            discri = dsqrt(discri)
         end if
      else
         discri = dble(fp)/z1
         discri = discri*dble(fpa)
         discri = z1-discri
         if (z1.ge.0.d0 .and. discri.ge.0.d0) then
            discri = dsqrt(z1)*dsqrt(discri)
         else if (z1.le.0.d0 .and. discri.le.0.d0) then
            discri = dsqrt(-z1)*dsqrt(-discri)
         else
            if (fp.lt.0.) t = tupper
            if (fp.ge.0.) t = tlower
            print*, 'ZZZ4 z1 gt 1 ',t, fp, z1, discri
            return
         end if
       print*, 'Cubic abs(z1)>1 ', abs(z1), discri
      end if

c-----------------------------------------
c discriminant nonnegative,
c compute solution (without overflow)
c-----------------------------------------
      if (t-ta .lt. 0.0) then
         discri = -discri
      end if

      sign = (t-ta)/abs(t-ta)
      if (sngl(b)*sign .gt. 0.0) then
         t    = t + fp*(ta-t)/sngl(b+discri)
         print*, 'Cubic sngl(b)*sign .gt. 0.0 ',
     &    sngl(b)*sign .gt. 0.0
      else
         den  = sngl(z1+b+dble(fpa))
         anum = sngl(b-discri)
         if (abs((t-ta)*anum).lt.(tupper-tlower)*abs(den)) then
            t = t + anum*(ta-t)/den
         else
            t = tupper
            print*, 'ZZZ5 '
         end if
      end if

            print*, 'ZZZ6 ', t
      t = max( t, tlower )
      t = min( t, tupper )
      
      return
      end
