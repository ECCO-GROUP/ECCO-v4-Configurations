#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Aug 22 09:52:56 2019

@author: owang
"""

from __future__ import division
import sys
import time
import os
import glob
import json

sys.path.append('/home/owang/CODE/Python/projects/modules/ECCOv4-py/')
import ecco_v4_py as ecco

dirroot = '/mnt/extraid/ifraid8/'
mds_var_dir0 = '/mnt/extraid/ifraid8/data10/owang/Ecco_data/v4/JPL/r4/release2/r042/r042f/r042ff23/run.v4_rls2.042ff23.iter129/diags/'

os.chdir(mds_var_dir0)
fname_suffix = '_mon_mean'
list = ["DRHODR",
        "EVEL","NVEL",
        "EXFaqh", 
        "EXFatemp", 
        "EXFewind", "EXFnwind", "EXFwspee", 
        "EXFhl", "EXFhs", 
        "EXFlwdn", "EXFlwnet", 
        "EXFpreci", "oceFWflx","SIatmFW","SFLUX","EXFempmr","EXFroff","EXFevap",
        "EXFpress", 
        "EXFqnet","oceQnet","SIatmQnt","TFLUX",
        "EXFswdn","EXFswnet","oceQsw",
        "EXFtaue","EXFtaun","oceTAUE","oceTAUN",
        "OBP","OBPNOPAB",
        "PHIHYD",
        "RHOAnoma",
        "SALT",
        "SIarea",
        "SIheff","SIhsnow","sIceLoad",
        "SIsnPrcp",
        "SSH","SSHNOIBC","SSHIB",
        "THETA",
        "SIeice","SInice"]
#processing in batches with each batch having ibatch files
ibatch = 31
ntime_steps = 0

mds_grid_dir = dirroot + '/data07/owang/Ecco_data/v4/JPL/r4/release2/h8//h8i_i48/various/nonblank/'

#averaging frequency
output_freq_code= 'AVG_MON'
output_dir = dirroot + '/data10/owang/Ecco_data/v4/Processed/r4/release3/r042/'+\
'r042f/run.v4_rls2.042ff23.iter129/netcdf/interp_monthly/'

#read in two json files, one common for all and one for specific variables
## JSON DIR 
meta_json_dir = '/home/owang/CODE/Python/projects/modules/ECCOv4-py/meta_json/'
# --- common meta data
with open(meta_json_dir + '/ecco_meta_common.json', 'r') as fp:
    meta_common = json.load(fp)

# -- variable specific meta data
with open(meta_json_dir + '/ecco_meta_variable.json', 'r') as fp:    
    meta_variable_specific = json.load(fp)

#modify meta information if necessary
meta_common['ecco-v4-global']['author'] = 'Ou Wang and Ian Fenty'
meta_common['ecco-v4-global']['product_version'] = 'ECCO Version 4 Release 4'
meta_common['ecco-v4-global']['product_time_coverage_end'] = '2017-12-31T12:00:00'

meta_variable_specific['SSH'] = {'long_name': 'Dynamic sea surface height anomaly', 'units': 'm'}
meta_variable_specific['SSHIB'] = {'long_name': 'Inverted Barometer SSH', 'units': 'm'}
meta_variable_specific['SSHNOIBC'] = {'long_name': \
                      'Sea surface height anomaly without the inverted barometer (IB) correction', \
                      'units': 'm'}
meta_variable_specific['OBP'] = {'long_name': 'Ocean bottom pressure', 'units': 'm'}
meta_variable_specific['OBPNOPAB'] = {'long_name': \
                      'Ocean bottom pressure including global mean atmospheric pressure', 
                      'units': 'm'}

for varnm_sub in list:
    varnm = varnm_sub + fname_suffix
    print('Processing ', varnm)
    mds_var_dir = mds_var_dir0 + varnm
    mds_files_to_load = varnm

    #first get number of files (timesteps)    
    if(ntime_steps==0):
        os.chdir(mds_var_dir)
        flist = glob.glob('*.data')
        flist.sort()
    
        time_steps = [int(flist[i][-15:-5]) for i in range(len(flist))]
        ntime_steps = len(time_steps)

    start_time = time.time()
    #processing files in batches
    for itime in range(0,ntime_steps, ibatch):
        itime_end = min(itime+ibatch, ntime_steps)
        time_steps_sub = time_steps[itime:itime_end]

        ecco.create_nc_variable_files_on_regular_grid_from_mds(mds_var_dir, 
                                                             mds_files_to_load,
                                                             mds_grid_dir,
                                                             output_dir,
                                                             output_freq_code,
                                                             vars_to_load = 'all',
                                                             #tiles_to_load = [0,1,2,3,4,5,6,7,8,9,10,11,12],
                                                             time_steps_to_load = time_steps_sub, #'all', #[12,36,60],
                                                             meta_variable_specific = meta_variable_specific,
                                                             express = 1,
                                                             meta_common = meta_common)#,
                                                             #mds_datatype = '>f4',
                                                             #method = 'time_interval_and_combined_tiles')
        
    print("Finish processing "+varnm)
    #print out timing information
    print(": --- %d seconds passed ---" % (time.time() - start_time))    
    time_passed = (time.time() - start_time)/float(ntime_steps)
    print(": --- %d seconds per file---" % time_passed)
  
