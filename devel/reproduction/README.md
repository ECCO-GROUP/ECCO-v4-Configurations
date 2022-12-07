
ECCO download and build utility scripts
---------------------------------------

The eget (ECCO "get") and eadd (ECCO ancillary data download) scripts allow one
to automatically perform the download steps described in Sections 1 through
4 in "Instructions for reproducing ECCO Version 4 Release 4, v1.0", Wang and
Fenty, 2022. These same download steps are also referenced in "Instructions
for conducting adjoint runs based on ECCO Version 4 Release 4, v1.0", Wang,
2022. Additionally, the ebld (ECCO "build") utility performs the forward
model compilation step in Section 5 of Wang and Fenty 2022, and the adjoint
model build in Section 2 of Wang 2022. eget, ead, and ebld reference ecfg
(ECCO configuration) for consistent configuration variable setup (V4r4 on
Pleiades only, at present, but easily extended to others).

To configure, make sure eget, eadd, ebld, and ecfg have either been copied
to a directory listed in your PATH environment variable (e.g., ~/bin), or
add the name of the directory in which they are located to PATH.  Thereafter,
all that is required in order to reproduce the directory structure diagrammed
at the end of Section 4 is:

    $ eget -v 4 -r 4 dir

where dir is the name of, in this case, an ECCOV4r4 working directory to
be created.  If not provided, eget will prompt you for your NASA Earthdata
username and password (-u and -p options), and will call eadd (which can
also be called separately) to download the ECCO ancillary data hosted on
PO.DACC. By default, all downloaded zipped tarballs will be deleted after
extraction, unless explicitly saved using the -k (keep) option.

After verifying the default settings provided in ecfg are applicable to your
system (module list and optfile), forward or adjoint/optimization code builds
can be performed using:

    $ ebld -v 4 -r 4 dir        # forward model only
    $ ebld -v r -r 4 -a dir     # adjoint and optimization code

where dir is the same top-level directory name used with eget. Note that
adjoint code compilation requires a TAF (Transformation of Algorithms in
Fortran) license from FastOpt (fastopt.com).

Command-line help is available for all scripts via the -h command-line option.
