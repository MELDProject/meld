##############################################################################

# This script defragments the lesion label, filling in holes by expanding and contracting across the surface

#import relevant packages
import numpy as np
import nibabel as nb
import argparse
import os
import io_meld as io

def get_neighbours(surface):
    coords, faces = nb.freesurfer.io.read_geometry(surface)
    neighbours=[[] for i in range(len(coords))]
    for tri in faces:
        neighbours[tri[0]].extend([tri[1],tri[2]])
        neighbours[tri[2]].extend([tri[1],tri[0]])
        neighbours[tri[1]].extend([tri[0],tri[2]])
    #Get unique neighbours
    for k in range(len(neighbours)):
        neighbours[k]=f7(neighbours[k])
    return np.array(neighbours);


def f7(seq):
    seen = set()
    seen_add = seen.add
    return [x for x in seq if not (x in seen or seen_add(x))]

def defrag_surface(lesion,surface):
    neighbours=get_neighbours(surface)
    #find basic lesion vertics
    patch=np.where(lesion>0)[0]
    steps=5
    #expanding stage. add neighbours
    for k in range(steps):
        new_patch=neighbours[patch]
    #shrinking stage. remove edge vertices
        out=np.concatenate(new_patch).ravel()
        patch=np.unique(out)
    not_patch=np.setdiff1d(range(len(neighbours)),patch)
    for k in range(steps):
        new_not_patch=neighbours[not_patch]
        out=np.concatenate(new_not_patch).ravel()
        not_patch=np.unique(out)
    patch=np.setdiff1d(range(len(neighbours)),not_patch)
    lesion[:]=0
    lesion[patch]=1
    return lesion;

#parse commandline arguments pointing to subject_dir etc
parser = argparse.ArgumentParser(description='defragment volumetrically created lesion masks on the surface')
parser.add_argument('subject_dir', type=str,
                    help='path to subject dir')
parser.add_argument('subject_ids',
                    type=str,
                    help='textfile containing list of subject ids')

args = parser.parse_args()


#save subjects dir and subject ids. import the text file containing subject ids
subject_dir=args.subject_dir
subject_ids_filename=args.subject_ids
subject_ids=np.loadtxt(subject_dir+subject_ids_filename, dtype='str')

hemis=['lh','rh']

for h in hemis:
    for s in subject_ids:
       #only do lesion mask is present
        if os.path.isfile(os.path.join(subject_dir, s, 'surf_meld/',h+'.lesion.mgh')):
            demo=nb.load(os.path.join(subject_dir, s, 'surf_meld/',h+'.lesion.mgh'))
            lesion=io.import_mgh(os.path.join(subject_dir, s, 'surf_meld/',h+'.lesion.mgh'))
            defragged=defrag_surface(lesion,os.path.join(subject_dir,s,'surf/',h+'.white'))
            #remove medial wall vertices
#            cortex=nb.freesurfer.io.read_label(subject_dir + s + '/label/'+h+'.cortex.label')
#            defragged[~cortex]=0
            io.save_mgh(os.path.join(subject_dir,s,'surf_meld/',h+'.lesion_linked.mgh'),defragged,demo)

