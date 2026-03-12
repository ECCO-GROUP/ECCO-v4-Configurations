# Overview of `slr_corr`
This file provides an overview of the `slr_corr` package scripts.

## slr_corr_readparms.F
This file initializes the SLR_CORR namelists and reads in the pertinent values from the `data.slr_corr` file. The key variables to support the model adjustments of precipitation are the observational sea level record, its start date and time, and its period. The variables are carried to subsequent scripts in this package via the `SLR_CORR_PARAM.h` header file.

## slr_corr_init_fixed.F
This file reads in the prescibed sea level timeseries. This entire timeseries is carried throughout the model run in the `slrc_obs_timeseries` variable and provided to subsequent scripts via the `SLR_CORR_FIELDS.h` header file. 

## slr_corr_init_varia.F
For now, this file is a place-holder. The initial idea was to use this file to calculate the sea level rise adjustments but the calculation was moved to `slr_corr_adjust_precip.F`. If this approach is maintained, then `slr_corr_init_varia.F` can be deleted.

## slr_corr_adjust_precip.F
This script is where the magic happens. It begins by calculating the target sea level using data from the `slrc_obs_timeseries` variable. Next, it calculates an adjustment to be provided to the precipitation field which will accomodate a change in global sea level to the target level. Finally, the adjustment is applied to the precipitation field. For now, the adjustment is provided as a global constant but can/should be updated to be a scalar adjustment. When using MPI, this script will call exchanges between procs - proc 0 will collect sea level information from all other procs to calculate the required mean adjustment and then the adjustment will be sent to the other procs to apply it.
