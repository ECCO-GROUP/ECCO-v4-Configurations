# Configurations for flux-forced runs
The configurations can be used to conduct flux-forced runs that would produce
 results very similar to ECCO v4r3 or v5 (llc270) that uses bulk-formula. 

This README file describes how to conduct a flux-forced forward run 
that would produce results equivalent to ECCO v4r3 (llc90) or v5(llc270). 
It is assumed that a user has successfully reproduced ECCO v4r3 as described in 
ftp://ecco.jpl.nasa.gov/Version4/Release3/doc/v4r3_reproduction_howto.pdf.
Similar steps would be taken to conduct a flux-forced run for llc270,
assuming that a user knows how to conduct llc270 forward runs 
as described in  
http://wwwcvs.mitgcm.org/viewvc/MITgcm/MITgcm_contrib/ecco_darwin/v5_llc270/readme.txt?view=log

The purpose of fluxes forced runs is to eliminate any bulk-formulae fluxes 
so one could isolate the effect of an external forcing by removing the 
fluxes' dependence on ocean states. Such as ocean-states indepent fluxes 
would be useful in many applcations, including forward sensitivity experiments.
The current configuration for v4r3 and v5(llc270) uses air-sea bulk-formulae 
and the sea-ice package, both of which would have ocean-state dependent fluxes. 
In a flux-forced run, both the air-sea bulk-formulae and sea-ice will
be turned off. 

The steps to conduct the flux-forced runs are as follows:

1) Generate the 6-hourly averaged fluxes 

Use the sample data.diagnostics file in input_generate_forcing/
to generate the 6-hourly mean fluxes. This data.diagnostics 
would replace the one that a user normally uses to produce v4r3 
or v5 (llc270). Note that the freshwater diagnostics output 
oceFWflx includes the river runoff. Therefore, if one were to 
use the flux-forced run later to examine the effects of 
different river runoff products, one would need to turn off 
the river runoff forcing when generating the 6-hourly 
fluxes. Otherwise, one would have a double-count of the river 
runoff, one implicit in oceFWflx and the other specified as 
an explicit river runoff forcing in data.exf. 

2) Aggregate the 6-hourly files to yearly files 

See the sample script in 
tools_generate_forcing/cat_exf2yearly_fromavg_all.sh to
aggregate the 6-hourly forcing to yearly files. The usage is 

  cat_exf2yearly_fromavg_all.sh DIRIN and DIROUT

  where DIRIN and DIROUT are the input directory (where the 6-hourly files are)
  and output directory (where the yearly files would be), respectively.
cat_exf2yearly_fromavg_all.sh will make use of cat_exf2yearly_fromavg.sh in the 
same directory. 

3) Updated code for flux-forced runs

Use the following updated patchy code for the flux-forced runs.
* For v4r3: use 
code_fluxforced_v4r3
* For v5 (llc270): use
code_fluxforced_llc270

4) Updated namelists
A couple of updated name lists in input_fluxforced/
need be used to conduct the flux-forced runs. For all other 
namelists that are not in the above directory, use 
the original ones from v4r3 or v5.
* data.exf: Use the pre-generated fluxes to force the model. Note that the 
 pre-generated sfluxfile is assumed to have contained runoff and therefore 
 runoff forcing is turned off here. Use data.exf_sflux_excl_runoff
 if sfluxfile does NOT contain runoff. 
* data.exf_sflux_excl_runoff: If the pre-generated sfluxfile contains NO
 runoff, then runoff forcing needs to be included here. Need to rename 
 this file (data.exf_sflux_excl_runoff) to data.exf when run the model. 
* data.pkg: Turn off the sea-ice, profile packages.




