# Configuration for flux-forced version of ECCO V4r4
Ou Wang, Ichiro Fukumori, and Ian Fenty

## Introduction
This configuration is for a flux-forced version of ECCO Version 4 Release 4 (v4r4) that would
produce results of a forward simulation run equivalent to v4r4.
ECCO v4r4 uses the bulk-formula to compute the air-sea fluxes as well as the ice-ocean and iceatmosphere
fluxes. The fluxes would change along with underling ocean and/ice states. In
contrast, a flux-forced configuration reads in pre-computed fluxes from files and therefore the
fluxes are independent upon the underlining ocean/sea-ice states. This character of the fluxforced
configuration is useful when one wants to separate contributions of various fluxes to a
particular ocean quantity. Potential usage includes forward sensitivity experiments, adjoint
reconstruction, and others.
It is assumed that a user has been successfully reproduced ECCO v4r4 as described in
https://ecco.jpl.nasa.gov/drive/files/Version4/Release4/doc/v4r4_reproduction_howto.pdf. The
steps to conduct a flux-forced run is similar to those for v4r4, with some significant changes as
described below.
Introdcution
This README file describes offline passive tracer configurations, for both forward and adjoint, that are based on ECCO Version 4 Release 4 (V4r4). An overview of the tracer configurations is provided, followed by instructions on how to compile and run offline passive tracer. 

