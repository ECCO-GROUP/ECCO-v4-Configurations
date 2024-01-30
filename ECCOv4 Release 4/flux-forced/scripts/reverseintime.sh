#!/bin/bash -f

var1=$1
dirin=$2
file0=$3
file1=$4

echo $3 
echo $4
echo ${file0}

for (( i=${file0}; i<=${file1}; i=i+168)); do
  let i_rev=${file1}-${i}+${file0}
  cyc=`printf "%010d" $i`
  cyc_rev=`printf "%010d" $i_rev`
  f=${dirin}/${var1}.${cyc}.data
  fm=${dirin}/${var1}.${cyc}.meta
  f_rev=${var1}.${cyc_rev}.data
  fm_rev=${var1}.${cyc_rev}.meta
  
  if [ ! -e $f ]; then
    echo $f: non-existent 1>&2
    exit 1
  fi
  ln -s ${f} ${f_rev}
  ln -s ${fm} ${fm_rev}
done

