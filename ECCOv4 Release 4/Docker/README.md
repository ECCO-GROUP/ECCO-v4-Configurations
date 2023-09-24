
This [Docker image configuration](https://www.docker.com) makes it easy to reproduce the [ECCO v4r4](https://ecco-group.org) state estimate.

It includes :

- gfortran, MPI, and NetCDF libraries needed to compile and run the MITgcm
- bash script to download the 
  1. [MITgcm](https://github.com/MITgcm/MITgcm) [checkpoint 66g](https://github.com/MITgcm/MITgcm/releases/tag/checkpoint66g)
  2. [ECCOv4-py Configuration files](https://github.com/ECCO-GROUP/ECCO-v4-Configurations)

Future versions will include Jupyter hub and the [ECCOv4-py Python Library](https://github.com/ECCO-GROUP/ECCOv4-py).


## Directions

To use on your local computer

You will need [Docker Desktop](https://docs.docker.com/desktop/) installed. 

To build your own image, go into the directory ECCO-Docker/ECCO_v4r4 and run

```
docker build -t ecco_v4r4_docker_image .
```

If your computer is a Mac that uses ARM-based chips (such as M1), use the following command to build the image:
  
```
docker build -t ecco_v4r4_docker_image . --build-arg="CHIP_ARCT=aarch64"
```

To run the image do

```
docker run -t -i --rm ecco_v4r4_docker_image bash
```

After running you will be in an interactive bash shell.  

To compile the MITgcm code first need to define SIZE.h a model configuration file in the ```ECCOV4/release4/code``` directory that specifies the number of cpus on your machine. We included a few SIZE.h_NN files for different number of cpus (NN). 

After you have a SIZE.h file then go to the ```/home/ecco/ECCOV4/release4/build``` directory and build the model code: 

```
>$ROOTDIR/tools/genmake2 -mods=../code -of=~/docker_src/linux_amd64_gfortran -mpi
>make -j depend
>make -j
``` 

The result will be an executable ```mitgcmuv```. 

To run the model you will need to link all the binary files as described in the
Instructions for reproducing ECCO Version 4 Release 4 [[https://doi.org/10.5281/zenodo.7789915](https://doi.org/10.5281/zenodo.7789915) document.
