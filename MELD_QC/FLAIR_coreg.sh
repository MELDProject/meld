#!/bin/bash

echo "<html>" 																						>  index.html
echo "<table>"																						>> index.html
for sub in $(ls ${SUBJECTS_DIR});
do
  if [[ $sub == MELD* ]]  
  then  
	echo "<tr>"																						>> index.html
	echo "<td><a href=\"file:"$sub".T1.tif\"><img src=\""$sub".T1.tif\"></a></td>"	>> index.html
	echo "<td><a href=\"file:"$sub".FLAIR.tif\"><img src=\""$sub".FLAIR.tif\"></a></td>"	>> index.html

	echo "</tr>"																					>> index.html
	echo "<tr>"																						>> index.html
	echo "<td colspan=4><center>"$sub"</center><br></td>"											>> index.html
	echo "</tr>"																					>> index.html

    echo "SetViewPreset 1"              > tmp1.tcl
    echo "RedrawScreen"                       >> tmp1.tcl
    echo "SaveTIFF "$sub".T1.tif"		>> tmp1.tcl
    echo "exit 0"						>>tmp1.tcl
    tkmedit $sub brainmask.mgz -surfs -tcl tmp1.tcl
    echo "SetViewPreset 1"              > tmp2.tcl
    echo "RedrawScreen"                       >> tmp2.tcl
    echo "SaveTIFF "$sub".FLAIR.tif"	>> tmp2.tcl
    echo "exit 0"						>>tmp2.tcl
    tkmedit $sub FLAIR.mgz -surfs -tcl tmp2.tcl

  fi
done;

echo "</table>"										>> index.html
echo "</html>"										>> index.html


