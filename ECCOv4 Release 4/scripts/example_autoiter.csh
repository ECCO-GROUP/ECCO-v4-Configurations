#PBS -S /bin/csh 
#PBS -W group_list=g26113
#PBS -l select=5:ncpus=28:model=bro
#PBS -q long
#PBS -l walltime=120:00:00
#PBS -j oe
#PBS -W umask=33
#PBS -m bea
#PBS -r n

#set some env
limit stacksize unlimited
module purge

module load comp-intel/2018.3.222  mathematica/11.0.0 totalview/2017.0.12 mpi-hpe/mpt.2.21
module load hdf4/4.2.12 hdf5/1.8.18_mpt
module load netcdf/4.4.1.1_mpt

module list

umask 022

setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${HOME}/lib
setenv FORT_BUFFERED 1
#setenv MPI_IB_RAILS 2
setenv MPI_BUFS_PER_PROC 128
#with the current MPI, the following line doesn't matter.
#setenv MPI_BUFS_PER_HOST 512
setenv MPI_DISPLAY_SETTINGS

#setenv MPIP "-k 2"

set nprocs  = 113
set whichiter  = 130
@ maxexec = ${whichiter} + 3 
set offsetiter = 129
#IMPORTANT! Make sure unpack is set to 1 if to use ecco_ctrl and 0 if not.
set swhichiter =  `printf "%010d" ${whichiter}`
set runnm = 'run_test'

set basedir   = /XYZ/
set ctrldir = ${basedir}/ctrlvec.${runnm}
set optimdir = ${basedir}/optim.${runnm}

while ( ${whichiter} <= ${maxexec} )
#IMPORTANT! Make sure unpack is set to 1 if to use ecco_ctrl and 0 if not.
set unpack = 1
if ( ${whichiter} == ${offsetiter} ) set unpack = 0

#generate ecco_ctrl for whichiter
@ iterm1 = ${whichiter} - 1

set yiter=`printf "%04d" ${whichiter}`
set yiterm1=`printf "%04d" ${iterm1}`

if ( ${unpack} == 0) goto skip_optim
if ( (${whichiter} == 0 || ${whichiter} == ${offsetiter}) && ${unpack} == 0) goto skip_optim
cd ${optimdir}

#if ecco_ctrl exists, skip optim and start the run
if ( -e ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiter} ) goto skip_optim
#otherwise, generate ecco_ctrl for the run
@ optimcycle = ${whichiter} - ( ${offsetiter} + 1 )
@ nextcycle = ${optimcycle} + 1
set yoptimcycle = `printf "%04d" ${optimcycle}`
set ynextcycle =  `printf "%04d" ${nextcycle}`

if ( ! -e ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiterm1} || ! -e ${ctrldir}/ecco_cost_MIT_CE_000.opt${yiterm1} ) then
echo 'run aborted'
exit
endif

ln -s ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiterm1} ecco_ctrl_MIT_CE_000.opt${yoptimcycle}
ln -s ${ctrldir}/ecco_cost_MIT_CE_000.opt${yiterm1} ecco_cost_MIT_CE_000.opt${yoptimcycle}

ex - data.optim >> /dev/null <<EOF
/optimcycle=
c
 optimcycle=${optimcycle},
.
w
q
EOF

#start_here:
#
\cp data.optim data.optim_i${iterm1}
./optim.x >! op_i${iterm1}

\cp -f OPWARMI OPWARMI.${iterm1}
\mv ecco_ctrl*.opt${ynextcycle} ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiter}

skip_optim:

#Now run the model 
if ( -d ${basedir}/run.v4_rls5.${runnm}.iter${whichiter} ) then
    echo 'run.v4_rls5.${runnm}.iter${whichiter} exists.'
    echo 'remove it and restart the run'
    exit 999
endif

mkdir ${basedir}/run.v4_rls5.${runnm}.iter${whichiter}
cd ${basedir}/run.v4_rls5.${runnm}.iter${whichiter}

rm -rf tapes/tapes*

#link input files
ln -s ${inputdir}/data/* .
ln -s ${inputdir}/input_forcing/* .
ln -s ${inputdir}/input_init/* .
ln -s ${inputdir}/input_init/*/* . 
ln -s ${inputdir}/input_init/*/*/* .
ln -s ${inputdir}/input_other/* .

cp -p ${inputdir}/input_init/tools/mkdir_subdir_diags.py .
mkdir_subdir_diags.py

#
if ( (${whichiter} == 0 || ${whichiter} == ${offsetiter}) && ${unpack} == 0) then 
else
#copy ecco_ctrl file to run directory
    \cp -f ${ctrldir}/ecco_ctrl*${whichiter}   .
endif
#

cat >! data.optim <<EOF
 &OPTIM
 optimcycle=${whichiter},
 &
EOF

#start the run
mpiexec -np ${nprocs} /u/scicon/tools/bin/mbind.x ./build/mitgcmuv_ad

@ whichiter = {$whichiter} + 1

echo ${whichiter}

end

