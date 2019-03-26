#!/usr/bin/env bash
inRangeCode=0
in_range () {
	compare=$(($2-1))
	echo "$1 and $compare"
	if (( $1 > $compare )) || (( $1 < -1)); then
		inRange=0
	else
		inRange=1
	fi
}

verboseFl=0
#set flags for input
for i in "$@"; do
	if [[ $i == "-v" ]]; then
		verboseFl=1
	fi
done
#loop through command line arguments
for i in "$@"; do
	#currently only check if extra arguments are files
	if [[ -e $i && $i != "-v" ]]; then 
		base=${i##*/}
		temp=${base%.*}
		dir=${i%$base}
		#will likely be changing containers
		base="$temp"
		ext=${i##*.}
		#echo -e "\nbase: $base dir: $dir ext: $ext"
		#get file information, redirect sterr
		info="$(ffprobe -i "$i" -hide_banner 2>&1)"
		if (( verboseFl == 1 )); then
			echo "$info"
		fi
		streamArr=()
		videoArr=()
		videoMetaArr=()
		videoTypeArr=()
		audioArr=()
		audioMetaArr=()
		audioTypeArr=()
		subtitleArr=()	
		subtitleTypeArr=()
		subtitleMetaArr=()
		#read each line of ffprobe output
		while read -r line; do
			#echo "... $line ..."
			if [[ $line =~ (S|s)"tream"(.*) ]]; then
				#echo "$line"	
				streamArr+=("$line")
				if [[ $line =~ (.*)(V|v)"ideo"(.*) ]]; then
					videoArr+=("$line")
					#this is causing issues if no metadata is available
					#Possibly skips next stream
					read line2
					if [[ $line2 =~  (.*)(M|m)"etadata"(.*) ]]; then
						#echo "metadata"
						read line3
						if [[ $line3 =~  (.*)(T|t)"itle"(.*) ]]; then
							#echo "$line3"
							videoMetaArr+=("$line3")
						fi
					else
						videoMetaArr+=("null")
					fi
				elif [[ $line =~ (.*)(A|a)"udio"(.*) ]]; then
				       	audioArr+=("$line")
					read line2
					if [[ $line2 =~  (.*)()M|m("etadata"(.*) ]]; then
						#echo "metadata"
						read line3
						if [[ $line3 =~  (.*)(T|t)"itle"(.*) ]]; then
							#echo "$line3"
							audioMetaArr+=("$line3")
						fi
					else
						audioMetaArr+=("null")
					fi
				elif [[ $line =~ (.*)(S|s)"ubtitle"(.*) ]]; then
					subtitleArr+=("$line")
					read line2
					if [[ $line2 =~  (.*)(M|m)"etadata"(.*) ]]; then
						#echo "metadata"
						read line3
						if [[ $line3 =~  (.*)(T|t)"title"(.*) ]]; then
							#echo "$line3"
							subtitleMetaArr+=("$line3")
						fi
					else
						subtitleMetaArr+=("null")
					fi
				else
					echo "$line"
					echo "Unidentified Stream"
				fi	

			fi	
		done <<< "$info"
		#print out all streams

		echo -e "\n\t--- Streams ---"
		echo "Number of video streams: ${#videoArr[@]} | Number of audio streams: ${#audioArr[@]} | Number of subtitle streams: ${#subtitleArr[@]}"
		
		
		echo -e "\n\n---------------------------------"
		#echo "number of stream pieces: $temp"
		#for i in ${streamArr[@]}; do
			#
		#done
		videoChoice=0
		if (( ${#videoArr[@]} == 0 )); then
			echo "No Video Tracks"
			videoChoice=-1
		elif (( ${#videoArr[@]} == 1 )); then
			#echo "One Video"
			videoChoice=0
			echo "${videoArr[videoChoice]}"
		else
			count=0
			echo -e "\n\t-Video Streams-"
			for i in "${videoArr[@]}"; do
				firstChunk=${i%%,*}
				mainContent=${firstChunk##*:\ }
				#echo "$firstChunk"
				echo "$count) | $firstChunk"
				type=${mainContent##*:}
				type=${type#\ }
				type=${type%%\ *}
				echo "$type"
				videoTypeArr+=("$type")
				count=$((count+1))
			done
			echo "Type the number corresponding to the video stream you want to use, followed by [ENTER]:"
			read videoChoice
			in_range $videoChoice ${#videoArr[@]} 
			echo "$inRangeCode"
		fi
		audioChoice=0
		if (( ${#audioArr[@]} == 0 )); then
			echo "No Audio Stream"
			audioChoice=-1
		else
			count=0
			echo -e "\n\t-Audio Streams-"
			for i in $(seq 1 ${#audioArr[@]}); do
				echo $i
			done
			for i in "${audioArr[@]}"; do
				firstChunk=${i%%,*}
				mainContent=${firstChunk##*:\ }
				#echo "$firstChunk"
				echo "$count) | $firstChunk"
				type=${mainContent##*:}
				type=${type#\ }
				type=${type%%\ *}
				echo "$type"
				audioTypeArr+=("$type")
				count=$((count+1))
			done
			echo "Type the number corresponding to the audio stream you want to use (-1 for no audio), followed by [ENTER]:"
			read audioChoice
			in_range $audioChoice ${#audioArr[@]} 
			echo "$inRangeCode"
			#echo "$audioChoice"
		fi
		subtitleChoice=0
		if (( ${#subtitleArr[@]} == 0 )); then
			echo "No Subtitle Streams"
			subtitleChoice=-1
			#echo "$subtitleChoice"
		else
			count=0
			echo -e "\n\t-Subtitle Streams-"
			for i in "${subtitleArr[@]}"; do
				firstChunk=${i%%,*}
				mainContent=${firstChunk##*:\ }
				#echo "$firstChunk"
				echo "$count) | $firstChunk"
				type=${mainContent##*:}
				type=${type#\ }
				type=${type%%\ *}
				echo "$type"
				subtitleTypeArr+=("$type")
				count=$((count+1))
			done
			echo "Type the number corresponding to the subtitle stream you want to use (-1 for no subtitles), followed by [ENTER]:"
			read subtitleChoice
			in_range $subtitleChoice ${#subtitleArr[@]} 
			echo "$inRangeCode"
		fi
		if (( $subtitleChoice == -1 )); then
			echo "$subtitleChoice"
		fi
	#Skip argument if it isn't a file
	else
		if [[ $i != "-v" ]]; then
			echo "$i is not a file"
		fi
	fi
	echo -e "\n=========="
done
