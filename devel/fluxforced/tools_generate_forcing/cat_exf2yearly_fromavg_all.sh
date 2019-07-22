#!/bin/bash -f

#Usage:
# cat_exf2yearly_fromavg_all.sh DIRIN DIROUT
#  where DIRIN and DIROUT are the input directory (where the 6-hourly files are)
#  and output directory (where the yearly files would be), respectively. 

dirin=$1
dirout=$2
for var1 in 'oceTAUX' 'oceTAUY' 'oceQsw' 'oceQnet' 'oceFWflx' 'oceSflux' 'oceSPflx' 'sIceLoad' 
do
#
#Fake the first (two) and last (one) records so that the time-forcing duration 
# is not smaller than the v4r3 model time-duration. 
# The faked fields are chosen to be the fields one-day later or earlier to 
# have the correct diurnal cycle. 
# 
cp -p ${dirin}/${var1}.0000000018.data ${dirin}/${var1}.-000000006.data
cp -p ${dirin}/${var1}.0000000024.data ${dirin}/${var1}.0000000000.data
cp -p ${dirin}/${var1}.0000210342.data ${dirin}/${var1}.0000210366.data

sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  1992      -6      8772
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  1993    8778     17532
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  1994   17538     26292
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  1995   26298     35052
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  1996   35058     43836
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  1997   43842     52596
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  1998   52602     61356
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  1999   61362     70116
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2000   70122     78900
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2001   78906     87660
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2002   87666     96420
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2003   96426    105180
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2004  105186    113964
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2005  113970    122724
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2006  122730    131484
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2007  131490    140244
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2008  140250    149028
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2009  149034    157788
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2010  157794    166548
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2011  166554    175308
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2012  175314    184092
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2013  184098    192852
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2014  192858    201612
sh -x cat_exf2yearly_fromavg.sh ${var1} ${dirin} ${dirout}  2015  201618    210366
done


