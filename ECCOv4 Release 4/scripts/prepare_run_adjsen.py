#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import division
import numpy as np
import xarray as xr
import os

# adapted from llc_array_conversion.py 
# https://github.com/ECCO-GROUP/ECCOv4-py
# to facilitate I/O

#%%
def llc_compact_to_tiles(data_compact, less_output = False):
    """

    Converts a numpy binary array in the 'compact' format of the
    lat-lon-cap (LLC) grids and converts it to the '13 tiles' format
    of the LLC grids.

    Parameters
    ----------
    data_compact : ndarray
        a numpy array of dimension nl x nk x 13*llc x llc

    less_output : boolean, optional, default False
        A debugging flag.  False = less debugging output


    Returns
    -------
    data_tiles : ndarray
        a numpy array organized by, at most,
        13 tiles x nl x nk x llc x llc

    Note
    ----
    If dimensions nl or nk are singular, they are not included
    as dimensions in data_tiles

    """

    data_tiles =  llc_faces_to_tiles(
                    llc_compact_to_faces(data_compact,
                                         less_output=less_output),
                    less_output=less_output)

    return data_tiles

# %%
def llc_tiles_to_compact(data_tiles, less_output = False):
    """

    Converts a numpy binary array in the 'compact' format of the
    lat-lon-cap (LLC) grids and converts it to the '13 tiles' format
    of the LLC grids.

    Parameters
    ----------
    data_tiles : ndarray
        a numpy array organized by, at most,
        13 tiles x nl x nk x llc x llc

        where dimensions 'nl' and 'nk' are optional.

    less_output : boolean, optional, default False
        A debugging flag.  False = less debugging output

    Returns
    -------
    data_compact : ndarray
        a numpy array of dimension nl x nk x 13*llc x llc

    Note
    ----
    If dimensions nl or nk are singular, they are not included
    as dimensions in data_compact

    """

    data_faces   = llc_tiles_to_faces(data_tiles, less_output=less_output)
    data_compact = llc_faces_to_compact(data_faces, less_output=less_output)

    return data_compact



