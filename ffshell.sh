#!/usr/bin/env bash
#loop through command line arguments
for i in "$@"; do
	#currently only check if extra arguments are files
	if [[ -e $i ]]; then 
		base=${i##*/}
		temp=${base%.*}
		dir=${i%$base}
		#will likely be changing containers
		base="$temp"
		ext=${i##*.}
		echo "base: $base dir: $dir ext: $ext"
		
		#get file information, redirect sterr
		info="$(ffprobe -i "$i" -hide_banner 2>&1)"
		streamArr=()
		videoArr=()
		audioArr=()
		subtitleArr=()	
		#read each line of ffprobe output
		while read -r line; do
			#echo "... $line ..."
			if [[ $line =~ "Stream"(.*) ]]; then
				echo "$line"	
				streamArr+=("$line")
				if [[ $line =~ (.*)"Video"(.*) ]]; then
					videoArr+=("$line")
				elif [[ $line =~ (.*)"Audio"(.*) ]]; then
				       	audioArr+=("$line")
				elif [[ $line =~ (.*)"subtitle"(.*) ]]; then
					subtitleArr+=("$line")
				else
					echo "Unidentified Stream"
				fi	

			fi	
		done <<< "$info"
		
		#print out all streams
		echo -e "\n--- Streams ---"
		echo "Number of video streams: ${#videoArr[@]}"
		echo "Number of audio streams: ${#audioArr[@]}"
		echo "Number of subtitle streams: ${#subtitleArr[@]}"
		
		for i in "${streamArr[@]}"; do
			#echo "$i"
			suff=${i##*#} #cut off everything preceeding
			pre=${suff%%:*}
			#echo -e "\n$pre\n"
		done
		#echo "number of stream pieces: $temp"
		#for i in ${streamArr[@]}; do
			#
		#done
	
	#Skip argument if it isn't a file
	else
		echo "$i is not a file"
	fi
done
