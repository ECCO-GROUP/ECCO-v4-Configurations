#PBS -S /bin/csh
#2023-05-19
#An example script to automate optimization for three iterations.
# starting from first guess
##PBS -S /bin/csh
##PBS -l select=4:ncpus=40:model=sky_ele
#PBS -l walltime=2:00:00
#PBS -q devel
#PBS -j oe
##PBS -o ./
#PBS -m bea

# Set env variables and load modules
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

# Set run specific variables
set nprocs  = 96
set basedir = `pwd`
set inputdir = ${basedir}/input/

# Specify starting iteration number
set whichiter  = 0
# swhichiter is whichiter in string format 
set swhichiter =  `printf "%010d" ${whichiter}`
# Specify ending iteration number (doing 2 iterations at one shot)
# Make sure the specified walltime (walltime=240:00:00 above)
# is long enough for the estimated time of iterations.
# If not, increase walltime or reduce maxexec
@ maxexec = ${whichiter} + 2 
# Specify iteration number for the initial iteration (the iteration before a steepest descent)
# As we may have to restart iterations from a steepest descent from time to time,
# the initial iteration is not always iteration 0.
set offsetiter = 0
set runnm = 'v4r4_coldstart'
# Control directory that would store ecco_ctrl and ecco_cost files.
# The directory is empty for the initial iteration, but ecco_cost and ecco_ctrl files 
# will be copied to or generated in this directory.
set ctrldir = ${basedir}/ctrlvec.${runnm}
# Optimization directory where the optimization generates ecco_ctrl for next iteration
set optimdir = ${basedir}/optim.${runnm}
# If not exist, create them
if ( ! -d ${ctrldir} ) then
  mkdir ${ctrldir}
endif
if ( ! -d ${optimdir} ) then
  mkdir ${optimdir}
endif
# Also copy some namelists and executable for optimization
cp -p ${basedir}/optim/data* ${optimdir}
cp -p ${basedir}/optim/optim.x ${optimdir}

# Loop through iterations
while ( ${whichiter} <= ${maxexec} )
# Set unpack to 1 means optimization uses ecco_ctrl from the previous iteration.
  set unpack = 1
# force unpack = 0 for the initial iteration, since there is no ecco_ctrl file.
  if ( ${whichiter} == ${offsetiter} ) set unpack = 0
# previous iteration number
  @ iterm1 = ${whichiter} - 1
# current and previous iteration numbers (10-digit string)
  set yiter=`printf "%04d" ${whichiter}`
  set yiterm1=`printf "%04d" ${iterm1}`
# If ${unpack} == 0 or if it is the initial iteration, skip generating ecco_ctrl. 
# We will be using xx files instead. 
  if ( ${unpack} == 0) goto skip_optim
  if ( (${whichiter} == 0 || ${whichiter} == ${offsetiter}) && ${unpack} == 0) goto skip_optim

# Now do the optimization
  cd ${optimdir}
# If ecco_ctrl exists, skip optim and start the run
  if ( -e ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiter} ) goto skip_optim
# Otherwise, generate ecco_ctrl for the run
  @ optimcycle = ${whichiter} - ( ${offsetiter} + 1 )
  @ nextcycle = ${optimcycle} + 1
  set yoptimcycle = `printf "%04d" ${optimcycle}`
  set ynextcycle =  `printf "%04d" ${nextcycle}`
# Abort if previous iteration's ecco_ctrl or ecco_cost is misssing
  if ( ! -e ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiterm1} || ! -e ${ctrldir}/ecco_cost_MIT_CE_000.opt${yiterm1} ) then
    echo 'run aborted'
    exit
  endif
# Link previous iteration's ecco_ctrl or ecco_cost
  ln -s ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiterm1} ecco_ctrl_MIT_CE_000.opt${yoptimcycle}
  ln -s ${ctrldir}/ecco_cost_MIT_CE_000.opt${yiterm1} ecco_cost_MIT_CE_000.opt${yoptimcycle}
# Update optimcyle in data.optim
ex - data.optim >> /dev/null <<EOF
/optimcycle=
c
 optimcycle=${optimcycle},
