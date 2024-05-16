#!/usr/bin/bash
find ../static -name index.html | grep fgd | while read file ; do
    mv $file $file.org
    awk -F '"' '/rel="stylesheet"/ {gsub(/link href="/, ("link href=\"" url "/fastop/fgd/"))} /script/ {gsub(/src="/, ("src=\"" url "/fastop/fgd/"))} {print}' url=$1 $file.org > $file
done
