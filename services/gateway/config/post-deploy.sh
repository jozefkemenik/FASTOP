#!/usr/bin/bash
find ../static -name index.html | grep -v fgd | while read file ; do
    mv $file $file.org
    awk -F '"' '/base href/ {baseHref=$2} /link rel="stylesheet"/ {gsub($4, (url baseHref $4))} /script/ {gsub(/src="/, ("src=\"" url baseHref))} {print}' url=$1 $file.org > $file
done
