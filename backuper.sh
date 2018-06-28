#!/bin/bash

echoerr() { echo "$@" 1>&2; exit 1; }

params=( "$@" )
count=${#params[@]}
if [ $count -lt 2 ]; then
    echoerr "passed less then 2 parameters"
elif [ $count -gt 2 ]; then
    echoerr "passed more then 2 parameters"
fi

source="${params[0]}"
number=${params[1]}
if [ ! -z `echo $number | sed 's/[0-9]*//g'` ]; then
    echoerr "count of backups is not a positive number ($number)"
fi
if [ ! $number -gt 0 ]; then
    echoerr "uncorrent number of backups ($number), must be greater 0"
fi    

if [ ! -f "$source" ] && [ ! -d "$source" ]; then
    echoerr "source not found ($source)"
fi

destination="/tmp/backup"
if [ ! -d $destination ]; then
    mkdir -p $destination
fi

name=`echo "$source" | sed 's/^\///' | sed 's/\/$//g' | sed 's/\//-/g'`
current=`ls -1 $destination | grep -e "$name[^-]*\.tar\.gz" | wc -l`
for_del=$(( $current - $number + 1 ))
timestamp=`date +%s%N`
filename="$destination/$name.tar.gz"
if [ -f "$filename" ]; then
    mv "$filename" "$destination/$name.$timestamp.tar.gz"
fi
if [ $for_del -gt 0 ]; then
    cur_path=`pwd`
    cd $destination
    ls -1 $destination | grep -e "$name[^-]*\.tar\.gz" | sed -e 's/\(.*\)/"\1"/' | sort | head "-n$for_del" | xargs rm
    cd $cur_path
fi
tar -czf "$destination/$name.tar.gz" "$source" 2> /dev/null
