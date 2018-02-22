import numpy as np
import nibabel as nb
import os

def load_mgh(filename):
    """ import mgh file using nibabel. returns flattened data array"""
    mgh_file=nb.load(filename)
    mmap_data=mgh_file.get_data()
    array_data=np.ndarray.flatten(mmap_data)
    return array_data;


def import_mgh(filename):
    """ import mgh file using nibabel. returns flattened data array"""
    mgh_file=nb.load(filename)
    mmap_data=mgh_file.get_data()
    array_data=np.ndarray.flatten(mmap_data)
    return array_data;

def save_mgh(filename,array, demo):
    """ save mgh file using nibabel and imported demo mgh file"""
    mmap=np.memmap('/tmp/tmp', dtype='float32', mode='w+', shape=demo.get_data().shape)
    mmap[:,0,0]=array[:]
    output=nb.MGHImage(mmap, demo.affine, demo.header)
    nb.save(output, filename)


#function to load subject features
def load_subject_features(fs_id,features,subject_number,medial_wall,subjects_dir):
    n_vert=163842
    hemis=['lh','rh']
    h_index=-1
    feature_matrix = []
    for h in hemis:
        h_index+=1
        #create empty matrix with columns for ids, P/C, FLAIR, Lesion Label, Vertex Number, Hemisphere and features
        hemisphere_feature_matrix = np.zeros((len(features)+6,n_vert))
        #subject_id
        hemisphere_feature_matrix[0,:] = np.ones(n_vert,dtype='float32')*subject_number
        #control or patient
        if "_C_" in fs_id or "_c_":
            hemisphere_feature_matrix[1,:] = np.zeros(n_vert)
        else :
            hemisphere_feature_matrix[1,:] = np.ones(n_vert)
        #check if FLAIR available
        if os.path.isfile(subjects_dir + fs_id + '/xhemi/surf_meld/lh.inter_z.on_lh.intra_z.gm_FLAIR_0.75.sm10.mgh'):
            FLAIR_flag=1
        else:
            FLAIR_flag=0
        hemisphere_feature_matrix[2,:] = np.ones(n_vert)*FLAIR_flag
        lesion_label = subjects_dir + fs_id + '/xhemi/surf_meld/' + h +'.on_lh.lesion.mgh'
        if os.path.isfile(lesion_label):
            lesion = import_mgh(lesion_label)
            hemisphere_feature_matrix[3,:] = lesion
        #otherwise only zeros
        else :
            hemisphere_feature_matrix[3,:]= np.zeros(n_vert)
        #vertex
        hemisphere_feature_matrix[4,:] = np.arange(n_vert)
        #hemisphere
        hemisphere_feature_matrix[5,:] = np.ones(n_vert,dtype='float32')*h_index
        f_num=5
        for f in features:
            f_num+=1
            try :
                feature = import_mgh(subjects_dir + fs_id + '/xhemi/surf_meld/'+h+f)
                #set medial wall values to zero
                feature[medial_wall]=0
                hemisphere_feature_matrix[f_num,:] = feature
            except nb.py3k.FileNotFoundError:
                hemisphere_feature_matrix[f_num,:] = np.ones(n_vert)*666
                if "FLAIR" not in f:
                    print('Feature '+f+' not found!')
    feature_matrix.extend(hemisphere_feature_matrix)
    return feature_matrix

