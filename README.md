# ECCOv4-Configurations

**Content:**

This repository contains documentation (doc/) and model configuration files (code/, namelist/) for official releases of the ECCO version 4 ocean and sea-ice state estimates.  Model configuration files allow users to reproduce the state estimate or  conduct new simulation experiments. 


## ECCO Version 4

ECCO Version 4 is the first multidecadal global ECCO product (Forget et al., 2015).  Unlike previous ECCO versions, Version 4 uses a nonlinear free surface formulation and real freshwater flux boundary condition, permitting a more accurate simulation of sea level change.  In addition to estimating forcing and initial conditions as done in earlier analyses, Version 4 estimates also adjusts the model’s mixing parameters that enables an improved fit to observations (Forget et al., 2015a). 

### Release 1: 1992-2011

The first official release of the ECCO Version 4 ocean and sea-ice state estimation system.  See Forget et al., 2015.
For the configurations for ECCOv4 Release 1 and Release 2, please see the ECCOv4 github page:
https://github.com/gaelforget/ECCOv4

### Release 2: 1992-2011

ECCO version 4 release 2 is a minor update of the original ECCO version 4 solution (Forget et al., 2015) that benefits from a few additional corrections and improvements listed in Forget et al. (2016) including geothermal heating and an adjusted global mean precipitation to better match observed global mean sea level time-series observations. 

For the configurations for ECCOv4 Release 1 and Release 2, please see the ECCOv4 github page:
https://github.com/gaelforget/ECCOv4


### Release 3: 1992-2015

ECCO version 4 release 3 extends the estimation time period through 2015, includes new observational data: Aquarius, GRACE, Arctic T, S profiles, sea-ice concentration, global mean sea level & ocean mass.  Model controls now include initial u, v, ssh.  In addition, atmospheric model controls are separated into time-invariant & time-dependent variables.  See [v4r3_summary.pdf](https://github.com/ECCO-GROUP/ECCOv4-Configurations/blob/master/ECCOv4%20Release%203/doc/v4r3_summary.pdf) for more details.

### Release 4: 1992-2017

ECCO version 4 release 4 extends the estimation time period through 2017, includes new/updated observational data: GRACE ocean bottom pressure, altimetry sea surface height, in situ temperature/salinity profiles, Aquarius sea surface salinity, sea surface temperature, sea-ice concentration, mean dynamic topography, global mean sea level & ocean mass.

The atmosphere pressure forcing is added to the estimate post optimization. The product has daily outputs of the estimate, including budget terms, to allow for daily budget calculations.

### devel: 
The devel directory contains pieces of code that are useful, but not checked into the main MITgcm repository. 

## Support

If user support is needed, please contact ecco-support@mit.edu or  mitgcm-support@mit.edu.


## References

**References:**

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2015: ECCO version 4: an integrated framework for non-linear inverse modeling and global ocean state estimation. Geoscientific Model Development, 8, 3071-3104, <http://dx.doi.org/10.5194/gmd-8-3071-2015>, <http://www.geosci-model-dev.net/8/3071/2015/>

Forget, G., J.-M. Campin, P. Heimbach, C. N. Hill, R. M. Ponte, and C. Wunsch, 2016: ECCO Version 4: Second Release, <http://hdl.handle.net/1721.1/102062>, [direct download](https://dspace.mit.edu/bitstream/handle/1721.1/102062/standardAnalysis.pdf?sequence=1&isAllowed=y)
