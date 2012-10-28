#!/bin/sh

if [ $# -lt "3" ]
then
	echo "usage: `basename $0` <rails_env> <mwp_base_dir> <mwp_log_file>"
	exit 1
fi

if [ ! -d $2 ]
then
	echo "MWP_BASE_DIR \"$2\" does not exist."
	exit 1
fi

if [ -f $3 ] && [ ! -w $3 ]
then
	echo "MWP_LOG_FILE \"$3\" is not writable."
	exit 1
fi

VERBOSE=1
RAILS_ENV=$1
export VERBOSE
export RAILS_ENV
MWP_BASE_DIR=$2
MWP_LOG_FILE=$3
shift 3

LD_LIBRARY_PATH='/usr/local/lib:/opt/mwpstack/current/lib:/opt/ImageMagick/ImageMagick-6.3.2/lib'
PATH='/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/mwpstack/current/bin'
RUBY_HOME='/opt/mwpstack/current'
RUBYOPT='rubygems'

export LD_LIBRARY_PATH
export PATH
export RUBY_HOME
export RUBYOPT


cd $MWP_BASE_DIR

echo "----------------------------------------------" >> $MWP_LOG_FILE
echo >> $MWP_LOG_FILE

date >> $MWP_LOG_FILE
echo >> $MWP_LOG_FILE

if [ $# -lt "1" ]
then
    # Old cron mode. Execute the predefined tasks
	echo Running cron:todo >> $MWP_LOG_FILE
        rake cron:todo >>$MWP_LOG_FILE 2>&1
	echo >> $MWP_LOG_FILE
	echo Running cron:deploy_to_opco >> $MWP_LOG_FILE
	rake cron:deploy_to_opco >>$MWP_LOG_FILE 2>&1
	echo >> $MWP_LOG_FILE
else
	# New cron mode. Execute the specified tasks
	for i in $*; do
                echo Running ${i} >> $MWP_LOG_FILE
		rake ${i} >>$MWP_LOG_FILE 2>&1
		echo >> $MWP_LOG_FILE
	done
fi

