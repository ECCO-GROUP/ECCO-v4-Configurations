#!/bin/bash -f

var1=$1
dirin=$2
dirout=$3
year0=$4
file0=$5
file1=$6

echo $3 
echo $4
echo ${file0}

fout=${dirout}/${var1}_6hourlyavg_${year0}
if [ -e $fout ]; then
  echo $fout is already existent 1>&2
  echo remove $fout and restart  1>&2
  exit 1
fi

for (( i=${file0}; i<=${file1}; i=i+6)); do
  cyc=`printf "%010d" $i`
  f=${dirin}/${var1}.${cyc}.data
  if [ ! -e $f ]; then
    echo $f: non-existent 1>&2
    exit 1
  fi
  cat ${f} >> ${fout}
done

