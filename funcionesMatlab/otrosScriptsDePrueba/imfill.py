import os

import nibabel as nib
from scipy import ndimage as ndi
import numpy as np

rio =  '/Users/fernando/Dropbox/MUIB/TFM/RIO42_2/';

ctPath = rio + 'PRE_CT_220909/isoCortadaCT.nii'
mrPath = rio + 'PRE_RM_210809/isoCortadaRM.nii'

print 'Loading images...'
ct = nib.load(ctPath)
mr = nib.load(mrPath)

print 'Getting data...'
ctData = ct.get_data()
mrData = mr.get_data()

print 'Filling holes...'
ctData = ndi.morphology.binary_fill_holes(ctData).astype(np.uint8)
mrData = ndi.morphology.binary_fill_holes(mrData).astype(np.uint8)

print 'Creating NIfTI images...'
ctNii = nib.Nifti1Image(ctData, ct.get_affine())
mrNii = nib.Nifti1Image(mrData, mr.get_affine())

print 'Saving results...'
nib.save(ctNii, ctPath)
nib.save(mrNii, mrPath)