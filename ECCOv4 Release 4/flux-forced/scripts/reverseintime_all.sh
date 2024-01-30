#!/bin/bash -f

# Create 7-day mean files that are reversed in time for offline adjoint tracer runs 
# by linking files under state_weekly to state_weekly_227808 with reversed 10-digit number 
# By default, 
# files in state_weekly (target) ==> files in state_weekly_227808 (link)
# 0(fake, same as 168) ==> 227808
# 168 ==> 227640
# 336 ==> 227472
#...
# 227472 ==> 336
# 227640 ==> 168 
# 227808 ==> 0

#Usage: sh -xv reverseintime_all.sh" 
#Usage: or sh -xv reverseintime_all.sh XYZ,"
#Usage:  where XYZ is a different time step for one of the 7-day mean file." 

if [ $# -eq 0 ]; then
    maxtimestep=227808
    echo ${maxtimestep}
else
    maxtimestep=$1
fi

dir_rev_time=state_weekly_rev_time_${maxtimestep}
if [ ! -d "${dir_rev_time}" ]; then
    mkdir ${dir_rev_time} 
fi
cd ${dir_rev_time}

for var1 in 'Convtave' 'GGL90diffKr-T' 'GM_Kwx-T' 'GM_Kwy-T' 'GM_Kwz-T' 'uVeltave' 'vVeltave' 'wVeltave' \
            'GM_Kux_week_mean' 'GM_Kuz_week_mean' 'GM_Kvy_week_mean' 'GM_Kvz_week_mean' 'GM_PsiXtave' 'GM_PsiYtave'

do
# 
dirin=../../state_weekly/${var1}/
dirout=./${var1}/
if [ ! -d "${dirout}" ]; then
    mkdir ${dirout}
fi

cd ${dirout}
sh -x ../../reverseintime.sh ${var1} ${dirin}  0 ${maxtimestep}
cd ..
done


