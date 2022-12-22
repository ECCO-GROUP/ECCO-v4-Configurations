C $Header: /u/gcmpack/MITgcm/pkg/ptracers/PTRACERS_PARAMS.h,v 1.14 2016/09/15 14:39:49 jahn Exp $
C $Name:  $

#ifdef ALLOW_PTRACERS

CBOP
C    !ROUTINE: PTRACERS_PARAMS.h
C    !INTERFACE:
C #include PTRACERS_PARAMS.h

C    !DESCRIPTION:
C Contains passive tracer parameters.

CEOP

#ifdef ALLOW_PTRACERS_EXF
C set PTRACERS_MAX_LAT_INC = MAX_LAT_INC = 1279
      INTEGER PTRACERS_MAX_LAT_INC
      PARAMETER(PTRACERS_MAX_LAT_INC = 1279)
      INTEGER sfftracstartdate1(PTRACERS_num)
      INTEGER sfftracstartdate2(PTRACERS_num)
      _RL     sfftracStartTime(PTRACERS_num)
      _RL     sfftracperiod(PTRACERS_num)
      _RL     sfftracRepCycle(PTRACERS_num)
      _RL     sfftracconst(PTRACERS_num)
      _RL     sfftrac_exfremo_intercept(PTRACERS_num)
      _RL     sfftrac_exfremo_slope(PTRACERS_num)
      _RL     exf_inscal_sfftrac(PTRACERS_num)
      _RL sfftrac_lon0(PTRACERS_num), sfftrac_lon_inc(PTRACERS_num)
      _RL sfftrac_lat0(PTRACERS_num)
      _RL sfftrac_lat_inc(PTRACERS_MAX_LAT_INC, PTRACERS_num)
      INTEGER sfftrac_nlon(PTRACERS_num), sfftrac_nlat(PTRACERS_num)
      INTEGER sfftrac_interpMethod(PTRACERS_num)

      character*1 sfftracmask(PTRACERS_num)

      character*(128) sfftracfile(PTRACERS_num)
#endif

C--   COMMON /PTRACERS_PARAMS_R/ PTRACERS real-type parameters:
C     PTRACERS_dTLev    :: Timestep for ptracers ( s ), function of level k
C     PTRACERS_taveFreq :: Frequency with which time-averaged PTRACERS
C                          are written to post-processing files.
C     PTRACERS_ref      :: vertical profile for passive tracers, in
C                          analogy to tRef and sRef, hence the name
C     PTRACERS_EvPrRn   :: tracer concentration in Rain, Evap & RunOff
C       notes: a) used if both NonLin_FrSurf & useRealFreshWater are set.
C              b) use pTracer surface (local) value if = UNSET_RL (default)
C     PTRACERS_startStepFwd :: time to start stepping forward this tracer
C     PTRACERS_resetFreq    :: Frequency (s) to reset ptracers to original val
C     PTRACERS_resetPhase   :: Phase (s) to reset ptracers

      _RL PTRACERS_dTLev(Nr)
      _RL PTRACERS_dumpFreq
      _RL PTRACERS_taveFreq
      _RL PTRACERS_monitorFreq
      _RL PTRACERS_diffKh(PTRACERS_num)
      _RL PTRACERS_diffK4(PTRACERS_num)
      _RL PTRACERS_diffKrNr(Nr,PTRACERS_num)
      _RL PTRACERS_ref(Nr,PTRACERS_num)
      _RL PTRACERS_EvPrRn(PTRACERS_num)
      _RL PTRACERS_startStepFwd(PTRACERS_num)
      _RL PTRACERS_resetFreq(PTRACERS_num)
      _RL PTRACERS_resetPhase(PTRACERS_num)
      COMMON /PTRACERS_PARAMS_R/
#ifdef ALLOW_PTRACERS_EXF
     &       sfftracconst,       sfftracRepCycle,
     &       sfftracperiod,      sfftracStartTime,
     &       sfftrac_exfremo_intercept,
     &       sfftrac_exfremo_slope,
     &                      exf_inscal_sfftrac,
     & sfftrac_lon0, sfftrac_lon_inc,
     & sfftrac_lat0, sfftrac_lat_inc,

#endif
     &     PTRACERS_dTLev,
     &     PTRACERS_dumpFreq,
     &     PTRACERS_taveFreq,
     &     PTRACERS_monitorFreq,
     &     PTRACERS_diffKh,
     &     PTRACERS_diffK4,
     &     PTRACERS_diffKrNr,
     &     PTRACERS_ref,
     &     PTRACERS_EvPrRn,
     &     PTRACERS_startStepFwd,
     &     PTRACERS_resetFreq,
     &     PTRACERS_resetPhase

#ifdef ALLOW_COST
C     COMMON /PTRACERS_OLD_R/ Old (real type) PTRACERS parameters
C        (to be removed 1 day ...)
      _RL lambdaTr1ClimRelax
      COMMON /PTRACERS_OLD_R/
     &     lambdaTr1ClimRelax
#endif

C--   COMMON /PTRACERS_PARAMS_I/ PTRACERS integer-type parameters:
C     PTRACERS_numInUse :: number of tracers to use
C     PTRACERS_Iter0    :: timestep number when tracers are initialized
      INTEGER PTRACERS_Iter0
      INTEGER PTRACERS_numInUse
      INTEGER PTRACERS_advScheme(PTRACERS_num)
      COMMON /PTRACERS_PARAMS_I/
#ifdef ALLOW_PTRACERS_EXF
     &       sfftracstartdate1,  sfftracstartdate2,
     & sfftrac_nlon, sfftrac_nlat, sfftrac_interpMethod,

#endif
     &     PTRACERS_Iter0,
     &     PTRACERS_numInUse,
     &     PTRACERS_advScheme

