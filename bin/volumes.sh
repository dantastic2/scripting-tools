
datadir="/Users/dwatson/scripting-tools/data"


#UHD Remux
volumes=("T9 Black 1" "T9 Black 2" "T9 Black 3")
volumes+=("T7 Black 1" "T7 Black 2" "T7 Black 3")
volumes+=("T7 Grey 1" "T7 Grey 2" "T7 Grey 3" "T7 Grey 4")
volumes+=("BlueSheild1" "BlueSheild2","T7 White", "T7 Blue")
volumes+=("CrucialX10", "CrucialX9", "SanDisk2T", "WD 1TB")

#HD Remux
volumes+=("Orange" "Teal", "Sky Blue", "CrucialX9", "Sandisk 2TB")

#Network Drives
volumes+=("Seagate20A" "Seagate20B", "Seagate20C", "Seagate20D", "Seagate26", "Seagate16UHD")


formats=("UHD Remux" "HD Remux", "UHD", "HD","DVD","SD")


# Loop through all items in the specified directory
for item in "/Volumes"/*; do
	volume="$(basename "$item")"
	outputName="${volume// /}"
	if [[ ${volumes[@]} =~ $volume ]] 
		then 
			echo $volume	
			driveType="ssd"; #default
			if [[ $volume =~ 'Seagate' ]]; then
				driveType="hdd";
			fi
			files=$(find "/Volumes/$volume/Movies/HD Remux/" -type f -exec basename {} \; 2>/dev/null | sort | grep -v "._")
			files+=$(find "/Volumes/$volume/HD Remux/" -type f -exec basename {} \; 2>/dev/null | sort | grep -v "._")
			if [ ${#files} -gt 0 ] 
			then
				echo "$files"  > $datadir/movielist/$driveType/$outputName.hdremux.lst
			fi
			filesUHD=$(find "/Volumes/$volume/UHD Remux/" -type f -exec basename {} \; 2>/dev/null | sort | grep -v "._")
			if [ ${#filesUHD} -gt 0 ] 
			then
				echo "$filesUHD"  > $datadir/movielist/$driveType/$outputName.uhdremux.lst
			fi
	fi
done

df -h /volumes/* > $datadir/diskUsage.lst
cat $datadir/movielist/ssd/*.uhdremux.* | sort > $datadir/movielist/uhdremux_ssd.lst
cat $datadir/movielist/hdd/*.uhdremux.* | sort > $datadir/movielist/uhdremux_hdd.lst
cat $datadir/movielist/ssd/*.hdremux.* | sort > $datadir/movielist/hdremux_ssd.lst
cat $datadir/movielist/hdd/*.hdremux.* | sort > $datadir/movielist/hdremux_hdd.lst

