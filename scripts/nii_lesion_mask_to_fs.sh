# This script registers a lesion mask done in mricron or any other software creating a nifti lesion mask
# (?h.lesion.nii) to the freesurfer surfaces
# It assumes that the ?h.lesion.nii is in the subjects mri folder $s/mri/"h.lesion.nii



SUBJECT_DIR=$1
subject_list=$2

cd "$SUBJECT_DIR"
export SUBJECTS_DIR="$SUBJECT_DIR"


## Import list of subjects
subjects=$(<"$subject_list")

for s in $subjects
do

bbregister --s "$s" --mov "$s" --mov "$s"/mri/brainmask.mgz --reg "$s"/mri/transforms/Identity.dat --init-fsl --t1

if [ ! -d  "$s"/surf_meld ];
then
mkdir "$s"/surf_meld
fi

if [ -e  "$s"/mri/rh.lesion.nii ];
then
# Ensure that the path is correct
mri_convert "$s"/rh.lesion.nii "$s"/mri/rh.lesion.mgz -rl "$s"/mri/T1.mgz
mri_vol2surf --src "$s"/mri/rh.lesion.mgz --out "$s"/surf_meld/rh.lesion.mgh --srcreg "$s"/mri/transforms/Identity.dat --hemi rh

elif [ -e  "$s"/mri/lh.lesion.nii ];
then
mri_convert "$s"/lh.lesion.nii "$s"/mri/lh.lesion.mgz -rl "$s"/mri/T1.mgz
mri_vol2surf --src "$s"/mri/lh.lesion.mgz --out "$s"/surf_meld/lh.lesion.mgh --srcreg "$s"/mri/transforms/Identity.dat --hemi lh

done

python lesion_blobbing.py "$SUBJECT_DIR" "$subject_list"