#%%
def llc_compact_to_faces(data_compact, less_output = False):
    """
    Converts a numpy binary array in the 'compact' format of the
    lat-lon-cap (LLC) grids and converts it into the 5 'faces'
    of the llc grid.

    The five faces are 4 approximately lat-lon oriented and one Arctic 'cap'

    Parameters
    ----------
    data_compact : ndarray
        An 2D array of dimension  nl x nk x 13*llc x llc

    less_output : boolean, optional, default False
        A debugging flag.  False = less debugging output


    Returns
    -------
    F : dict
        a dictionary containing the five lat-lon-cap faces

        F[n] is a numpy array of face n, n in [1..5]

        dimensions of each 2D slice of F

        - f1,f2: 3*llc x llc
        -    f3: llc x llc
        - f4,f5: llc x 3*llc

    Note
    ----
    If dimensions nl or nk are singular, they are not included
    as dimensions of data_compact

    """

    dims = data_compact.shape
    num_dims = len(dims)

    # final dimension is always of length llc
    llc = dims[-1]

    # dtype of compact array
    arr_dtype = data_compact.dtype

    if not less_output:
        print('llc_compact_to_faces: dims, llc ', dims, llc)
        print('llc_compact_to_faces: data_compact array type ', data_compact.dtype)

    if num_dims == 2: # we have a single 2D slices (y, x)
        f1 = np.zeros((3*llc, llc), dtype=arr_dtype)
        f2 = np.zeros((3*llc, llc), dtype=arr_dtype)
        f3 = np.zeros((llc, llc), dtype=arr_dtype)
        f4 = np.zeros((llc, 3*llc), dtype=arr_dtype)
        f5 = np.zeros((llc, 3*llc), dtype=arr_dtype)

    elif num_dims == 3: # we have 3D slices (time or depth, y, x)
        nk = dims[0]

        f1 = np.zeros((nk, 3*llc, llc), dtype=arr_dtype)
        f2 = np.zeros((nk, 3*llc, llc), dtype=arr_dtype)
        f3 = np.zeros((nk, llc, llc), dtype=arr_dtype)
        f4 = np.zeros((nk, llc, 3*llc), dtype=arr_dtype)
        f5 = np.zeros((nk, llc, 3*llc), dtype=arr_dtype)

    elif num_dims == 4: # we have a 4D slice (time or depth, time or depth, y, x)
        nl = dims[0]
        nk = dims[1]

        f1 = np.zeros((nl, nk, 3*llc, llc), dtype=arr_dtype)
        f2 = np.zeros((nl, nk, 3*llc, llc), dtype=arr_dtype)
        f3 = np.zeros((nl, nk, llc, llc), dtype=arr_dtype)
        f4 = np.zeros((nl, nk, llc, 3*llc), dtype=arr_dtype)
        f5 = np.zeros((nl, nk, llc, 3*llc), dtype=arr_dtype)

    else:
        print ('llc_compact_to_faces: can only handle compact arrays of 2, 3, or 4 dimensions!')
        return []

    # map the data from the compact format to the five face arrays

    # -- 2D case
    if num_dims == 2:

        f1 = data_compact[:3*llc,:]
        f2 = data_compact[3*llc:6*llc,:]
        f3 = data_compact[6*llc:7*llc,:]

        #f4 = np.zeros((llc, 3*llc))

        for f in range(8,11):
            i1 = np.arange(0, llc)+(f-8)*llc
            i2 = np.arange(0,3*llc,3) + 7*llc + f -8
            f4[:,i1] = data_compact[i2,:]

        #f5 = np.zeros((llc, 3*llc))

        for f in range(11,14):
            i1 = np.arange(0, llc)+(f-11)*llc
            i2 = np.arange(0,3*llc,3) + 10*llc + f -11
            #print ('f, i1, i2 ', f, i1[0], i2[0])

            f5[:,i1] = data_compact[i2,:]

    # -- 3D case
    elif num_dims == 3:
        # loop over k

        for k in range(nk):
            f1[k,:] = data_compact[k,:3*llc,:]
            f2[k,:] = data_compact[k,3*llc:6*llc,:]
            f3[k,:] = data_compact[k,6*llc:7*llc,:]

            # if someone could explain why I have to make
            # dummy arrays of f4_tmp and f5_tmp instead of just using
            # f5 directly I would be so grateful!
            f4_tmp = np.zeros((llc, 3*llc))
            f5_tmp = np.zeros((llc, 3*llc))

            for f in range(8,11):
                i1 = np.arange(0, llc)+(f-8)*llc
                i2 = np.arange(0,3*llc,3) + 7*llc + f -8
                f4_tmp[:,i1] = data_compact[k,i2,:]


            for f in range(11,14):
                i1 = np.arange(0,  llc)   +(f-11)*llc
                i2 = np.arange(0,3*llc,3) + 10*llc + f -11
                f5_tmp[:,i1] = data_compact[k,i2,:]

            f4[k,:] = f4_tmp
            f5[k,:] = f5_tmp



    # -- 4D case
    elif num_dims == 4:
        # loop over l and k
        for l in range(nl):
            for k in range(nk):

                f1[l,k,:] = data_compact[l,k,:3*llc,:]
                f2[l,k,:] = data_compact[l,k, 3*llc:6*llc,:]
                f3[l,k,:] = data_compact[l,k, 6*llc:7*llc,:]

                # if someone could explain why I have to make
                # dummy arrays of f4_tmp and f5_tmp instead of just using
                # f5 directly I would be so grateful!
                f4_tmp = np.zeros((llc, 3*llc))
                f5_tmp = np.zeros((llc, 3*llc))

                for f in range(8,11):
                    i1 = np.arange(0, llc)+(f-8)*llc
                    i2 = np.arange(0,3*llc,3) + 7*llc + f -8
                    f4_tmp[:,i1] = data_compact[l,k,i2,:]

                for f in range(11,14):
                    i1 = np.arange(0, llc)+(f-11)*llc
                    i2 = np.arange(0,3*llc,3) + 10*llc + f -11
                    f5_tmp[:,i1] = data_compact[l,k,i2,:]

                f4[l,k,:,:] = f4_tmp
                f5[l,k,:,:] = f5_tmp


    # put the 5 faces in the dictionary.
    F = {}
    F[1] = f1
    F[2] = f2
    F[3] = f3
    F[4] = f4
    F[5] = f5

    return F


