#!/bin/bash
###
# piccopy.sh
# v1.0
# Author: Piotr Modlinger
# Description: Script to copy and deduplicate pictures from /pitmod/home/Obrazy to nasbox:/mediasrv/Zdjecia
#	       Please put your files or directories in /pitmod/home/Obrazy and run the script
# 	       Script to execute interactively

## Modification to function programming



### Declarations
DST_SRV=nasbox
SRC="/home/pitmod/Obrazy/"
DST="/mediasrv/TMP/"
DST_STORE="/mediasrv/Zdjecia/"


### Initial copy Pictures to nasbox for deduplication
echo "== Copy files from $SRC to $DST_SRV:$DST =="
rsync -avhe ssh --progress $SRC $DST_SRV:$DST && echo "Done"


### Deduplicating files
echo "== Deduplicate $DST_SRV:$DST with $DST_SRV:$DST_STORE =="
ssh $DST_SRV "rmlint $DST_STORE $DST"
read -p "Are you sure you want to remove files? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Deduplicating files..."
	ssh $DST_SRV "/home/pitmod/rmlint.sh" && echo "Done"
	
fi
echo "== Copy deduplicated files back from $DST_SRV:$DST to $SRC =="
rsync -avhe ssh --delete --progress $DST_SRV:$DST $SRC && echo "Done"


### Manual categorization of files. Need to create directories in /home/pitmod/Obrazy/ i.e 2018/Wakacje_Wlochy 2017/Rozne 
echo "== Please put pictures into directories i.e ${SRC}2018/Wakacje_Wlochy =="


### Copy deduplicated and categorized files to nasbox: separate rsync for each year folder
read -p "Are you ready to copy directories to nasbox? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
        echo "Copy started..."
	for i in `find $SRC -maxdepth 1 -type d | egrep "[0-9]+"`
	do
		echo "-- $i --"
		rsync -avhe ssh --progress "$i/" $DST_SRV:$DST_STORE"`basename $i`/"
	done && echo "Done"
fi


### Cleanups of remote /mediasrv/TMP/ and local /home/pitmod/Obrazy
echo "== Cleanups =="
read -p "Do you want to cleanup $DST_SRV:$DST and $SRC" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	echo "Cleaning up $DST_SRV:$DST..."
	ssh $DST_SRV "rm -rf ${DST}*"
	echo "Cleaning up $SRC..."
	rm -rf ${SRC}* 
	echo 'Done'
fi
echo 'Thank you and wish you a nice day!'
