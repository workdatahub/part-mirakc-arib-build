#!/bin/bash

#  実行ファイルに必要な共有ライブラリをリスト化する。
#
#  - 使い方 - 
#  ./exliblist.sh [実行バイナリファイルのフルパスをリスト化したファイル名] [共有ライブラリのリスト化を出力するファイル名]
#
#  Designed On 2020.05 By kurukurumaware

LF="
"
var_no=0
var_libraryPathList=""
outputFilename=$2

# リンク先のパスを取得してvar_libPathとnot equalだった場合リストに加える
function search_Link(){
    local var_linkSource=$1
    local var_linkPath=`readlink -f ${var_linkSource}`
    if [[ "$var_linkPath" = "$var_linkSource" ]]; then
        :
    else
        printf "found liink    : %s\n" $var_linkPath
        if [[ "$var_libraryPathList" = *${var_linkPath}* ]]; then  #リンク先が既にリスト内にあるかチェック
            :
        else
            # リストにリンク先も追加
            var_libraryPathList="${var_libraryPathList}""${var_linkPath}"$LF
            printf "\033[36madd link source: %s\033[m\n" $var_linkPath
            search_Link $var_linkPath
        fi
    fi
}

function search_Library(){
        local var_newList=""
    local var_libList=`ldd  $1`
    var_no=$(( $var_no+1 ))
    printf "==============     %s     ==============\n" $1

while read line; do
    local var_libPath=${line#*=> };
    var_libPath=${var_libPath% *}
    if [[ "$var_libPath" = /* ]]; then
        printf "found library  : %s\n" $var_libPath
        if [[ "$var_libraryPathList" = *${var_libPath}* ]]; then #ライブラリが既にリスト内にあるかチェック
            :
        else
            var_libraryPathList="${var_libraryPathList}""${var_libPath}"$LF
            printf "\033[36madd path list  : %s\033[m\n" $var_libPath
            # リンクがあればリンク先も追加
            search_Link $var_libPath
            search_Library $var_libPath
        fi
    else
        printf "\033[33mdont add path  : %s\033[m\n" $var_libPath
    fi
  
done << END
    $var_libList
END

    var_no=$(( $var_no-1 ))
    # echo $var_no

}



# 実行ファイルのリストを貰ってリスト行回数分ライブラリの検索を呼び出す
executFileListProcess(){
local executFileList=`cat $1`
# 1つづつバイナリファイルのパスを渡す
while read line; do
    search_Library $line
done << END
$executFileList
END
}

var_libraryPathList=""
executFileListProcess $1

printf "\n----- 依存ライブラリリスト -------\n"
printf "$var_libraryPathList"
printf "$var_libraryPathList" > $outputFilename

