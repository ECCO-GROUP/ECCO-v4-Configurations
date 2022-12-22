# Instructions for compiling and running offline passive tracer
This MITgcm package was designed to provide online adjustments to model runs such that modeled mean sea level is consistent with a prescribed set of observations.

## Overview
Offline passive tracer uses prescribed (thus "offline") model circulation and mixing parameters to integrate passive tracer in time. Because there is no time stepping for model state, running offline passive tracer can be much faster than running "online" passive tracer where the model state is computed on the fly. 
  
Offline passive tracer in this repository is implemented as part of the flux-forced version of ECCO Version 4 Release 4 (V4r4) for both forward and adjoint passive tracer. Adjoint passive tracer is approximated following Fukumori et al. (2004).

The prescribed model circulation and mixing parameters are 7-day means from ECCO V4r4. The fields includes velocity, convection, GM mixing tensor, GM bolus velocity stream function, and GGL90 vertical diffusivity. 

Compiling and running offline passive tracer is similar to that for the flux-forced version of V4r4 (Wang et al., 2021). A few changes from those for the flux-forced V4r4 are listed below. 

### Forward passive tracer 

- Compile 
  - Use files in ``code_offline_ptracer`` for patch code instead of ``code`` for custom code
- Run
  - Use ``namelist_offline_ptracer`` instead of ``namelist`` for input name list files
  - ECCO V4r4's 7-day mean circulation and mixing parameters are available at https://ecco.jpl.nasa.gov/drive/files/Version4/Release4/other/flux-forced/state_weekly. The fields are organized by variable (subdirectory). Download all variables (and keep the directory structure) to your local machine. When running the model, make them accessible to a run by linking all variables into your run directory.  
  - Initializing tracer by creating a single-precision, 3d file on the model grid. Specify whatever tracer value one wants to the region one wants to release tracer and zero elsewhere. Create a link to this file with the name "theta_init_V4r4.bin" in the run directory.
  - Monthly mean (ptracer_mon_mean) and snapshot (ptracer_mon_mean) of tracer distribution are output to diags/ by the MITgcm diagnostics package. 
  - Because there is no time stepping for model state, forcing files for the flux-forced V4r4 are *not* needed for running offline passive tracer.
       
### Adjoint passive tracer 
  (to be added)

### References:

Fukumori, I., T. Lee, B. Cheng, and D. Menemenlis, 2004: The origin, pathway, and destination of Niño3 water estimated by a simulated passive tracer and its adjoint, J. Phys. Oceanogr., 34, 582-604, doi:10.1175/2515.1.

Wang, O., I. Fukumori, and I. Fenty, 2021: Configuration for flux-forced version of ECCO V4r4. Available at https://github.com/ECCO-GROUP/ECCO-v4-Configurations/blob/master/ECCOv4%20Release%204/flux-forced/doc/Config_fluxforced.pdf.
