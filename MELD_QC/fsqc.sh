#!/bin/bash

echo "<html>" 																						>  index.html
echo "<table>"																						>> index.html
for sub in $(ls ${SUBJECTS_DIR});
do
  if [[ $sub == MELD* ]]  
  then  
	echo "<tr>"																						>> index.html
	echo "<td><a href=\"file:"$sub".lh.lat.hr.tif\"><img src=\""$sub".lh.lat.lr.tif\"></a></td>"	>> index.html
	echo "<td><a href=\"file:"$sub".lh.med.hr.tif\"><img src=\""$sub".lh.med.lr.tif\"></a></td>"	>> index.html
	echo "<td><a href=\"file:"$sub".rh.lat.hr.tif\"><img src=\""$sub".rh.lat.lr.tif\"></a></td>"	>> index.html
	echo "<td><a href=\"file:"$sub".rh.med.hr.tif\"><img src=\""$sub".rh.med.lr.tif\"></a></td>"	>> index.html
	echo "</tr>"																					>> index.html
	echo "<tr>"																						>> index.html
	echo "<td colspan=4><center>"$sub"</center><br></td>"											>> index.html
	echo "</tr>"																					>> index.html
	
	
	echo "labl_import_annotation \"aparc.annot\""	> tmp.tcl
	echo "scale_brain 1.35"							>>tmp.tcl
	echo "redraw"									>>tmp.tcl
	echo "save_tiff "$sub".lh.lat.hr.tif"			>>tmp.tcl
	echo "rotate_brain_y 180.0"						>>tmp.tcl
	echo "redraw"									>>tmp.tcl
	echo "save_tiff "$sub".lh.med.hr.tif"			>>tmp.tcl
	echo "resize_window 300"						>>tmp.tcl
	echo "rotate_brain_y -180.0"					>>tmp.tcl
	echo "redraw"									>>tmp.tcl
	echo "save_tiff "$sub".lh.lat.lr.tif"			>>tmp.tcl
	echo "rotate_brain_y 180.0"						>>tmp.tcl
	echo "redraw"									>>tmp.tcl
	echo "save_tiff "$sub".lh.med.lr.tif"			>>tmp.tcl
	echo "exit 0"									>>tmp.tcl
	tksurfer $sub lh pial -tcl tmp.tcl

	echo "labl_import_annotation \"aparc.annot\""	> tmp.tcl
	echo "scale_brain 1.35"							>>tmp.tcl
	echo "redraw"									>>tmp.tcl
	echo "save_tiff "$sub".rh.lat.hr.tif"			>>tmp.tcl
	echo "rotate_brain_y 180.0"						>>tmp.tcl
	echo "redraw"									>>tmp.tcl
	echo "save_tiff "$sub".rh.med.hr.tif"			>>tmp.tcl
	echo "rotate_brain_y -180.0"					>>tmp.tcl
	echo "resize_window 300"						>>tmp.tcl
	echo "redraw"									>>tmp.tcl
	echo "save_tiff "$sub".rh.lat.lr.tif"			>>tmp.tcl
	echo "rotate_brain_y 180.0"						>>tmp.tcl
	echo "redraw"									>>tmp.tcl
	echo "save_tiff "$sub".rh.med.lr.tif"			>>tmp.tcl
	echo "exit 0"									>>tmp.tcl
	tksurfer $sub rh pial -tcl tmp.tcl
	
	rm tmp.tcl
  fi
done;
echo "</table>"										>> index.html
echo "</html>"										>> index.html


