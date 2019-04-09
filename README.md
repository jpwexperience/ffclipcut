# FFmpeg Script to Cut Clips
Bash script that cuts clips without needing to know much of anything about ffmpeg.

Currently only displays Video, Audio, and Subtitle Streams of input file.

FFmpeg must be installed to run the script properly.
FFmpeg must be compiled with --enable-libass to burn subtitles.

usage: $ bash ffshell.sh input1, input2, ...

Currently output is optimized for .mp4 and .mov formats

Video Stream encoded as H.264 unless crf value of -1 is chosen.

Audio Stream encoded as AAC

Script will search the directory the input file is in for external subtitle files.

Regular Clips (no subtitles) and picture based subtitle burns use the ffmpeg convetion:
	ffmpeg -ss "Start Time" -i "input" -t "Duration" ...
	This is faster but may result in slightly off video starts.
