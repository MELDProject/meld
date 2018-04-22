##############################################################################

# This script counts how many controls are available per field strength per site. If more than 20 available, then it will calculate mu and std for each feature in order for inter subject z scoring to be computed in the next script
# If less than 20 controls are available, it will use a default template control to inter-subject normalise the data in the next script
# The decision is made separately for FLAIR images - i.e. if you have more than 20 controls with T1 and less than 20 with both T1 and FLAIR. Site specific normalisation will occur for T1 features, whereas the template control will be used to normalise the FLAIR features.

# create control subjects to carry out z-scores
#import relevant packages
import numpy as np
import nibabel as nb
import argparse
import io_meld as io
import os

#parse commandline arguments pointing to subject_dir etc
parser = argparse.ArgumentParser(description='create mu and std overlays from a set of subjects to carry out z-scoring.')
parser.add_argument('subject_dir', type=str, 
                    help='path to subject dir')
parser.add_argument('subject_ids', 
                    type=str,
                    help='textfile containing list of subject ids')
parser.add_argument('control_dir',
                    type=str,
                    help='output_directory for template control')


args = parser.parse_args()

#save subjects dir and subject ids. import the text file containing subject ids
subject_dir=args.subject_dir
subject_ids_filename=args.subject_ids
subject_ids=np.loadtxt(subject_dir+subject_ids_filename, dtype='str')
control_dir=args.control_dir

#load in demo overlay structure
measures=['.on_lh.intra_z.thickness.sm10.mgh', '.asym.on_lh.intra_z.thickness.sm10.mgh',
          '.on_lh.intra_z.w-g.pct.sm10.mgh','.asym.on_lh.intra_z.w-g.pct.sm10.mgh',
          '.on_lh.intra_z.pial.K_filtered.sm20.mgh','.asym.on_lh.intra_z.pial.K_filtered.sm20.mgh',
          '.on_lh.curv.mgh', '.asym.on_lh.curv.mgh',
          '.on_lh.sulc.mgh', '.asym.on_lh.sulc.mgh']
flair_measures=['.on_lh.intra_z.gm_FLAIR_0.75.sm10.mgh','.on_lh.intra_z.gm_FLAIR_0.5.sm10.mgh',
                '.on_lh.intra_z.gm_FLAIR_0.25.sm10.mgh','.on_lh.intra_z.gm_FLAIR_0.sm10.mgh',
                '.on_lh.intra_z.wm_FLAIR_0.5.sm10.mgh','.on_lh.intra_z.wm_FLAIR_1.sm10.mgh',
                '.asym.on_lh.intra_z.gm_FLAIR_0.75.sm10.mgh','.asym.on_lh.intra_z.gm_FLAIR_0.5.sm10.mgh',
                '.asym.on_lh.intra_z.gm_FLAIR_0.25.sm10.mgh','.asym.on_lh.intra_z.gm_FLAIR_0.sm10.mgh',
                '.asym.on_lh.intra_z.wm_FLAIR_0.5.sm10.mgh','.asym.on_lh.intra_z.wm_FLAIR_1.sm10.mgh']
    
hemis=['lh','rh']
demo=nb.load(subject_dir+subject_ids[0]+'/xhemi/surf_meld/'+hemis[0]+measures[0])

#run on two field strengths separately
fields=['3T','15T']

#count how many control subjects:
for f in fields:
    indices = [i for i, v in enumerate(subject_ids) if f+"_C_" in v]
    control_subjects = subject_ids[indices]
    total_number = len(control_subjects)

    if total_number < 20:
        print("Found " + str(total_number)+ "controls. As this is less than 25, we will use MELD template controls for normalisation step")
        break
    print("Creating T1 control means and stds")


    for h in hemis:
        for m in measures:
            control_data=np.zeros((len(control_subjects),len(demo.get_data())))
            k=-1
            for s in control_subjects:
                k+=1
                control_data[k]=io.import_mgh(subject_dir+s+'/xhemi/surf_meld/'+h+m)
            mean=np.mean(control_data,axis=0)
            std=np.std(control_data,axis=0)
            io.save_mgh(os.path.join(control_dir,f,h+'.mu'+m),mean,demo)
            io.save_mgh(os.path.join(control_dir,f,h+'.std'+m),std,demo)


#count how many FLAIR controls
    flair_controls=[]
    for fs_id in control_subjects:
        if os.path.isfile(subject_dir + fs_id + '/xhemi/surf_meld/lh.on_lh.intra_z.gm_FLAIR_0.75.sm10.mgh'):
            flair_controls.append(fs_id)


    if len(flair_controls) < 20:
        print("Found " + str(len(flair_controls))+ " FLAIR controls. As this is less than 25, we will use MELD template FLAIR controls for normalisation step")
        break
    print("Creating control FLAIR means and stds")

    for h in hemis:
        for m in flair_measures:
            control_data=np.zeros((len(flair_controls),len(demo.get_data())))
            k=-1
            for s in flair_controls:
                k+=1
                control_data[k]=io.import_mgh(subject_dir+s+'/xhemi/surf_meld/'+h+m)
            mean=np.mean(control_data,axis=0)
            std=np.std(control_data,axis=0)
            io.save_mgh(os.path.join(control_dir,f,h+'.mu'+m),mean,demo)
            io.save_mgh(os.path.join(control_dir,f,h+'.std'+m),std,demo)



