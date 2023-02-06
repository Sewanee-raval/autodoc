#!/bin/bash

ROOT="/home/rgval/Scripts/"
HTTP="/"
OUTPUT="output/index.html" 

# print the html header
echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">' > $OUTPUT
echo "<html><head><title>Index of Network Systems</title></head>" >> $OUTPUT
echo "<body><h1 id="Index_SUBDIR">Index of Network Systems</a></h1>" >> $OUTPUT


i=0
echo "<UL>" >> $OUTPUT
for filepath in `find "$ROOT" -maxdepth 2 -mindepth 1 -type d| sort`; do
  path=`basename "$filepath"`
  echo "  <LI>$path</LI>" >> $OUTPUT
  echo "  <UL>" >> $OUTPUT
  for i in `find "$filepath" -maxdepth 1 -mindepth 1 -type f ! -iname "index.html" | sort`; do
    file=`basename "$i"`
    #echo "    <LI><a href=\"/$path/$file\">$file</a></LI>" >> $OUTPUT
    echo "    <LI><a href=\"$file\">$file</a></LI>" >> $OUTPUT
  done
  echo "  </UL>" >> $OUTPUT
done
echo "</UL>" >> $OUTPUT

# print the footer html
echo "</body></html>" >> $OUTPUT
