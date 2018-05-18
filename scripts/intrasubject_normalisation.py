##############################################################################

# This script calculates the mu and std of a feature within an individual and normalises the value of each vertex by the mu and std.
# Features: cortical thickness, grey-white matter intensity contrast, intrinsic curvature
# FLAIR features (if available): FLAIR sampled in the grey matter at 25%, 50% and 75% cortical thickness depths, sampled at the grey-white matter boundary and 1mm and 2mm subcortical.


#import relevant packages
import numpy as np
import nibabel as nb
import argparse
import os
import io_meld as io

#parse commandline arguments pointing to subject_dir etc
parser = argparse.ArgumentParser(description='normalise by across each subject')
parser.add_argument('subject_dir', type=str,
                    help='path to subject dir')
parser.add_argument('subject_ids',
                    type=str,
                    help='textfile containing list of subject ids')

args = parser.parse_args()


#save subjects dir and subject ids. import the text file containing subject ids
subject_dir=args.subject_dir
subject_ids_filename=args.subject_ids
subject_ids=np.loadtxt(os.path.join(subject_dir,subject_ids_filename), dtype='str')

measures=['.thickness.sm10.mgh', '.w-g.pct.sm10.mgh',
    '.pial.K_filtered.sm20.mgh']
          
flair_measures=['.gm_FLAIR_0.sm10.mgh','.gm_FLAIR_0.25.sm10.mgh','.gm_FLAIR_0.5.sm10.mgh',
    '.gm_FLAIR_0.75.sm10.mgh','.wm_FLAIR_0.5.sm10.mgh','.wm_FLAIR_1.sm10.mgh']
hemis=['lh','rh']
demo=nb.load(os.path.join(subject_dir,subject_ids[0],'surf_meld',hemis[0]+measures[0]))

for h in hemis:
    for s in subject_ids:
        demo=nb.load(os.path.join(subject_dir,s,'surf_meld',h+measures[0]))
        cortex=nb.freesurfer.io.read_label(os.path.join(subject_dir , s , 'label', h+'.cortex.label')
        for m in measures:
            if not os.path.isfile(os.path.join(subject_dir , s , 'surf_meld',h+'.intra_z'+m):
                subject_measure=io.load_mgh(os.path.join(subject_dir,s,'surf_meld',h+m))
                z_measure=(subject_measure-np.mean(subject_measure[cortex]))/np.std(subject_measure[cortex])
                io.save_mgh(os.path.join(subject_dir,s,'surf_meld',h+'.intra_z'+m),z_measure,demo)
        #only do FLAIR measures if present
        if os.path.isfile(os.path.join(subject_dir , s , 'surf_meld',h+flair_measures[0])):
            for m in flair_measures:
                if not os.path.isfile(os.path.join(subject_dir , s , 'surf_meld',h+'.intra_z'+m)):
                    subject_measure=io.load_mgh(os.path.join(subject_dir , s, 'surf_meld',h+m))
                    z_measure=(subject_measure-np.mean(subject_measure[cortex]))/np.std(subject_measure[cortex])
                    io.save_mgh(os.path.join(subject_dir , s, 'surf_meld', h+'.intra_z'+m),z_measure,demo)


