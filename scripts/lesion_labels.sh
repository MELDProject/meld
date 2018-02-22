##############################################################################

##This script moves the lesion label to fsaverage_sym
SUBJECT_DIR=$1
subject_list=$2


cd "$SUBJECT_DIR"
export SUBJECTS_DIR="$SUBJECT_DIR"


## Import list of subjects
subjects=$(<"$subject_list")
# for each subject do the following

for s in $subjects
do

# Move lesion Label
# Move onto left hemisphere
if [ -e "$s"/surf_meld/lh.lesion_linked.mgh ]
then
mris_apply_reg --src  "$s"/surf_meld/lh.lesion_linked.mgh --trg "$s"/xhemi/surf_meld/lh.on_lh.lesion.mgh  --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
elif [ -e "$s"/surf_meld/rh.lesion_linked.mgh ]
then
mris_apply_reg --src "$s"/surf_meld/rh.lesion_linked.mgh --trg "$s"/xhemi/surf_meld/rh.on_lh.lesion.mgh   --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
fi

done


