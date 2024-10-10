#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun May 19 20:46:56 2019

@author: owang
"""
import os, shutil, glob

fdiag = 'data.diagnostics'
var_id = -1
with open(fdiag, 'r') as f0:
    for line in f0:
        if (len(line) == 0) or (line[0] == '#'):
            # blank line or comment line found
            continue
        elif line.lstrip()[0:10] == 'filename(':
            # new variable line found
            var_id += 1
            var_name = line[1:].strip()
        else:
            filename_line = line.find('filename(')
            if filename_line == -1:
                continue
            else:
                sep_ind = line.find('=')
                if sep_ind == -1:
                    print("incorrect file format")
                    sys.exit()
                else:
                    vtmp = line[sep_ind+1:].strip()
                    ind_lprm = vtmp.find("'")
                    ind_rprm = vtmp[ind_lprm+1:].find("'")
                    #print ind_lprm, ind_rprm
                    #print vtmp[ind_lprm:ind_lprm+ind_rprm+1]
                    newdirtmp0 = vtmp[ind_lprm+1:ind_lprm+ind_rprm+1]
                    newdirtmp = newdirtmp0.strip()
                    if newdirtmp[-1]=='/':
                        newdirtmp = newdirtmp[0:-1]                     
                    endloc = newdirtmp.rfind("/")
                    newdir = newdirtmp[0:endloc]
                    #print('making new directories: ', endloc,newdir)
                    try:
                        os.makedirs(newdir)
                    except:
                        print(newdir + " exists") 
                    # print '====='
                    # print(newdir+'*.??ta',  '  ', newdir+'/')
                    # for fl2mv in glob.glob(newdir+'*.??ta'):
                    #     shutil.move(fl2mv , newdir+'/')