#%%
def llc_faces_to_tiles(F, less_output=False):
    """

    Converts a dictionary, F, containing 5 lat-lon-cap faces into 13 tiles
    of dimension nl x nk x llc x llc x nk.

    Tiles 1-6 and 8-13 are oriented approximately lat-lon
    while tile 7 is the Arctic 'cap'

    Parameters
    ----------
    F : dict
        a dictionary containing the five lat-lon-cap faces

        F[n] is a numpy array of face n, n in [1..5]

    less_output : boolean, optional, default False
        A debugging flag.  False = less debugging output

    Returns
    -------
    data_tiles : ndarray
        an array of dimension 13 x nl x nk x llc x llc,

        Each 2D slice is dimension 13 x llc x llc

    Note
    ----
    If dimensions nl or nk are singular, they are not included
    as dimensions of data_tiles


    """

    # pull out the five face arrays
    f1 = F[1]
    f2 = F[2]
    f3 = F[3]
    f4 = F[4]
    f5 = F[5]

    dims = f3.shape
    num_dims = len(dims)

    # dtype of compact array
    arr_dtype = f1.dtype

    # final dimension of face 1 is always of length llc
    ni_3 = f3.shape[-1]

    llc = ni_3 # default
    #

    if num_dims == 2: # we have a single 2D slices (y, x)
        data_tiles = np.zeros((13, llc, llc), dtype=arr_dtype)


    elif num_dims == 3: # we have 3D slices (time or depth, y, x)
        nk = dims[0]
        data_tiles = np.zeros((nk, 13, llc, llc), dtype=arr_dtype)


    elif num_dims == 4: # we have a 4D slice (time or depth, time or depth, y, x)
        nl = dims[0]
        nk = dims[1]

        data_tiles = np.zeros((nl, nk, 13, llc, llc), dtype=arr_dtype)

    else:
        print ('llc_faces_to_tiles: can only handle face arrays that have 2, 3, or 4 dimensions!')
        return []

    # llc is the length of the second dimension
    if not less_output:
        print ('llc_faces_to_tiles: data_tiles shape ', data_tiles.shape)
        print ('llc_faces_to_tiles: data_tiles dtype ', data_tiles.dtype)


    # map the data from the faces format to the 13 tile arrays

    # -- 2D case
    if num_dims == 2:
        data_tiles[0,:]  = f1[llc*0:llc*1,:]
        data_tiles[1,:]  = f1[llc*1:llc*2,:]
        data_tiles[2,:]  = f1[llc*2:,:]
        data_tiles[3,:]  = f2[llc*0:llc*1,:]
        data_tiles[4,:]  = f2[llc*1:llc*2,:]
        data_tiles[5,:]  = f2[llc*2:,:]
        data_tiles[6,:]  = f3
        data_tiles[7,:]  = f4[:,llc*0:llc*1]
        data_tiles[8,:]  = f4[:,llc*1:llc*2]
        data_tiles[9,:]  = f4[:,llc*2:]
        data_tiles[10,:] = f5[:,llc*0:llc*1]
        data_tiles[11,:] = f5[:,llc*1:llc*2]
        data_tiles[12,:] = f5[:,llc*2:]

    # -- 3D case
    if num_dims == 3:
        # loop over k
        for k in range(nk):
            data_tiles[k,0,:]  = f1[k,llc*0:llc*1,:]
            data_tiles[k,1,:]  = f1[k,llc*1:llc*2,:]
            data_tiles[k,2,:]  = f1[k,llc*2:,:]
            data_tiles[k,3,:]  = f2[k,llc*0:llc*1,:]
            data_tiles[k,4,:]  = f2[k,llc*1:llc*2,:]
            data_tiles[k,5,:]  = f2[k,llc*2:,:]
            data_tiles[k,6,:]  = f3[k,:]
            data_tiles[k,7,:]  = f4[k,:,llc*0:llc*1]
            data_tiles[k,8,:]  = f4[k,:,llc*1:llc*2]
            data_tiles[k,9,:]  = f4[k,:,llc*2:]
            data_tiles[k,10,:] = f5[k,:,llc*0:llc*1]
            data_tiles[k,11,:] = f5[k,:,llc*1:llc*2]
            data_tiles[k,12,:] = f5[k,:,llc*2:]

    # -- 4D case
    if num_dims == 4:
        #loop over l and k
        for l in range(nl):
            for k in range(nk):
                data_tiles[l,k,0,:]  = f1[l,k,llc*0:llc*1,:]
                data_tiles[l,k,1,:]  = f1[l,k,llc*1:llc*2,:]
                data_tiles[l,k,2,:]  = f1[l,k,llc*2:,:]
                data_tiles[l,k,3,:]  = f2[l,k,llc*0:llc*1,:]
                data_tiles[l,k,4,:]  = f2[l,k,llc*1:llc*2,:]
                data_tiles[l,k,5,:]  = f2[l,k,llc*2:,:]
                data_tiles[l,k,6,:]  = f3[l,k,:]
                data_tiles[l,k,7,:]  = f4[l,k,:,llc*0:llc*1]
                data_tiles[l,k,8,:]  = f4[l,k,:,llc*1:llc*2]
                data_tiles[l,k,9,:]  = f4[l,k,:,llc*2:]
                data_tiles[l,k,10,:] = f5[l,k,:,llc*0:llc*1]
                data_tiles[l,k,11,:] = f5[l,k,:,llc*1:llc*2]
                data_tiles[l,k,12,:] = f5[l,k,:,llc*2:]

    return data_tiles

