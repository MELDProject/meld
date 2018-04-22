##############################################################################

# This script does per-vertex normalisation based on control data for each feature

#import relevant packages
import numpy as np
import nibabel as nb
import argparse
import io_meld as io
import os

#parse commandline arguments pointing to subject_dir etc
parser = argparse.ArgumentParser(description='normalise by controls mu and std for each vertex')
parser.add_argument('subject_dir', type=str,
                    help='path to subject dir')
parser.add_argument('subject_ids',
                    type=str,
                    help='subject id')
parser.add_argument('control_dir',
                    type=str,
                    help='path to control subject')
args = parser.parse_args()


#save subjects dir and subject ids. import the text file containing subject ids
subject_dir=args.subject_dir
subject_id_filename=args.subject_ids
subject_ids=np.loadtxt(subject_dir + subject_id_filename,dtype='str')
control_dir=args.control_dir
hemis=['lh','rh']
cortex=nb.freesurfer.io.read_label(subject_dir + 'fsaverage_sym/label/lh.cortex.label')

#check if FLAIR
for fs_id in subject_ids:
    if '3T' in fs_id:
        f='3T'
    elif '15T' in fs_id:
        f='15T'
    if os.path.isfile(subject_dir + fs_id + '/xhemi/surf_meld/lh.on_lh.intra_z.gm_FLAIR_0.75.sm10.mgh'):
        measures=['.on_lh.intra_z.thickness.sm10.mgh', '.asym.on_lh.intra_z.thickness.sm10.mgh',
              '.on_lh.intra_z.w-g.pct.sm10.mgh','.asym.on_lh.intra_z.w-g.pct.sm10.mgh',
              '.on_lh.intra_z.pial.K_filtered.sm20.mgh','.asym.on_lh.intra_z.pial.K_filtered.sm20.mgh',
              '.on_lh.curv.mgh','.on_lh.sulc.mgh',
              '.asym.on_lh.curv.mgh','.asym.on_lh.sulc.mgh',
              '.on_lh.intra_z.gm_FLAIR_0.75.sm10.mgh','.on_lh.intra_z.gm_FLAIR_0.5.sm10.mgh',
              '.on_lh.intra_z.gm_FLAIR_0.25.sm10.mgh','.on_lh.intra_z.gm_FLAIR_0.sm10.mgh',
              '.on_lh.intra_z.wm_FLAIR_0.5.sm10.mgh','.on_lh.intra_z.wm_FLAIR_1.sm10.mgh',
              '.asym.on_lh.intra_z.gm_FLAIR_0.75.sm10.mgh','.asym.on_lh.intra_z.gm_FLAIR_0.5.sm10.mgh',
              '.asym.on_lh.intra_z.gm_FLAIR_0.25.sm10.mgh','.asym.on_lh.intra_z.gm_FLAIR_0.sm10.mgh',
              '.asym.on_lh.intra_z.wm_FLAIR_0.5.sm10.mgh','.asym.on_lh.intra_z.wm_FLAIR_1.sm10.mgh']
    else:
        measures=['.on_lh.intra_z.thickness.sm10.mgh', '.asym.on_lh.intra_z.thickness.sm10.mgh',
              '.on_lh.intra_z.w-g.pct.sm10.mgh','.asym.on_lh.intra_z.w-g.pct.sm10.mgh',
              '.on_lh.intra_z.pial.K_filtered.sm20.mgh','.asym.on_lh.intra_z.pial.K_filtered.sm20.mgh',
              '.on_lh.curv.mgh','.on_lh.sulc.mgh',
                  '.asym.on_lh.curv.mgh','.asym.on_lh.sulc.mgh']
    demo=nb.load(subject_dir+fs_id+'/xhemi/surf_meld/'+hemis[0]+measures[0])
    for h in hemis:
        for m in measures:
            control_mu=io.load_mgh(os.path.join(control_dir,f,h+'.mu'+m))
            control_std=io.load_mgh(os.path.join(control_dir,f,h+'.std'+m))
            subject_measure=io.load_mgh(subject_dir+fs_id+'/xhemi/surf_meld/'+h+m)
            z_measure=np.divide((subject_measure-control_mu),control_std,out=np.zeros_like(subject_measure), where=control_std!=0)
            io.save_mgh(subject_dir+fs_id+'/xhemi/surf_meld/'+h+'.inter_z'+m,z_measure,demo)


