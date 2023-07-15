#PBS -S /bin/csh
#PBS -l select=5:ncpus=40:model=sky_ele
#PBS -l walltime=8:00:00
#PBS -j oe
#PBS -o ./
#PBS -m bea

# Load modules and set evn variables
limit stacksize unlimited
module purge
module load comp-intel/2020.4.304 
module load mpi-hpe/mpt
module load hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
module list

setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}
setenv FORT_BUFFERED 1
setenv MPI_BUFS_PER_PROC 128
setenv MPI_DISPLAY_SETTINGS

set nprocs  = 96
set basedir = `pwd`
set inputdir = ../input/

# Check & remove existing run, if present, for a fresh start 
if ( -d ${basedir}/run) then
  echo 'Directory "run" exists.'
  echo 'Please rename/remove it and re-submit the job.'
  exit 1
endif
mkdir ${basedir}/run
cd ${basedir}/run

# Link input files
# IMPORTANT: link ../namelist_adjsen/ before ../namelist/
ln -s ../namelist_adjsen/* .
ln -s ../namelist/* .
ln -s ${inputdir}/input_init/error_weight/data_error/* .
ln -s ${inputdir}/input_init/* .
ln -s ${inputdir}/data_constraints/data_error/*/* .
ln -s ${inputdir}/data_constraints/*/* .
ln -s ${inputdir}/input_forcing/adjusted/eccov4r4* .
ln -s ${inputdir}/input_forcing/other/*.bin .
ln -s ${inputdir}/input_forcing/control_weights/* .
ln -s ${inputdir}/input_forcing/control_weights/atm_ctrls/* .
ln -s ${inputdir}/native_grid_files/tile*.mitgrid .

# Run the following two scripts: 
#  prepare_run.py: set up the run
#  mkdir_subdir_diags.py: create subdirectories for outputting diagnostics.
#   comment it out if no need to output diagnostics
python ../scripts/prepare_run_adjsen.py
python ../scripts/mkdir_subdir_diags.py

# Submit run
cp -p ../build/mitgcmuv_ad .
mpiexec -np ${nprocs} /u/scicon/tools/bin/mbind.x ./mitgcmuv_ad


