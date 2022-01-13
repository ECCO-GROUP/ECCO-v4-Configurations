#2022-01-13
#Ou Wang
#An example script to automate optimization
#The script will do 4 iterations. 
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
#Load modules for compilers, etc. 
#First remove all modules to have a fresh restart
module purge

#Now load modules 
#These modules are the latest versions as of 01/13/2022
#Using newer modules when available is recommended
module load comp-intel/2020.4.304 mpi-hpe/mpt.2.25
module load hdf4/4.2.12 hdf5/1.8.18_mpt netcdf/4.4.1.1_mpt

#For debug purpose, list the loaded modules to see 
#if they are the same as those specified above
module list

#Change permission of output files so others can read
umask 022

#Set some system environment variables
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${HOME}/lib
setenv FORT_BUFFERED 1
#setenv MPI_IB_RAILS 2
setenv MPI_BUFS_PER_PROC 128
#with the current MPI, the following line doesn't matter.
#setenv MPI_BUFS_PER_HOST 512
setenv MPI_DISPLAY_SETTINGS

#setenv MPIP "-k 2"

#Set number of processes
set nprocs  = 113
#Specify starting iteration number
set whichiter  = 130
#swhichiter is whichiter in string format 
set swhichiter =  `printf "%010d" ${whichiter}`
#Specify ending iteration number (doing 4 iterations at one shot) 
#Make sure the specified walltime (walltime=120:00:00 above)
#is long enough for the estimated time of iterations. 
#If not, increase walltime or reduce maxexec  
@ maxexec = ${whichiter} + 3 
#Specify the iteration number for the initial iteration (the iteration before a steepest descent) 
#As we may have to restart iterations from a steepest descent from time to time, 
#the initial iteration is not always iteration 0.
set offsetiter = 129

#Run name
set runnm = 'run_test'
#Run directory
set basedir   = /XYZ/
#Control directory that would store ecco_ctrl and ecco_cost files.
#The directory is empty for the initial iteration.
set ctrldir = ${basedir}/ctrlvec.${runnm}
#Optimization directory where the optimization generates ecco_ctrl for next iteration
#See an example of optimdir for the initial iteration in 
#https://github.com/ECCO-GROUP/ECCO-v4-Configurations/blob/master/ECCOv4%20Release%204/scripts/optim
set optimdir = ${basedir}/optim.${runnm}

#Keep iterating until ${whichiter}>${maxexec}
while ( ${whichiter} <= ${maxexec} )

#IMPORTANT! Make sure unpack is set to 1 if use ecco_ctrl and 0 if not.
set unpack = 1
#Set unpack = 0 or the initial iteration, since there is no ecco_ctrl file.
if ( ${whichiter} == ${offsetiter} ) set unpack = 0

#Generate ecco_ctrl for whichiter
#Calculate the pervious iteration number (need previous iteration's ecco_ctrl and ecco_cost)
@ iterm1 = ${whichiter} - 1

set yiter=`printf "%04d" ${whichiter}`
set yiterm1=`printf "%04d" ${iterm1}`

#If ${unpack} == 0 or if it is the initial iteration, skip generating ecco_ctrl. 
#We will be using xx files instead. 
if ( ${unpack} == 0) goto skip_optim
if ( (${whichiter} == 0 || ${whichiter} == ${offsetiter}) && ${unpack} == 0) goto skip_optim

#Now doing the optimization
cd ${optimdir}

#If ecco_ctrl exists, skip optim and start the run
if ( -e ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiter} ) goto skip_optim
#Otherwise, generate ecco_ctrl for the run
@ optimcycle = ${whichiter} - ( ${offsetiter} + 1 )
@ nextcycle = ${optimcycle} + 1
set yoptimcycle = `printf "%04d" ${optimcycle}`
set ynextcycle =  `printf "%04d" ${nextcycle}`

#Abort if previous iteration's ecco_ctrl or ecco_cost is misssing
if ( ! -e ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiterm1} || ! -e ${ctrldir}/ecco_cost_MIT_CE_000.opt${yiterm1} ) then
echo 'run aborted'
exit
endif

#Link previous iteration's ecco_ctrl or ecco_cost
ln -s ${ctrldir}/ecco_ctrl_MIT_CE_000.opt${yiterm1} ecco_ctrl_MIT_CE_000.opt${yoptimcycle}
ln -s ${ctrldir}/ecco_cost_MIT_CE_000.opt${yiterm1} ecco_cost_MIT_CE_000.opt${yoptimcycle}

#Update optimcyle in data.optim
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
#Now generate ecco_ctrl 
#optim.x can be generated following 
#https://github.com/ECCO-GROUP/ECCO-v4-Configurations/tree/master/ECCOv4%20Release%204/optimization
#Or one can use their own version of optimi.x
./optim.x >! op_i${iterm1}

#OPWARMI will be overwitten at each iteration. So save a copy.
\cp -f OPWARMI OPWARMI.${iterm1}

#Move the new ecco_ctrl to ${ctrldir}
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

#After the run successfully finishes, copy ecco_cost from 
#run directory to the ctrldir directory for optimization 
#to generate ecco_ctrl for next iteration
rsync -av ecco_cost_MIT_CE_000.opt${yiter} ${ctrldir}

#Increase whichiter for next iteration
@ whichiter = {$whichiter} + 1

echo ${whichiter}

end