#%%

def llc_tiles_to_faces(data_tiles, less_output=False):
    """

    Converts an array of 13 'tiles' from the lat-lon-cap grid
    and rearranges them to 5 faces.  Faces 1,2,4, and 5 are approximately
    lat-lon while face 3 is the Arctic 'cap'

    Parameters
    ----------
    data_tiles :
        An array of dimension 13 x nl x nk x llc x llc

    If dimensions nl or nk are singular, they are not included
        as dimensions of data_tiles

    less_output : boolean
        A debugging flag.  False = less debugging output
        Default: False

    Returns
    -------
    F : dict
        a dictionary containing the five lat-lon-cap faces

        F[n] is a numpy array of face n, n in [1..5]

        dimensions of each 2D slice of F

        - f1,f2: 3*llc x llc
        -    f3: llc x llc
        - f4,f5: llc x 3*llc

    """

    # ascertain how many dimensions are in the faces (minimum 3, maximum 5)
    dims = data_tiles.shape
    num_dims = len(dims)

    # the final dimension is always length llc
    llc = dims[-1]

    # tiles is always just before (y,x) dims
    num_tiles = dims[-3]

    # data type of original data_tiles
    arr_dtype = data_tiles.dtype

    if not less_output:
        print('llc_tiles_to_faces: num_tiles, ', num_tiles)

    if num_dims == 3: # we have a 13 2D slices (tile, y, x)
        f1 = np.zeros((3*llc, llc), dtype=arr_dtype)
        f2 = np.zeros((3*llc, llc), dtype=arr_dtype)
        f3 = np.zeros((llc, llc), dtype=arr_dtype)
        f4 = np.zeros((llc, 3*llc), dtype=arr_dtype)
        f5 = np.zeros((llc, 3*llc), dtype=arr_dtype)

    elif num_dims == 4: # 13 3D slices (time or depth, tile, y, x)

        nk = dims[0]

        f1 = np.zeros((nk, 3*llc, llc), dtype=arr_dtype)
        f2 = np.zeros((nk, 3*llc, llc), dtype=arr_dtype)
        f3 = np.zeros((nk, llc, llc), dtype=arr_dtype)
        f4 = np.zeros((nk, llc, 3*llc), dtype=arr_dtype)
        f5 = np.zeros((nk, llc, 3*llc), dtype=arr_dtype)

    elif num_dims == 5: # 4D slice (time or depth, time or depth, tile, y, x)
        nl = dims[0]
        nk = dims[1]

        f1 = np.zeros((nl,nk, 3*llc, llc), dtype=arr_dtype)
        f2 = np.zeros((nl,nk, 3*llc, llc), dtype=arr_dtype)
        f3 = np.zeros((nl,nk, llc, llc), dtype=arr_dtype)
        f4 = np.zeros((nl,nk, llc, 3*llc), dtype=arr_dtype)
        f5 = np.zeros((nl,nk, llc, 3*llc), dtype=arr_dtype)

    else:
        print ('llc_tiles_to_faces: can only handle tiles that have 2, 3, or 4 dimensions!')
        return []

    # Map data on the tiles to the faces

    # 2D slices on 13 tiles
    if num_dims == 3:

        f1[llc*0:llc*1,:] = data_tiles[0,:]

        f1[llc*1:llc*2,:] = data_tiles[1,:]
        f1[llc*2:,:]      = data_tiles[2,:]

        f2[llc*0:llc*1,:] = data_tiles[3,:]
        f2[llc*1:llc*2,:] = data_tiles[4,:]
        f2[llc*2:,:]      = data_tiles[5,:]

        f3                = data_tiles[6,:]

        f4[:,llc*0:llc*1] = data_tiles[7,:]
        f4[:,llc*1:llc*2] = data_tiles[8,:]
        f4[:,llc*2:]      = data_tiles[9,:]

        f5[:,llc*0:llc*1] = data_tiles[10,:]
        f5[:,llc*1:llc*2] = data_tiles[11,:]
        f5[:,llc*2:]      = data_tiles[12,:]

    # 3D slices on 13 tiles
    elif num_dims == 4:

        for k in range(nk):
            f1[k,llc*0:llc*1,:] = data_tiles[k,0,:]

            f1[k,llc*1:llc*2,:] = data_tiles[k,1,:]
            f1[k,llc*2:,:]      = data_tiles[k,2,:]

            f2[k,llc*0:llc*1,:] = data_tiles[k,3,:]
            f2[k,llc*1:llc*2,:] = data_tiles[k,4,:]
            f2[k,llc*2:,:]      = data_tiles[k,5,:]

            f3[k,:]             = data_tiles[k,6,:]

            f4[k,:,llc*0:llc*1] = data_tiles[k,7,:]
            f4[k,:,llc*1:llc*2] = data_tiles[k,8,:]
            f4[k,:,llc*2:]      = data_tiles[k,9,:]

            f5[k,:,llc*0:llc*1] = data_tiles[k,10,:]
            f5[k,:,llc*1:llc*2] = data_tiles[k,11,:]
            f5[k,:,llc*2:]      = data_tiles[k,12,:]

    # 4D slices on 13 tiles
    elif num_dims == 5:
        for l in range(nl):
            for k in range(nk):
                f1[l,k,llc*0:llc*1,:] = data_tiles[l,k,0,:]

                f1[l,k,llc*1:llc*2,:] = data_tiles[l,k,1,:]
                f1[l,k,llc*2:,:]      = data_tiles[l,k,2,:]

                f2[l,k,llc*0:llc*1,:] = data_tiles[l,k,3,:]
                f2[l,k,llc*1:llc*2,:] = data_tiles[l,k,4,:]
                f2[l,k,llc*2:,:]      = data_tiles[l,k,5,:]

                f3[l,k,:]             = data_tiles[l,k,6,:]

                f4[l,k,:,llc*0:llc*1] = data_tiles[l,k,7,:]
                f4[l,k,:,llc*1:llc*2] = data_tiles[l,k,8,:]
                f4[l,k,:,llc*2:]      = data_tiles[l,k,9,:]

                f5[l,k,:,llc*0:llc*1] = data_tiles[l,k,10,:]
                f5[l,k,:,llc*1:llc*2] = data_tiles[l,k,11,:]
                f5[l,k,:,llc*2:]      = data_tiles[l,k,12,:]

    # Build the F dictionary
    F = {}
    F[1] = f1
    F[2] = f2
    F[3] = f3
    F[4] = f4
    F[5] = f5

    return F


