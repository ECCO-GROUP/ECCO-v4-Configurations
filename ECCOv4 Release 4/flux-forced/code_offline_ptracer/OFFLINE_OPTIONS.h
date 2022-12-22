C $Header: /u/gcmpack/MITgcm/pkg/offline/OFFLINE_OPTIONS.h,v 1.3 2011/12/24 01:09:39 jmc Exp $
C $Name:  $

#ifndef OFFLINE_OPTIONS_H
#define OFFLINE_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_OFFLINE

CBOP
C    !ROUTINE: OFFLINE_OPTIONS.h
C    !INTERFACE:

C    !DESCRIPTION:
c options for offline package
CEOP

#undef NOT_MODEL_FILES

C o Conduct offline adjoint runs
C o All precomputed model state files should be backward in time
C o i.e., 1st file for an offline adjount run is actually the last
C o file saved by a forward simulation
C o (created by users).
C o  Also, velocity sign is reversed in the code.
C#define OFFLINE_ADJOINT

#endif /* ALLOW_OFFLINE */
#endif /* OFFLINE_OPTIONS_H */
