#!/bin/sh

# Inline all svg files.
for f in in/*.svg
do
    uuid=`uuidgen`
    # Add unique uuid to id's within the svg file to prevent overlapping css
    sed -i "s/glyph0-/$uuid-glyph0-/" $f
    # Replace img node where `src="$f"` with uuid
    sed -i ':a;N;$!ba; s|<img[^>]*src="'"$f"'"[^>]*/>|'"$uuid"'|g' in/index.html
    # replace uuid with content of $f
    sed -i -e "/$uuid/{r $f" -e "d}" in/index.html
done

# Inline *.css
for f in in/*.css
do
    sed -i 's/<link rel="STYLESHEET" href="'"$f"'">/<style type="text\/css">\n<\/style>/' in/index.html
    sed -i '/<style type="text\/css">/ r '"$f"'' in/index.html
done

# Add doctype header if not present
sed '/^<!DOCTYPE html>/{q 0};{q 1}' in/index.html || sed -i '1s/^/<!DOCTYPE html>/' in/index.html

# Call tidy for sanitizing
tidy --doctype html5 -asxhtml -indent --show-warnings no in/index.html > out/index.html || if [ $? -ne 1 ]; then exit 100; fi