C--   COMMON /PTRACERS_PARAMS_L/ PTRACERS logical-type parameters:
C     PTRACERS_ImplVertAdv   :: use Implicit Vertical Advection for this tracer
C     PTRACERS_MultiDimAdv   :: internal flag (depend on the advection scheme),
C                               true if this tracer uses Multi-Dim advection
C     PTRACERS_SOM_Advection :: internal flag (depend on the advection scheme),
C                               true if this tracer uses 2nd-order moment advection
C     PTRACERS_AdamsBashGtr  :: internal flag (depend on the advection scheme),
C                               true if applies Adams-Bashforth on tracer tendency
C     PTRACERS_AdamsBash_Tr  :: internal flag (depend on the advection scheme),
C                               true if applies Adams-Bashforth on passive Tracer
C     PTRACERS_useGMRedi(n)  :: true if GM-Redi applies to pTracer n
C     PTRACERS_useDWNSLP(n)  :: true if Down-Sloping flow applies to pTracer n
C     PTRACERS_useKPP(n)     :: true if KPP applies to pTracer n
C     PTRACERS_doAB_onGpTr   :: if Adams-Bashforth time stepping is used, apply
C                               AB on tracer tendencies (rather than on Tracers)
C     PTRACERS_addSrelax2EmP :: add Salt relaxation to EmP
C     PTRACERS_startAllTrc   :: internal flag, all tracers start at startTime
C     PTRACERS_calcSurfCor   :: calculate Linear Free-Surf source/sink of tracer
C                               (set internally)
C     PTRACERS_linFSConserve :: apply mean Free-Surf source/sink at surface
C     PTRACERS_useRecords    :: snap-shot output: put all pTracers in one file
      LOGICAL PTRACERS_ImplVertAdv(PTRACERS_num)
      LOGICAL PTRACERS_MultiDimAdv(PTRACERS_num)
      LOGICAL PTRACERS_SOM_Advection(PTRACERS_num)
      LOGICAL PTRACERS_AdamsBashGtr(PTRACERS_num)
      LOGICAL PTRACERS_AdamsBash_Tr(PTRACERS_num)
      LOGICAL PTRACERS_useGMRedi(PTRACERS_num)
      LOGICAL PTRACERS_useDWNSLP(PTRACERS_num)
      LOGICAL PTRACERS_useKPP(PTRACERS_num)
      LOGICAL PTRACERS_linFSConserve(PTRACERS_num)
      LOGICAL PTRACERS_doAB_onGpTr
      LOGICAL PTRACERS_addSrelax2EmP
      LOGICAL PTRACERS_startAllTrc
      LOGICAL PTRACERS_calcSurfCor
      LOGICAL PTRACERS_useRecords
      LOGICAL
     &     PTRACERS_monitor_mnc, PTRACERS_monitor_stdio,
     &     PTRACERS_timeave_mdsio, PTRACERS_snapshot_mdsio,
     &     PTRACERS_pickup_write_mdsio, PTRACERS_pickup_read_mdsio,
     &     PTRACERS_timeave_mnc, PTRACERS_snapshot_mnc,
     &     PTRACERS_pickup_write_mnc, PTRACERS_pickup_read_mnc
      COMMON /PTRACERS_PARAMS_L/
     &     PTRACERS_ImplVertAdv,
     &     PTRACERS_MultiDimAdv,
     &     PTRACERS_SOM_Advection,
     &     PTRACERS_AdamsBashGtr, PTRACERS_AdamsBash_Tr,
     &     PTRACERS_useGMRedi,
     &     PTRACERS_useDWNSLP,
     &     PTRACERS_useKPP,
     &     PTRACERS_linFSConserve,
     &     PTRACERS_doAB_onGpTr,
     &     PTRACERS_addSrelax2EmP,
     &     PTRACERS_startAllTrc,
     &     PTRACERS_calcSurfCor,
     &     PTRACERS_useRecords,
     &     PTRACERS_timeave_mdsio, PTRACERS_snapshot_mdsio,
     &     PTRACERS_pickup_write_mdsio, PTRACERS_pickup_read_mdsio,
     &     PTRACERS_monitor_stdio, PTRACERS_monitor_mnc,
     &     PTRACERS_timeave_mnc, PTRACERS_snapshot_mnc,
     &     PTRACERS_pickup_write_mnc, PTRACERS_pickup_read_mnc

C--   COMMON /PTRACERS_PARAMS_C/ PTRACERS character-type parameters:
      CHARACTER*(MAX_LEN_FNAM) PTRACERS_initialFile(PTRACERS_num)
      CHARACTER*(MAX_LEN_FNAM) PTRACERS_names(PTRACERS_num)
      CHARACTER*(MAX_LEN_FNAM) PTRACERS_long_names(PTRACERS_num)
      CHARACTER*(MAX_LEN_FNAM) PTRACERS_units(PTRACERS_num)
      COMMON /PTRACERS_PARAMS_C/
#ifdef ALLOW_PTRACERS_EXF
     &       sfftracfile,    sfftracmask,
#endif
     &     PTRACERS_initialFile,
     &     PTRACERS_names,
     &     PTRACERS_long_names,
     &     PTRACERS_units

C     COMMON /PTRACERS_LABELS/ holds pTracers labels
C     PTRACERS_ioLabel  :: pTracer I/O & diagnostics label (2 charecters long)
      COMMON /PTRACERS_LABELS/
     &     PTRACERS_ioLabel
      CHARACTER*2              PTRACERS_ioLabel(PTRACERS_num)

#endif /* ALLOW_PTRACERS*/

CEH3 ;;; Local Variables: ***
CEH3 ;;; mode:fortran ***
CEH3 ;;; End: ***
