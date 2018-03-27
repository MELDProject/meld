SUBJECT_DIR=$1
subject_list=$2
script_dir=$SUBJECT_DIR/../scripts/

cd "$SUBJECT_DIR"
export SUBJECTS_DIR="$SUBJECT_DIR"


## Import list of subjects
subjects=$(<"$subject_list")

for s in $subjects;
do


python "$script_dir"create_identity_reg.py "$s"

if [ ! -d  "$s"/surf_meld ];
then
mkdir "$s"/surf_meld
fi

#detect if lesion and which hemisphere
if [ -e  "$s"/label/rh.lesion.label ];
then
mri_label2vol --label "$s"/label/rh.lesion.label --temp "$s"/mri/T1.mgz --o "$s"/mri/rh.lesion.mgz --identity
mri_vol2surf --src "$s"/mri/rh.lesion.mgz --out "$s"/surf_meld/rh.lesion.mgh --hemi rh --srcreg "$s"/mri/transforms/Identity.dat

elif [ -e  "$s"/label/lh.lesion.label ];
then
mri_label2vol --label "$s"/label/lh.lesion.label --temp "$s"/mri/T1.mgz --o "$s"/mri/lh.lesion.mgz --identity
mri_vol2surf --src "$s"/mri/lh.lesion.mgz --out "$s"/surf_meld/lh.lesion.mgh --hemi lh --srcreg "$s"/mri/transforms/Identity.dat
fi

done

python "$script_dir"lesion_blobbing.py "$SUBJECT_DIR" "$subject_list"