def llc_faces_to_compact(F, less_output=True):
    """

    Converts a dictionary containing five 'faces' of the lat-lon-cap grid
    and rearranges it to the 'compact' llc format.


    Parameters
    ----------
    F : dict
        a dictionary containing the five lat-lon-cap faces

        F[n] is a numpy array of face n, n in [1..5]

        dimensions of each 2D slice of F

        - f1,f2: 3*llc x llc
        -    f3: llc x llc
        - f4,f5: llc x 3*llc


    less_output : boolean, optional, default False
        A debugging flag.  False = less debugging output

    Returns
    -------
    data_compact : ndarray
        an array of dimension nl x nk x nj x ni

        F is in the llc compact format.

    Note
    ----
    If dimensions nl or nk are singular, they are not included
    as dimensions of data_compact

    """

    # pull the individual faces out of the F dictionary
    f1 = F[1]
    f2 = F[2]
    f3 = F[3]
    f4 = F[4]
    f5 = F[5]

    # ascertain how many dimensions are in the faces (minimum 2, maximum 4)
    dims = f3.shape
    num_dims = len(dims)

    # data type of original faces
    arr_dtype = f1.dtype

    # the final dimension is always the llc #
    llc = dims[-1]

    # initialize the 'data_compact' array
    if num_dims == 2: # we have a 2D slice (x,y)
        data_compact = np.zeros((13*llc, llc), dtype=arr_dtype)

    elif num_dims == 3: # 3D slice (x, y, time or depth)
        nk = dims[0]
        data_compact = np.zeros((nk, 13*llc, llc), dtype=arr_dtype)

    elif num_dims == 4: # 4D slice (x,y,time and depth)
        nl = dims[0]
        nk = dims[1]
        data_compact = np.zeros((nl, nk, 13*llc, llc), dtype=arr_dtype)
    else:
        print ('llc_faces_to_compact: can only handle faces that have 2, 3, or 4 dimensions!')
        return []

    if not less_output:
        print ('llc_faces_to_compact: face 3 shape', f3.shape)

    if num_dims == 2:

        data_compact[:3*llc,:]      = f1
        data_compact[3*llc:6*llc,:] = f2
        data_compact[6*llc:7*llc,:] = f3

        for f in range(8,11):
            i1 = np.arange(0, llc)+(f-8)*llc
            i2 = np.arange(0,3*llc,3) + 7*llc + f -8
            data_compact[i2,:] = f4[:,i1]

        for f in range(11,14):
            i1 = np.arange(0, llc)+(f-11)*llc
            i2 = np.arange(0,3*llc,3) + 10*llc + f -11
            data_compact[i2,:] = f5[:,i1]

    elif num_dims == 3:
        # loop through k indicies
        print ('llc_faces_to_compact: data_compact array shape', data_compact.shape)

        for k in range(nk):
            data_compact[k,:3*llc,:]      = f1[k,:]
            data_compact[k,3*llc:6*llc,:] = f2[k,:]
            data_compact[k,6*llc:7*llc,:] = f3[k,:]

            # if someone could explain why I have to transpose
            # f4 and f5 when num_dims =3 or 4 I would be so grateful.
            # Just could not figure this out.  Transposing works but why!?
            for f in range(8,11):
                i1 = np.arange(0, llc)+(f-8)*llc
                i2 = np.arange(0,3*llc,3) + 7*llc + f - 8

                data_compact[k,i2,:] = f4[k,0:llc,i1].T

            for f in range(11,14):
                i1 = np.arange(0, llc)+(f-11)*llc
                i2 = np.arange(0,3*llc,3) + 10*llc + f -11
                data_compact[k,i2,:] = f5[k,:,i1].T

    elif num_dims == 4:
        # loop through l and k indices
        for l in range(nl):
            for k in range(nk):
                data_compact[l,k,:3*llc,:]      = f1[l,k,:]
                data_compact[l,k,3*llc:6*llc,:] = f2[l,k,:]
                data_compact[l,k,6*llc:7*llc,:] = f3[l,k,:]

                for f in range(8,11):
                    i1 = np.arange(0, llc)+(f-8)*llc
                    i2 = np.arange(0,3*llc,3) + 7*llc + f -8
                    data_compact[l,k,i2,:]      = f4[l,k,:,i1].T

                for f in range(11,14):
                    i1 = np.arange(0, llc)+(f-11)*llc
                    i2 = np.arange(0,3*llc,3) + 10*llc + f -11
                    data_compact[l,k,i2,:]      = f5[l,k,:,i1].T


    if not less_output:
        print ('llc_faces_to_compact: data_compact array shape', data_compact.shape)
        print ('llc_faces_to_compact: data_compact array dtype', data_compact.dtype)

    return data_compact

