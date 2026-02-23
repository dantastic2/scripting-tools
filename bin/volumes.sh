
#UHD Remux
volumes=("T9 Black 1" "T9 Black 2" "T9 Black 3")
volumes+=("T7 Black 1" "T7 Black 2" "T7 Black 3")
volumes+=("T7 Grey 1" "T7 Grey 2" "T7 Grey 3" "T7 Grey 4")
volumes+=("BlueSheild1" "BlueSheild2","T7 White", "T7 Blue")
volumes+=("CrucialX10", "CrucialX9", "SanDisk2T", "WD 1TB")

#HD Remux
volumes+=("Orange" "Teal", "Sky Blue", "CrucialX9", "Sandisk 2TB")

formats=("UHD Remux" "HD Remux", "UHD", "HD","DVD","SD")


# Loop through all items in the specified directory
for item in "/Volumes"/*; do
	volume="$(basename "$item")"
	outputName="${volume// /}"
	if [[ ${volumes[@]} =~ $volume ]] 
		then 
			echo $volume	
			files=$(find "/Volumes/$volume/Movies/HD Remux/" -type f -exec basename {} \; 2>/dev/null | sort | grep -v "._")
			files+=$(find "/Volumes/$volume/HD Remux/" -type f -exec basename {} \; 2>/dev/null | sort | grep -v "._")
			if [ ${#files} -gt 0 ] 
			then
				echo "$files"  > ~/scripting-tools/data/movielist/ssd/$outputName.hdremux.lst
			fi
			filesUHD=$(find "/Volumes/$volume/UHD Remux/" -type f -exec basename {} \; 2>/dev/null | sort | grep -v "._")
			if [ ${#filesUHD} -gt 0 ] 
			then
				echo "$filesUHD"  > ~/scripting-tools/data/movielist/ssd/$outputName.lst
			fi
	fi
done


#find /Volumes/Seagate20X/UHD\ Remux/ -type f -exec basename {} \; | sort > ~/movielist/hdd/Seagate20X.lst


#ls /Volumes/Crucial\ BX/TV > ~/tvlist/ssd/CrucialBX.lst;
#cat ssd/* | sort > tv_ssd_comp.lst
#ls /Volumes/Seagate20X/TV > ~/tvlist/hdd/Seagate20X.lst
#cat hdd/* | sort > tv_hdd_comp.lst