.
w
q
EOF

  if ( ${optimcycle} == 0 ) then
# Specify fmin for iteration 1 (i.e. current iteration # is 0)
ex - data.optim >> /dev/null <<EOF
/fmin=
c
 fmin=${fmin},
.
w
q
EOF
  endif

# Save data.optim from previous iteration
  \cp data.optim data.optim_i${iterm1}
# Now generate ecco_ctrl 
# optim.x can be generated following 
# https://github.com/ECCO-GROUP/ECCO-v4-Configurations/tree/master/ECCOv4%20Release%204/optimization
# Or one can use their own version of optimi.x
  ./optim.x >! op_i${iterm1}
# OPWARMI will be overwritten at each iteration. So save a copy here.
  \cp -f OPWARMI OPWARMI.${iterm1}
# Move the new ecco_ctrl to ${ctrldir}
  \mv ecco_ctrl*.opt${ynextcycle} ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiter}

  skip_optim:
# Now run the model 
  if ( -d ${basedir}/run.v4_rls5.${runnm}.iter${whichiter} ) then
      echo 'run.v4_rls5.${runnm}.iter${whichiter} exists.'
      echo 'remove it and restart the run'
      exit 999
  endif
  mkdir ${basedir}/${runnm}.iter${whichiter}
  cd ${basedir}/${runnm}.iter${whichiter}
  rm -rf tapes/tapes*
# Link input files
  ln -s ../namelist/* .
  ln -s ${inputdir}/input_init/error_weight/data_error/* .
  ln -s ${inputdir}/input_init/* .
  ln -s ${inputdir}/data_constraints/data_error/*/* .
  ln -s ${inputdir}/data_constraints/*/* .
  ln -s ${inputdir}/input_forcing/unadjusted/eccov4r4* .
  ln -s ${inputdir}/input_forcing/other/*.bin .
  ln -s ${inputdir}/input_forcing/control_weights/* .
  ln -s ${inputdir}/input_forcing/control_weights/atm_ctrls/* .
  ln -s ${inputdir}/native_grid_files/tile*.mitgrid .
  python ../scripts/mkdir_subdir_diags.py

# namelist for starting from iter0 and including atm controls 
  unlink data
  cp -p data.iter0.3d data
  unlink data.exf
  cp -p data.exf.iter0 data.exf
  unlink data.gmredi 
  cp -p data.gmredi.iter0 data.gmredi

  if ( ${whichiter} == 0 ) then
     unlink data.ctrl 
     cp -p data.ctrl.iter0.inclatmctrl data.ctrl
  else if ( ${whichiter} == ${offsetiter} && ${unpack} == 0) then 
     unlink data.ctrl 
     cp -p data.ctrl_itXX.inclatmctrl data.ctrl
  else
     unlink data.ctrl 
     cp -p data.ctrl.unpack.inclatmctrl data.ctrl
     #copy ecco_ctrl file to run directory
     \cp -f ${ctrldir}/ecco_ctrl*${whichiter}   .
  endif
#
  unlink data.optim
cat >! data.optim <<EOF
 &OPTIM
 optimcycle=${whichiter},
 &
EOF

# Start the run
  mpiexec -np ${nprocs} /u/scicon/tools/bin/mbind.x ../build/mitgcmuv_ad

# After the run successfully finishes, copy ecco_cost from
# run directory to the ctrldir directory for optimization
# to generate ecco_ctrl for next iteration
  rsync -av ecco_cost_MIT_CE_000.opt${yiter} ${ctrldir}
  rsync -av ecco_ctrl_MIT_CE_000.opt${yiter} ${ctrldir}
# Compute fmin (needed for data.optim during optimization)
  if (  ${whichiter} == 0 || ${whichiter} == ${offsetiter} ) then 
   set f0 = `grep " fc = " costfunction0000 | awk '{print $3}'`
   echo "To have 0.4% cost reduction, set fmin = 0.998 * f0" 
   set fmin = `echo "${f0} * 0.998" | bc`
   echo "fmin: "  ${fmin}
  endif
  cd ..
# Increase whichiter for next iteration
  @ whichiter = {$whichiter} + 1
  echo ${whichiter}
  end

