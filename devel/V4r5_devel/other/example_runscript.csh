#!/bin/csh -v
#PBS -S /bin/csh
#PBS -N Adjoint_NBP8
#PBS -W group_list=n1855
#PBS -l select=5:ncpus=28:mpiprocs=24:model=bro
##PBS -l select=5:ncpus=28:model=bro
##PBS -l select=1:ncpus=28:mpiprocs=1:model=bro+4:ncpus=28:model=bro
#PBS -l site=static_broadwell
#PBS -l walltime=01:30:00
##PBS -l walltime=00:30:00
#PBS -q devel
#PBS -j oe
#PBS -r n

#====>>> REPLACE FOLLOWING LINE WITH CORRECT RUNTIME DIRECTORY <<<====
limit coredumpsize unlimited
limit stacksize unlimited
module purge

#20200630
module load comp-intel/2020.4.304 mpi-hpe/mpt.2.23
#module load comp-intel/2019.5.281 mpi-hpe/mpt.2.23
#module load comp-intel/2018.3.222 mpi-hpe/mpt.2.23
##module load comp-intel/2016.2.181 mpi-hpe/mpt.2.23
module load hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt
#module load pagecache-management/0.5
#setenv PAGECACHE_MAX_BYTES   8589934592

module list

umask 022

#setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${HOME}/lib
setenv FORT_BUFFERED 1
#setenv MPI_IB_RAILS 2
setenv MPI_BUFS_PER_PROC 128
#with the current MPI, the following line doesn't matter.
#setenv MPI_BUFS_PER_HOST 512
unsetenv MPI_IB_RECV_MSGS
unsetenv MPI_UD_RECV_MSGS
setenv MPI_DISPLAY_SETTINGS

set nprocs  = 113

#set WORKINGDIR = WORKINGDIR
#set basedir   = ${WORKINGDIR}/MITgcm/ECCOV4/release5/
set inputdir   = path_to_inputdir
set rundirnm   = rundir

if ( -d run ) then
 echo "The run directory exists. Remove it and re-submit the script."
 exit 9
endif

mkdir ${rundirnm}
cd ${rundirnm}
ln -s ${inputdir}/data/* .
ln -s ${inputdir}/input_forcing/* .
ln -s ${inputdir}/input_init/* .
ln -s ${inputdir}/input_init/*/* . 
ln -s ${inputdir}/input_init/*/*/* .
ln -s ${inputdir}/input_other/* .

cp -p ${inputdir}/input_init/tools/mkdir_subdir_diags.py .
mkdir_subdir_diags.py

set jobid=`echo $PBS_JOBID | awk -F. '{print $1}'`
time pdsh -w `/u/scicon/tools/bin/pbs_nodes $jobid` "cd $PWD; /bin/cp data eedata data.{autodiff,cal,cost,ctrl,diagnostics,ecco,exch2,exf,ggl90,gmredi,grdchk,optim,pkg,profiles,salt_plume,sbo,seaice,shelfice,smooth} /tmp"
time pdsh -w `/u/scicon/tools/bin/pbs_nodes $jobid` "mkdir /tmp/profiles"
mkdir /tmp/diags

#foreach f (`ls xx_*.0000000146.{data,meta} r2.* *.bin`)
foreach f (`ls ecco_ct* r2.* *.bin smooth[23]D* xx_*.${swhichiter}.{data,meta}`)
 /bin/cp $f /tmp &
end
wait

time mpiexec -prefix "%g " -np ${nprocs} /u/scicon/tools/bin/mbind.x build/mitgcmuv_ad

ls -lrt /tmp
cd /tmp
mv *_global.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv     xx_*.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv   adxx_*.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv      m_*.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
#mv    adm_*.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
#mv    ADJ*.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv    ecco_*.opt* $PBS_O_WORKDIR/${rundirnm}/ &
mv        diags/* $PBS_O_WORKDIR/${rundirnm}/diags &
wait

#rsync -av --include='*/' --exclude='ad*.??ta' --include='*.equi.data' profiles $PBS_O_WORKDIR/${rundirnm}/
#rsync -av --include='*/' --exclude='ad*.??ta' --include='*.equi.data' profiles/ $PBS_O_WORKDIR/${rundirnm}/ &
mv ADJ*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv Angle*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv D??.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv Depth.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv K_icefront*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv R??.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv R_icefront.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv ?2zonDir.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv [XY][CG].*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv hFac?.*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv mask*.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
mv prof_?_*mean.{data,meta} $PBS_O_WORKDIR/${rundirnm}/ &
wait

cd $PBS_O_WORKDIR/${rundirnm}/
#mkdir $PBS_O_WORKDIR/First_full
pdsh -w `/u/scicon/tools/bin/pbs_nodes $jobid` "cd /tmp; mv STD???.???? $PBS_O_WORKDIR/${rundirnm}/"
pdsh -w `/u/scicon/tools/bin/pbs_nodes $jobid` "cd /tmp; rsync -av --include='*/' --exclude='ad*.??ta' --include='*.equi.data' profiles $PBS_O_WORKDIR/${rundirnm}/"
#pdsh -w `/u/scicon/tools/bin/pbs_nodes $jobid` "cd /tmp; rm data data.* tapes* scratch?.*"

