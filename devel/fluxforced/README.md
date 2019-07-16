# fluxforced
Conducting flux-forced runs that are equivalent to ECCO v4r3 or llc270

This README file describes how to conduct a flux-forced forward run 
that is equivalent to ECCO v4r3 (llc90) or llc270. It is assumed that a user
has successfully reproduced ECCO v4r3 as described in 
ftp://ecco.jpl.nasa.gov/Version4/Release3/doc/v4r3_reproduction_howto.pdf.
Similar steps would be taken to conduct a flux-forced run for llc270,
assuming that a user knows how to conduct llc270 forward runs 
as described in  
http://wwwcvs.mitgcm.org/viewvc/MITgcm/MITgcm_contrib/ecco_darwin/v5_llc270/readme.txt?view=log

The purpose of fluxes forced runs is to eliminate any bulk-formulae fluxes 
so one could isolate the effect of an external forcing by removing the 
fluxes' dependence on ocean states. The current configuration for 
v4r3 and llc270 uses air-sea bulk-formulae and the sea-ice package, 
both of which would have ocean-state dependent fluxes. In a 
flux-forced run, both the air-sea bulk-formulae and sea-ice will
be turned off. 

The steps to conduct the flux-forced runs are as follows:

1) Generate the 6-hourly averaged fluxes using the sample data.diagnostics file in  
/nobackupp7/owang/FOR_OTHERS/fluxforced/input_generate_forcing/
This data.diagnostics would replace the one that a user used to produce 
v4r3 or llc270. Note that the freshwater diagnostics output oceFWflx includes 
the river runoff. Therefore, if one were to use the flux-forced run 
later to examine the effects of different river runoff products, one 
would need to turn off the river runoff forcing when generating the 6-hourly 
fluxes. Otherwise, one would have a double-count of the river runoff, one
implicit in oceFWflx and the other specified as an explicit
river runoff forcing in data.exf. 

2) Aggregate the 6-hourly files to yearly files 
See the sample script in 
/nobackupp7/owang/FOR_OTHERS/fluxforced/tools_generate_forcing/
cat_exf2yearly_fromavg_all.sh DIRIN and DIROUT
  where DIRIN and DIROUT are the input directory (where the 6-hourly files are)
  and output directory (where the yearly files would be), respectively.
cat_exf2yearly_fromavg_all.sh will make use of cat_exf2yearly_fromavg.sh in the 
same directory. 

3) Updated code for flux-forced runs
Use the following updated patchy code for the flux-forced runs.
For v4r3: use 
/nobackupp7/owang/FOR_OTHERS/fluxforced/code_fluxforced_v4r3
For llc270: use
/nobackupp7/owang/FOR_OTHERS/fluxforced/code_fluxforced_llc270

4) Updated namelists
A couple of updated name lists in 
/nobackupp7/owang/FOR_OTHERS/fluxforced/input_fluxforced/
need be used to conduct the flux-forced runs: 
data.exf: Use the pre-generated fluxes to force the model. Note that the 
 pre-generated sfluxfile is assumed to have contained runoff and therefore 
 runoff forcing is turned off here. Use data.exf_sflux_excl_runoff
 if sfluxfile does NOT contain runoff. 
data.exf_sflux_excl_runoff: If the pre-generated sfluxfile contains NO
 runoff, then runoff forcing needs to be included here. Need to rename 
 this file (data.exf_sflux_excl_runoff) to data.exf when run the model. 
data.pkg: Turn off the sea-ice, profile packages.

For all other namelists that are not in the above directory, use 
the original ones from v4r3 or llc270.



