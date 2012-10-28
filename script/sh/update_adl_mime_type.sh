#!/bin/sh

if [ $# -lt "1" ]
then
	echo "usage: `basename $0` <adl_dir>"
	exit 1
fi

if [ ! -d $1 ]
then
	echo "ADL_DIR \"$2\" does not exist."
	exit 1
fi

ADL_DIR=$1

echo "----------------------------------------------"
echo

date
echo

for f in $ADL_DIR/*.xml
do
   [ -f "$f" ] || continue
   tempfile=`mktemp /tmp/secureXXXXXXXX`
   
   echo "processing $f"
   xsltproc update_adl_mime_type.xsl "$f" > $tempfile
   mv $tempfile "$f"
done 

