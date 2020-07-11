#!/bin/sh

check_tools() {
  tools="ffmpeg"
  for tool in $tools; do
    if [ ! "$(command -v "$tool")" ]; then
      printf "\e[1m%s\e[0m not found! Exiting....\n" "$tool"
      exit 1
    fi
  done
}

check_tools

{
  find . ! -name "$(printf "*\n*")" -name '*.mp4' 2>/dev/null
  find . ! -name "$(printf "*\n*")" -name '*.MP4' 2>/dev/null
} >tmp

if [ "$(cat tmp)" = "" ]; then
  echo "Error: No files found! Exiting...."
  rm tmp
  exit 1
fi


while IFS= read -r file; do
  count=$((count + 1))
  file="$(echo "$file" | cut -d '/' -f 2)"
  files="$files-i \"$file\" "
done <tmp
rm tmp

for i in $(seq 1 $count); do
  iterator=$((i - 1))
  filter_complex="${filter_complex}[$iterator:v] [$iterator:a] "
done

echo "Merging $count files..."

eval ffmpeg -hide_banner -loglevel panic "$files" -filter_complex \""$filter_complex" concat=n="$count":v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \""${PWD##*/}"\".mp4 </dev/null

ffmpeg_status="$?"
if [ "$ffmpeg_status" != 0 ]; then
  echo "Something went wrong. Error: $ffmpeg_status"
else
  echo "Merged $count files!"
fi

printf "Press enter to exit..."
read -r
