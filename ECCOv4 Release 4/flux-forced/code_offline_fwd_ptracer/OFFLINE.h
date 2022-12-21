C $Header: /u/gcmpack/MITgcm/pkg/offline/OFFLINE.h,v 1.13 2015/07/16 21:21:18 jmc Exp $
C $Name:  $

#ifdef  ALLOW_OFFLINE
C     !ROUTINE: OFFLINE.h
C -------------------------------
C   OFFLINE.h
C  variable for forcing offline tracer
C -------------------------------

C-- Offline parameters:

C-  Forcing files
      COMMON /OFFLINE_PARAMS_C/
     &       UvelFile, VvelFile, WvelFile, ThetFile, Saltfile,
     &       ConvFile, KPP_DiffSFile, KPP_ghatKFile,
     &       GMwxFile, GMwyFile, GMwzFile,
#ifndef ALLOW_OFFLINE_DIST_FLUXFILES
     &       HFluxFile, SFluxFile, IceFile
#else
     &       HFlxFile, SFlxFile, IceFile
#endif
     &      ,GGL90diffKrFile, 
     &      GM_PsiXFile, GM_PsiYFile
      CHARACTER*(MAX_LEN_FNAM) UvelFile
      CHARACTER*(MAX_LEN_FNAM) VvelFile
      CHARACTER*(MAX_LEN_FNAM) WvelFile
      CHARACTER*(MAX_LEN_FNAM) ThetFile
      CHARACTER*(MAX_LEN_FNAM) SaltFile
      CHARACTER*(MAX_LEN_FNAM) ConvFile
      CHARACTER*(MAX_LEN_FNAM) KPP_DiffSFile
      CHARACTER*(MAX_LEN_FNAM) KPP_ghatKFile
      CHARACTER*(MAX_LEN_FNAM) GMwxFile
      CHARACTER*(MAX_LEN_FNAM) GMwyFile
      CHARACTER*(MAX_LEN_FNAM) GMwzFile
      CHARACTER*(MAX_LEN_FNAM) GM_PsiXFile
      CHARACTER*(MAX_LEN_FNAM) GM_PsiYFile
#ifndef ALLOW_OFFLINE_DIST_FLUXFILES
      CHARACTER*(MAX_LEN_FNAM) HFluxFile
      CHARACTER*(MAX_LEN_FNAM) SFluxFile
#else
      CHARACTER*(MAX_LEN_FNAM) HFlxFile
      CHARACTER*(MAX_LEN_FNAM) SFlxFile
#endif
      CHARACTER*(MAX_LEN_FNAM) IceFile
      CHARACTER*(MAX_LEN_FNAM) GGL90diffKrFile

C Need extra GM terms when GM_NON_UNITY_DIAGONAL and GM_EXTRA_DIAGONAL are defined
      COMMON /OFFLINE_PARAMS_C2/
     &       GMuxFile, GMvyFile, GMuzFile, GMvzFile
      CHARACTER*(MAX_LEN_FNAM) GMuxFile
      CHARACTER*(MAX_LEN_FNAM) GMvyFile
      CHARACTER*(MAX_LEN_FNAM) GMuzFile
      CHARACTER*(MAX_LEN_FNAM) GMvzFile

      COMMON /OFFLINE_PARAMS_I/
     &       offlineLoadPrec,
     &       offlineIter0
      INTEGER offlineLoadPrec
      INTEGER offlineIter0

      COMMON /OFFLINE_PARAMS_R/
     &       deltaToffline, offlineTimeOffset,
     &       offlineForcingPeriod, offlineForcingCycle
      _RL deltaToffline
      _RL offlineTimeOffset
      _RL offlineForcingPeriod
      _RL offlineForcingCycle

C---+----1----+----2----+----3----+----4----+----5----+----6----+----7-|--+----|
C-- Offline variables:

C     offlineLdRec :: time-record currently loaded (in temp arrays *[1])
      COMMON /OFFLINE_VARS_I/
     &       offlineLdRec
      INTEGER offlineLdRec(nSx,nSy)

      COMMON /OFFLINE_VARS_R/
c    &       ConvectCount, ICEM,
     &       offline_Wght
c     _RL ICEM(1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RS ConvectCount(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RL offline_Wght(2,nSx,nSy)

C     Forcing fields:
C     uvel[01]  :: Temp. for u
C     vvel[01]  :: Temp. for v
C     wvel[01]  :: Temp. for w
C     conv[01]  :: Temp for Convection Count
C     [01]      :: End points for interpolation
C     Above use static heap storage to allow exchange.
C     aWght, bWght :: Interpolation weights
      COMMON /OFFLINE_FFIELDS_R/
     &                 uvel0, uvel1, vvel0, vvel1, wvel0, wvel1,
     &                 tave0, tave1, save0, save1,
     &                 gmkx0, gmkx1, gmky0, gmky1, gmkz0, gmkz1,
     &                 conv0, conv1, kdfs0, kdfs1, kght0, kght1,
     &                 sflx0, sflx1
c    &               , hflx0, hflx1, icem0, icem1
#ifdef ALLOW_OFFLINE_LOAD_GGL90
     &               , ggl90diffkr0, ggl90diffkr1
#endif
#ifdef ALLOW_OFFLINE_LOAD_GM_PSI
     &               , GM_PsiX0, GM_PsiX1, GM_PsiY0, GM_PsiY1
#endif
      _RS  uvel0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  uvel1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  vvel0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  vvel1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  wvel0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  wvel1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  tave0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  tave1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  save0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  save1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmkx0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmkx1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmky0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmky1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmkz0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmkz1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
#ifdef ALLOW_OFFLINE_LOAD_GM_PSI
      _RS  GM_PsiX0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  GM_PsiX1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  GM_PsiY0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  GM_PsiY1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
#endif
      _RS  conv0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  conv1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  kdfs0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  kdfs1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  kght0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  kght1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  sflx0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
      _RS  sflx1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RS  hflx0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RS  hflx1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RS  icem0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
c     _RS  icem1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,nSx,nSy)
#ifdef ALLOW_OFFLINE_LOAD_GGL90
      _RS  ggl90diffkr0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  ggl90diffkr1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
#endif

C Need extra GM terms when GM_NON_UNITY_DIAGONAL and GM_EXTRA_DIAGONAL are defined
C The declaration can be put inside CPP options to save memory
      COMMON /OFFLINE_FFIELDS_R2/
     &                 gmix0, gmix1, gmjy0, gmjy1, 
     &                 gmiz0, gmiz1, gmjz0, gmjz1 
      _RS  gmix0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmix1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmjy0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmjy1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmiz0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmiz1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmjz0    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
      _RS  gmjz1    (1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr,nSx,nSy)
#endif /* ALLOW_OFFLINE*/
