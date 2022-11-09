#!/usr/bin/env fish
set folder "public/images/sound-library"
for image in $(ls $folder | grep -v ".webp")
    string match -r "^(?<filename>.*)\.\w+\$" $image
    imagew -w 300,220 --outfmt webp -bkgd fff $folder/$image $folder/$filename.webp
end