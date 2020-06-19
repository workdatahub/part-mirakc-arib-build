#!/bin/bash

# リストにフルパスで記載したファイル名の単体ファイルを
# [指定ディレクトリ下+フルパス名]でコピーする
#
#  - 使い方 - 
#  ./lcopy.sh [実行バイナリファイルのフルパスをリスト化したファイル名] [共有ライブラリのリスト化を出力するファイル名]
#
#  Designed On 2020.05 By kurukurumaware

var_sourceList=`cat $1`
var_destdir=$2
var_destdir=${var_destdir%/}
mkdir -p $var_destdir

while read var_source; do
    var_destination=${var_destdir}${var_source}
    cp --archive --parents --no-dereference --preserve ${var_source} ${var_destdir}
done << END
    $var_sourceList
END
