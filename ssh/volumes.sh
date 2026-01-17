
volumes=("T9 Black 1" "T9 Black 2" "T9 Black 3")
volumes+=("T7 Black 1" "T7 Black 2" "T7 Black 3")
volumes+=("T7 Grey 1" "T7 Grey 2" "T7 Grey 3" "T7 Grey 4")
volumes+=("BlueSheild1" "BlueSheild2", "T7 White")
volumes+=("CrucialX10")


# Loop through all items in the specified directory
for item in "/Volumes"/*; do
	volume="$(basename "$item")"
	outputName="${volume// /}"
	if [[ ${volumes[@]} =~ $volume ]] 
		then 
			echo $volume
			find "/Volumes/$volume/UHD Remux/" -type f -exec basename {} \; | sort > ~/movielist/ssd/$outputName.lst1
	fi
done
