# Instructions for compiling and running offline passive tracer
This MITgcm package was designed to provide online adjustments to model runs such that modeled mean sea level is consistent with a prescribed set of observations.

## Overview
Offline passive tracer uses prescribed (thus "offline") model circulation and mixing paraemters to integrate passive tracer in time. Because there is no time stepping for model state, running offline passive tracer can be much faster than running "online" passive tracer where the model state is computed on the fly. 
  
Offline passive tracer is implemented as part of the flux-forced version of ECCO Version 4 Release 4 for both forward and adjoint passive tracer. In partilcular, adjoint passive tracer is approximated following Fukumori et al. (2004, JPO, https://doi.org/10.1175/2515.1).

Compiling and running offline passive tracer is similar to running flux-forced V4r4. 
