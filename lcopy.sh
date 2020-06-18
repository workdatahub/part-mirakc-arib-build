#!/bin/bash

var_sourceList=`cat $1`
var_destdir=$2
var_destdir=${var_destdir%/}
mkdir -p $var_destdir

while read var_source; do
    var_destination=${var_destdir}${var_source}
    cp --archive --parents --no-dereference ${var_source} ${var_destdir}
done << END
    $var_sourceList
END