#%%

grid_dir = '../namelist_adjsen/'
grid_fn = '../input/GRID_GEOMETRY_ECCO_V4r4_native_llc0090.nc'
grid_ds = xr.open_dataset(grid_dir+grid_fn)
grid_ds.load()
XC = grid_ds.XC
YC = grid_ds.YC
maskC = grid_ds.maskC
hFacC = grid_ds.hFacC
drF = grid_ds.drF
rA = grid_ds.rA

nrecmon = 12
nr = 50
ny = 1170
nx = 90
# mask to define box for objective function
# first initialize to zeros on model 3d grid
# The box is defined as : 5N-16N, 120E-151E, vertical level range: 15-20
# Vertical level range
kkk0=15-1
kkk1=20-1

idx_objmask = maskC * (XC>=120) * (YC<=151) * (YC>=5) * (YC<=16) 
# Mask out vertical level range
idx_objmask[0:kkk0] = False
idx_objmask[kkk1+1:,:] = False

objmask = 0.*np.copy(maskC)
objmask[idx_objmask] = 1.
# Compute the total volume of the box where the objective function is defined. 
totvol = (objmask * hFacC * drF * rA).sum().values
# the model objective function is sum of objmask*vol*Q at each model grid, 
# where vol is volume in m^3 and Q is a model state.
# Normalizing objmask by the total volume where the objective function is 
# defined would make the objective function the volume-weighted mean Q 
# in the box that has the same unit as Q.  
objmask = objmask/totvol

