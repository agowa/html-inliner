#!/bin/sh

# Call tidy for sanitizing
cp main/index.html main/index.ea742abd-3300-47dc-ae64-3157acdc917f.html
tidy --doctype html5 -asxhtml -indent --show-warnings no main/index.ea742abd-3300-47dc-ae64-3157acdc917f.html > main/index.html || if [ $? -ne 1 ]; then exit 100; fi
rm -f main/index.ea742abd-3300-47dc-ae64-3157acdc917f.html

# Inline all svg files.
pushd main
for f in *.svg
do
    uuid=`uuidgen`
    # Add unique uuid to id's within the svg file to prevent overlapping css
    sed -i "s/glyph0-/$uuid-glyph0-/" $f
    sed -i 's/<g id="surface/<g id="'"$uuid"'-surface/' $f
    sed -i 's/clipPath id="clip/clipPath id="'"$uuid"'-clip/' $f
    sed -i 's/clip-path="url(#clip/clip-path="url(#'"$uuid"'-clip/' $f
    sed -i 's/<?xml version="1.0" encoding="UTF-8"?>//' $f
    # Replace img node where `src="$f"` with uuid
    sed -i ':a;N;$!ba; s|<img[^>]*src="'"$f"'"[^>]*>|'"$uuid"'|g' index.html
    # replace uuid with content of $f
    sed -i -e "/$uuid/{r $f" -e "d}" index.html
done

# Inline *.css
for f in *.css
do
    sed -i 's/<link rel="STYLESHEET" href="'"$f"'"[^>]*>/<style type="text\/css">\n<\/style>/' index.html
    sed -i '/<style type="text\/css">/ r '"$f"'' index.html
done
popd

# Add doctype header if not present
sed '/^<!DOCTYPE html>/{q 0};{q 1}' main/index.html || sed -i '1s/^/<!DOCTYPE html>/' main/index.html

# Call tidy for sanitizing
tidy --doctype html5 -asxhtml -indent --show-warnings no main/index.html > public/index.html || if [ $? -ne 1 ]; then exit 100; fi
