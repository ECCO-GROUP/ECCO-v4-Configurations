# Offline passive tracer
This README file describes offline passive tracer configurations, for both forward and adjoint, that are based on ECCO Version 4 Release 4 (V4r4). An overview of the tracer configurations is provided, followed by instructions on how to compile and run offline passive tracer. 

## Overview
Offline passive tracer uses prescribed (thus "offline") model circulation and mixing parameters to integrate passive tracer in time. Because there is no time stepping for model state, running offline passive tracer can be much faster than running "online" passive tracer where the model state is computed on the fly. 
  
Offline passive tracer in this repository is implemented as part of the flux-forced version of ECCO V4r4 for both forward and adjoint passive tracer. Adjoint passive tracer is approximated following Fukumori et al. (2004).

The prescribed model circulation and mixing parameters are 7-day means from ECCO V4r4. The fields includes velocity, convection, GM mixing tensor, GM bolus velocity stream function, and GGL90 vertical diffusivity. 

Compiling and running offline passive tracer is similar to that for the flux-forced version of V4r4 (Wang et al., 2021). A few changes from that for the flux-forced V4r4 are listed below. 

## Forward passive tracer 

- Compile 
  - Use files in ``code_offline_ptracer`` for patch code instead of ``code``. There are two extra versions for the header file OFFLINE_OPTIONS.h. OFFLINE_OPTIONS.h.fwd, which is the same as OFFLINE_OPTIONS.h, would be used for forward passive tracer, while OFFLINE_OPTIONS.h.adj is for adjoint passive tracer run (see "Compile" for adjoint passive tracer below). When compiling code for forward passive tracer, make sure OFFLINE_OPTIONS.h is the same as OFFLINE_OPTIONS.h.fwd. If not, copy OFFLINE_OPTIONS.h.fwd to OFFLINE_OPTIONS.h before compiling the code.
- Run
  - Use ``namelist_offline_ptracer`` instead of ``namelist`` for input name list files
  - ECCO V4r4's 7-day mean circulation and mixing parameters are available at https://ecco.jpl.nasa.gov/drive/files/Version4/Release4/other/flux-forced/state_weekly. The fields are organized by variable (subdirectory). Download ``state_weekly`` inclduing all subdirectories (and keep the directory structure the same) to your local machine. When running the model, make them accessible to a run by linking all variables into your run directory.  
  - Initializing tracer by creating a double-precision, 3d file on the model grid. Specify whatever tracer value one wants to the region one wants to release tracer and zero elsewhere. Name the file as pickup_ptracers.ZZZZZZZZZZ.data, where "ZZZZZZZZZZ" is a 10-digit nunber for Iter0 (as specified in the namelist file "data"), left padded with zeros. For example, if nIter0 is 1, then the filename is pickup_ptracers.0000000001.data. Copy or create a link to this file in the run directory.
  - Monthly mean (ptracer_mon_mean) and snapshot (ptracer_mon_mean) of tracer distribution are output to diags/ by the MITgcm diagnostics package. 
  - Because there is no time stepping for model state, forcing files for the flux-forced V4r4 are *not* needed for running offline passive tracer.
       
## Adjoint passive tracer 
Compiling and running offline adjoint passive tracer is very similar to that for offline forward passive tracer described above. The changes are as follows.
- Compile 
  - Same as that for forward passive tracer, but need to use a different version of the header file OFFLINE_OPTIONS.h. Copy OFFLINE_OPTIONS.h.adj to OFFLINE_OPTIONS.h and then compile the code in the same way as foward passive tracer.
- Run
  - The backward-in-time integration for offline adjoint passive tracer is implemented by creating a new set of 7-day mean files of model circulation and mixing parameters that are symbolic links to the original 7-day mean files from V4r4. For instance, the new ``uVeltave.0000227808.data`` would be a symbolic link to the original ``uVeltave.0000000000.data``. Two bash scripts (``reverseintime.sh`` and ``reverseintime_all.sh``; the latter will call the former) are provided in ``flux-forced/scripts`` for this purpose. Copy the two scripts to the parent directory of ``state_weekly`` that has the 7-day mean V4r4 files, and use ``sh -xv reverseintime_all.sh`` to create the new set of files (which are just symbolic links) in ``state_weekly_rev_time_227808``. The scripts are also capable of creating symbolic links for shorter runs by using ``sh -xv reverseintime_all.sh XYZ``, where ``XYZ`` is the largest time step of 7-day mean files over the shorter run. For example, ``sh -xv reverseintime_all.sh 8904`` would create a new set of files in ``state_weekly_rev_time_8904`` to force an offline adjoint passive integration backward in time over year 1992. See more descriptions in ``reverseintime_all.sh``. 
  - Once the new set of files are created, make all of the subdirectories under ``state_weekly_rev_time_227808`` (or something similar like ``state_weekly_rev_time_8904`` for the example short run) accessible to the run. 
  - The rest is the same as what is been described above for running forward passive tracer.

## References:

Fukumori, I., T. Lee, B. Cheng, and D. Menemenlis, 2004: The origin, pathway, and destination of Niño3 water estimated by a simulated passive tracer and its adjoint, J. Phys. Oceanogr., 34, 582-604, doi:10.1175/2515.1.

Wang, O., I. Fukumori, and I. Fenty, 2021: Configuration for flux-forced version of ECCO V4r4. Available at https://github.com/ECCO-GROUP/ECCO-v4-Configurations/blob/master/ECCOv4%20Release%204/flux-forced/doc/README_fluxforced.md. 
