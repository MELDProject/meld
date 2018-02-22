##############################################################################

# This script does the following:
# 1. Sample FLAIR at 25%, 50%, 75% of the cortical thickness, at the grey-white matter boundary, and 0.5mm and 1mm subcortically
# 2. Smooth the following features using a 10mm gaussian kernel:
# - cortical thickness
# - FLAIR at 25%, 50%, 75% of the cortical thickness, at the grey-white matter boundary, and 0.5mm and 1mm subcortically
# - grey-white matter intensity contrast
# 3. Calculate curvature
# 4. Convert curvature and sulcal depth to .mgh file type

##This script needs to be run on all patients and all controls
## Change to your subjects directory ##
SUBJECT_DIR=$1
subject_list=$2
script_dir=$3

cd "$SUBJECT_DIR"
export SUBJECTS_DIR="$SUBJECT_DIR"


## Import list of subjects
subjects=$(<"$subject_list")
# for each subject do the following
for s in $subjects
do
  #check if final file exists. if it does, skip this step
  if [ ! -e "$s"/surf_meld/rh.w-g.pct.mgh ];  then

  # creates Identidy.dat - a transormation matrix required for sampling intensities with surfaces. In this case an identity matrix as volumes are already coregistered
#  bbregister --s "$s" --mov "$s" --mov "$s"/mri/brainmask.mgz --reg "$s"/mri/transforms/Identity.dat --init-fsl --t1
  python "$script_dir"create_identity_reg.py "$s"
  mkdir "$s"/surf_meld
  H="lh rh"
  #for each hemisphere
  for h in $H
  do
#if FLAIR exists, then sample it
    if [ -e "$s"/mri/FLAIR.mgz ]
     then
    # Sample FLAIR at 25%, 50%, 75% of the cortical thickness & at the grey-white matter boundary & smooth using 10mm Gaussian kernel
    D="0.5 0.25 0.75 0"
      for d in $D
      do
        #sampling volume to surface
        mri_vol2surf --src "$s"/mri/FLAIR.mgz --out "$s"/surf_meld/"$h".gm_FLAIR_"$d".mgh --hemi "$h" --projfrac "$d" --srcreg "$s"/mri/transforms/Identity.dat --trgsubject "$s" --surf white
        #smoothing
        mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
        --i "$s"/surf_meld/"$h".gm_FLAIR_"$d".mgh --o "$s"/surf_meld/"$h".gm_FLAIR_"$d".sm10.mgh
      done

    # Sample FLAIR 0.5mm and 1mm subcortically & smooth using 10mm Gaussian kernel
    D_wm="0.5 1"
    for d_wm in $D_wm
    do
      mri_vol2surf --src "$s"/mri/FLAIR.mgz --out "$s"/surf_meld/"$h".wm_FLAIR_"$d_wm".mgh --hemi "$h" --projdist -"$d_wm" --srcreg "$s"/mri/transforms/Identity.dat --trgsubject "$s" --surf white
      mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
      --i "$s"/surf_meld/"$h".wm_FLAIR_"$d_wm".mgh --o "$s"/surf_meld/"$h".wm_FLAIR_"$d_wm".sm10.mgh
    done
    fi
    # Smooth cortical thickness and grey white matter intensity contrast

    mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
     --i "$s"/surf/"$h".thickness --o "$s"/surf_meld/"$h".thickness.sm10.mgh
    mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 10\
    --i "$s"/surf/"$h".w-g.pct.mgh --o "$s"/surf_meld/"$h".w-g.pct.sm10.mgh

    # Calculate curvature 
    mris_curvature_stats -f white -g --writeCurvatureFiles "$s" "$h" curv 
    mris_curvature_stats -f pial -g --writeCurvatureFiles "$s" "$h" curv

    # Convert mean curvature and sulcal depth to .mgh file type
    mris_convert -c "$s"/surf/"$h".curv "$s"/surf/"$h".white "$s"/surf_meld/"$h".curv.mgh
    mris_convert -c "$s"/surf/"$h".sulc "$s"/surf/"$h".white "$s"/surf_meld/"$h".sulc.mgh
    mris_convert -c "$s"/surf/"$h".pial.K.crv "$s"/surf/"$h".white "$s"/surf_meld/"$h".pial.K.mgh
    mris_calc --output "$s"/surf_meld/"$h".pial.K_filtered.mgh "$s"/surf_meld/"$h".pial.K.mgh abs
    mris_fwhm --s "$s" --hemi "$h" --cortex --smooth-only --fwhm 20\
    --i "$s"/surf_meld/"$h".pial.K_filtered.mgh --o "$s"/surf_meld/"$h".pial.K_filtered.sm20.mgh

    mris_convert -c "$s"/surf/"$h".thickness "$s"/surf/"$h".white "$s"/surf_meld/"$h".thickness.mgh
    cp "$s"/surf/"$h".w-g.pct.mgh "$s"/surf_meld/"$h".w-g.pct.mgh

  done

  fi
done




