#############################################
# This script Moves features to fsaverage_sym - a bilaterally symmetrical template
# Then it calculates interhemsipheric asymmetry
# It also moves the manual lesion label to fsaverage_sym
##Run on all patients and controls

## Change to your subjects directory ##
subject_dir=$1
subject_list=$2

cd "$subject_dir"
export SUBJECTS_DIR="$subject_dir"



## Import list of subjects
subjects=$(<"$subject_list")

Measures="intra_z.thickness.sm10.mgh intra_z.w-g.pct.sm10.mgh intra_z.gm_FLAIR_0.sm10.mgh intra_z.gm_FLAIR_0.25.sm10.mgh intra_z.gm_FLAIR_0.5.sm10.mgh intra_z.gm_FLAIR_0.75.sm10.mgh intra_z.wm_FLAIR_0.5.sm10.mgh intra_z.wm_FLAIR_1.sm10.mgh intra_z.pial.K_filtered.sm20.mgh"

#These measures are done separately as they are not smoothed or z scored.
Measures2="thickness.mgh  w-g.pct.mgh  curv.mgh sulc.mgh 
    gm_FLAIR_0.75.mgh  gm_FLAIR_0.5.mgh  gm_FLAIR_0.25.mgh
    gm_FLAIR_0.mgh  wm_FLAIR_0.5.mgh  wm_FLAIR_1.mgh 
    pial.K_filtered.sm20.mgh"

for s in $subjects
do
  #create one all zero overlay for inversion step
  cp fsaverage_sym/surf/lh.white.avg.area.mgh "$s"/xhemi/surf_meld/zeros.mgh
  mris_calc --output "$s"/xhemi/surf_meld/zeros.mgh "$s"/xhemi/surf_meld/zeros.mgh set 0

  for m in $Measures
  do 
    
    # Move onto left hemisphere
    mris_apply_reg --src  "$s"/surf_meld/lh."$m" --trg "$s"/xhemi/surf_meld/lh.on_lh."$m"  --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
    mris_apply_reg --src "$s"/surf_meld/rh."$m" --trg "$s"/xhemi/surf_meld/rh.on_lh."$m"    --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
    # Calculate interhemispheric asymmetry
    mris_calc --output "$s"/xhemi/surf_meld/lh.asym.on_lh."$m" "$s"/xhemi/surf_meld/lh.on_lh."$m" sub "$s"/xhemi/surf_meld/rh.on_lh."$m"
    # invert interhemisphereic asymmetry
    mris_calc --output "$s"/xhemi/surf_meld/rh.asym.on_lh."$m" "$s"/xhemi/surf_meld/zeros.mgh sub "$s"/xhemi/surf_meld/lh.asym.on_lh."$m"
  done


  for m2 in $Measures2
  do

    # Move onto left hemisphere
    mris_apply_reg --src  "$s"/surf_meld/lh."$m2" --trg "$s"/xhemi/surf_meld/lh.on_lh."$m2"  --streg $SUBJECTS_DIR/"$s"/surf/lh.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
    mris_apply_reg --src "$s"/surf_meld/rh."$m2" --trg "$s"/xhemi/surf_meld/rh.on_lh."$m2"    --streg $SUBJECTS_DIR/"$s"/xhemi/surf/lh.fsaverage_sym.sphere.reg     $SUBJECTS_DIR/fsaverage_sym/surf/lh.sphere.reg
    # Asymmetry
    mris_calc --output "$s"/xhemi/surf_meld/lh.asym.on_lh."$m2" "$s"/xhemi/surf_meld/lh.on_lh."$m2" sub "$s"/xhemi/surf_meld/rh.on_lh."$m2"
    mris_calc --output "$s"/xhemi/surf_meld/rh.asym.on_lh."$m2" "$s"/xhemi/surf_meld/zeros.mgh sub "$s"/xhemi/surf_meld/lh.asym.on_lh."$m2"

  done

done
