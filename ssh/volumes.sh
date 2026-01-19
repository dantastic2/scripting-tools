
#UHD Remux
volumes=("T9 Black 1" "T9 Black 2" "T9 Black 3")
volumes+=("T7 Black 1" "T7 Black 2" "T7 Black 3")
volumes+=("T7 Grey 1" "T7 Grey 2" "T7 Grey 3" "T7 Grey 4")
volumes+=("BlueSheild1" "BlueSheild2", "T7 White")
volumes+=("CrucialX10")

#HD Remux
volumes+=("Orange" "Teal", "Sky Blue", "Crucial")


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
				echo $files  > ~/movielist/ssd/$outputName.hdremux.lst
			fi
			filesUHD=$(find "/Volumes/$volume/UHD Remux/" -type f -exec basename {} \; 2>/dev/null | sort | grep -v "._")
			if [ ${#filesUHD} -gt 0 ] 
			then
				echo $filesUHD  > ~/movielist/ssd/$outputName.lst
			fi
	fi
done