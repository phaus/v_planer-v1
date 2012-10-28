#/bin/bash

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

echo "
######################################################
#                                                    #
#     MOBILE WIDGET DELIVERY PREPARATION SCRIPT      #
#                                                    #
######################################################

Please answer the following questions to prepare a 
delta delivery package for operations.

Which MWP Edition do want to deliver?

[1] Consumer Edition
[2] Developer Edition
[3] quit
"
# read input and check if value is in range
while read -p "please enter a number: "  MWPEDITION_SELECTION
do
	# is given value one of the numbers not 1 or 2
  if echo $MWPEDITION_SELECTION | grep [^1-2] > /dev/null
  then
		# q is also allowed to quit...
    if [ "$MWPEDITION_SELECTION" = "q" ]
    then
      echo "You entered $MWPEDITION_SELECTION - Delivery Script Quits..."
      exit 0
    fi                                                                          
    echo "Unknown number. Please use 1, 2 or 3"
	else
		# given value is numric; we can continue with input
		case $MWPEDITION_SELECTION in 
			"1") MWPEDITION="mwp-consumer"; break
			;; 
			"2") MWPEDITION="mwp-dev"; break 
			;; 
			"3") exit 1 
			;; 
		esac
	fi  
done


DATEPREFIX=`date +'%Y%m%d%H%M'`

echo "creating and navigating to $HOME/tmp/mwp-delivery dir..."
DELIVERYTMP="$HOME/tmp/mwp-delivery"
mkdir -p $DELIVERYTMP
cd $DELIVERYTMP

rm -rf $DELIVERYTMP/*

read -p "Which is the newer release number (.../$MWPEDITION/tags/?): " NEW_RELEASE
read -p "Which is the older release number (.../$MWPEDITION/tags/?): " OLD_RELEASE

OLDER_RELEASE_NAME=""$MWPEDITION"-tag-"$OLD_RELEASE
NEW_RELEASE_NAME=""$MWPEDITION"-tag-"$NEW_RELEASE
PACKAGE_NAME=""$MWPEDITION"-delta-from-"$OLD_RELEASE"-to-"$NEW_RELEASE"-"$DATEPREFIX".tgz"

svn export https://intra.vfnet.de:666/vs/common/$MWPEDITION/tags/$OLD_RELEASE $OLDER_RELEASE_NAME
svn export https://intra.vfnet.de:666/vs/common/$MWPEDITION/tags/$NEW_RELEASE $NEW_RELEASE_NAME

$MY_PATH/deltaCollector.sh  $NEW_RELEASE_NAME $OLDER_RELEASE_NAME delta
cd $DELIVERYTMP/delta
cp $NEW_RELEASE_NAME/README .
tar -czvf $PACKAGE_NAME $NEW_RELEASE_NAME README removedFiles.txt 

echo "

Delta package between the tags $NEW_RELEASE and $OLD_RELEASE has been created here:

$DELIVERYTMP/delta/$PACKAGE_NAME"

read -p "Shall this script transfer it to XTRIAL? [y/n]: " TO_XTRIAL

if [ "$TO_XTRIAL" == "y" ]
then
	scp $DELIVERYTMP/delta/$PACKAGE_NAME  mwpdev@xtrial1.dev.vfnet.de:/home/mwpdev/deliveries/

	echo "Package can be found here:
	 mwpdev@xtrial1.dev.vfnet.de:/home/mwpdev/deliveries/$PACKAGE_NAME
	"
fi

echo "bye"

