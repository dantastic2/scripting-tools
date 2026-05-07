#Shell commands

find . -exec mkvmerge -o 'tmp/{}' -s eng,en,en-us -a eng,en-us '{}' \;

mkvmerge -o '/Users/dwatson/Downloads/ThunderCats (1985)/ThunderCats - Season 01/thunderkitty.mkv' -s eng,en,en-us -a eng,en-us  '/Users/dwatson/Downloads/ThunderCats (1985)/ThunderCats - Season 01/ThunderCats - S01E02 The Unholy Alliance.mkv'




mediaInfo --output=JSON me\ falling\ on\ storage\ building\ ramp.mp4 | jq

mediaInfo --Inform="Video;%CodecID%" me\ falling\ on\ storage\ building\ ramp.mp4

#Subtracting numbers from a filename: 
rename 's/^Dragon Ball - 0*\K(\d+)/$1-122/e' *.*

sudo launchctl stop org.samba.smbd; sudo launchctl start org.samba.smbd;

#Remove leading spaces:  (-n option simulates) 
rename -n 's/^ *//' *

#Remove first four characters: 
rename -n 's/.{4}(.*)/$1/' *

ls -v | sort | cat -n | while read n f; do echo "mv \"$f\" \"Dark Shadows - S21E$n DS-${f#*e}\""; done


defaults write com.apple.screencapture location [Path_to_Your_Folder]
killall SystemUIServer


ffmpeg -i HandBrake/Pumpkinhead\ \(1988\).mkv -i BLURAY/Pumpkinhead\ \(1988\).mkv -filter_complex "[0:v]scale=1920:1080[distorted];[distorted][1:v]libvmaf=n_threads=30" -f null -

ffmpeg -i HandBrake/Rosemary\'s\ Baby\ \(1968\)_compressed.mkv -i BLURAY/Rosemary\'s\ Baby\ \(1968\).mkv -filter_complex libvmaf="n_threads=20" -f null -


find . -name "._*" -exec rm {} \;
sudo lsof | grep Crucial
sudo mdutil -i off /Volumes/Seagate16UHD

ls Newslazer |  sed 's/\./ /g' | sed 's/ mkv/.mkv/g' | grep mkv

for f in */*/*mkv;do fp=$(dirname "$f"); fl=$(basename "$f"); {mv "$fp/$fl" "./$fp.mkv"}; {rm -rf "$fp"}; done;

for f in */*/*mp4;do fp=$(dirname "$f"); fl=$(basename "$f"); {mv "$fp/$fl" "./$fp.mp4"}; {rm -rf "$fp"}; done;

find . \( -name "*.mkv" -o -name "*.avi" -o -name "*.mp4" \) -exec mv {} . \;

find . -name ".*" -exec rm {} \;

cat test1 test2 | sort | uniq -d

for file in *; do
    if [ -f "$file" ]; then
        new_name="${file:3}"
        if [ "$file" != "$new_name" ]; then
            mv "$file" "$new_name"
        fi
    fi
done


#Subtracting numbers from a filename: 
rename 's/^Dragon Ball - 0*\K(\d+)/$1-122/e' *.*

s/\.(?=.*\.)//g


curl -X 'GET' \
  'https://api4.thetvdb.com/v4/search?q=rupauls%20drag%20race' \
  -H 'accept: application/json' \
  -H 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhZ2UiOiIiLCJhcGlrZXkiOiI2NzU0N2EzZS0yZDNiLTQyY2YtOGQxNi03MzZmYjk3OTQ1MTUiLCJjb21tdW5pdHlfc3VwcG9ydGVkIjpmYWxzZSwiZXhwIjoxNzQ3OTc1MjAyLCJnZW5kZXIiOiIiLCJoaXRzX3Blcl9kYXkiOjEwMDAwMDAwMCwiaGl0c19wZXJfbW9udGgiOjEwMDAwMDAwMCwiaWQiOiIyNzA3Mjc1IiwiaXNfbW9kIjpmYWxzZSwiaXNfc3lzdGVtX2tleSI6ZmFsc2UsImlzX3RydXN0ZWQiOmZhbHNlLCJwaW4iOiIxMjM0Iiwicm9sZXMiOltdLCJ0ZW5hbnQiOiJ0dmRiIiwidXVpZCI6IiJ9.NTLwS-98Gn7eDfyA4JcCiwZO9iUnwJENgyGOMUVDk7zt5kOhLlUnd9XNO_qQfqy70-hsKideKbPTIxdIJ_KhyRaiyFDthQjKy2XaYobcOOps1LBUNqzqoXApBrLOskvFKj2VlTB7dxyRUgmPZSsCjPyy44Fi4hqudJTjiBAmb21eCuxWTTIi05UshqrbGnzrRlPC5blsQnCYTyflILq9dJPgers1r4CwU1hig-acYRracjMitCvK52Fs-OATrntYDAmO1ynbHrFZBRFFeAWX7qUf4TAKOsHZmS--mTsTARnN2MoIWoLwRJ8L7nMNsq5n-xhsQT4v0cVtDMVB7PhVPHYipUw3gvrjoaaApzjbaqvRzaJnygAKcseaveuKB5Wpn3IEDgZ9-PaQrSm03gVSY-7QZuIkKLfCR-yFngaoWdVSqm5xsliPU8ZoCPq9jAUtRv7nl1QY1LVmZIwob2F6p_yZ7Q6XU_ETBHOJQkSgLQGvUG023aoSl1DCSsbTIEzRPSQBIpzHBZIWnCm_JCv-2HzJJdBRBbrUQ9VkTqF4P5PVuUIFk4kiTCK5yg9oMB49rjpv5h6c8lFwgEO5B8YSzlAqAIeWXSREUeB6jgd07Ehxs-F03BmWislG90jPEuNHR00Blo9huLyuEW96mQaCd_dVHrZw6FO4GRCGWu94WCQ'


sudo du -h -d 1 | sort
sudo du -h -d 1 2>/dev/null | sort -h
