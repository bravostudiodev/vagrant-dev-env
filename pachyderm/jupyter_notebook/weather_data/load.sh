#!/bin/bash

FILES=*

REPO="weather"

pachctl create-repo $REPO

#ls *-*-* | while read -r file; do echo "$file"; pachctl put-file $REPO master $file -c -f $file; done
for f in $FILES
do
	if [ "$f" != "load.sh" ]
	then
		echo $f
		pachctl put-file $REPO master $f -c -f $f
	fi
done