# Two mask files will be provided, one spatial and one temporal. 
# The filenames are objmask_fn appended with "C" for the spatial mask
# and "T" for the temporal mask. The temporal mask is a 1D scalar
# that has the weight of 0 or 1 for each averaging time record. 
# In the example adjoint calculation, the objective function is 
# defined as the last month (month 12) of monthly-averaged 
# THETA for a 12-month integration. The temporal mask is a 
# 12-element scalar, with the 12th element being one and the others 
# zero. 

# Spatial mask for objective function
objmask_fn = 'objmask'      
objmask_c =  llc_tiles_to_compact(objmask, less_output = True)   
objmask_c.astype('>f4').tofile(objmask_fn+'C')    

# Temporal mask for objective function
objmask_temporal_fn = objmask_fn+'T' 
objmask_temporal = np.zeros((nrecmon))
objmask_temporal[-1]=1
objmask_temporal.astype('>f4').tofile(objmask_temporal_fn)    

# Set up atmospheric controls
opt_str = '0000000129' # iteration number as a 10-digit string (for xx filename)
# for 1-year integration, set nrecxx = 54 (weeks) and nrecmon = 12 (months)
nrecxx = 54 # number of weekly atm control record for one-year integration 
             # For a longer simulation, increase nrecxx accordingly.

# Create fake weights for atmoshperic controls.
# The weights are provided as a 2d field on the model native grid;
# with 1 for wet and 0 for dry grid points of the model 
# surface layer.  
weights_fn = 'weights_ones.data'
datatmp = grid_ds.maskC.values[0,:]
weights_c = llc_tiles_to_compact(datatmp, less_output = True)
weights_c.astype('>f4').tofile(weights_fn)

# Create a file with all zeros for atmospheric control adjustments
# This file is needed for calculating the adjoint sensitivity. 
# The atmospheric controls are linked to this file.
# The adjoint model needs the atmospheric controls to do 
# the adjoint calculation (the forward run would be the 
# same with or without these zero atmospheric controls.)
zeros = np.zeros((nrecxx, ny, nx))
zeros_fn = 'zero_atm_xx'
zeros.astype('>f4').tofile(zeros_fn)

# atm xx
xx_list = [ 'xx_atemp', 'xx_precip', 'xx_swdown', 'xx_lwdown', 
            'xx_aqh', 'xx_tauu', 'xx_tauv']
# make symbolic link to each of the atm control 
for xx in xx_list:
	os.symlink(zeros_fn, xx+'.'+opt_str+'.data')
