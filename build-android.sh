#!/bin/bash
#
# タイトル
#
# filename:  build-android.sh
# 
# @version   1.0.0
# @copyright Copyright (C) 2018 CREANSMAERD CO.,LTD. All rights reserved.
# @date      2018-03-20
# @author    木屋 善夫
#

# 使用法を表示
# 
# @params number リターンコード
# @params string エラーメッセージ(省略可)
# @return シェルスクリプトを終了するので戻りません
function usage_exit() {
	if [ "$2" ] ; then
		echo ${2}
	fi

	cat << _EOL_
アンドロイド用ビルドバッチ
usage: $ build-android.sh -bu
-b: ビルド不要
-u: アップロード不要
_EOL_

	exit $1;
}

# コマンドをエコーして実行
# $DEBUG が TRUE のときは実行しない
# 
# @param $1 コマンド
# @param $2〜$9 引数
function _exec {
	local cmd=$1
	local res=0;
	shift
	echo -e "\e[33;1m\$ ${cmd}" "$@" "\e[m"

	if [ ! "$DEBUG" ]; then
		# $DEBUG が空なのでコマンドを実行
		$cmd "$@"
		res=$?
	fi
	return $res
}

# グローバル変数
NO_BUILD=0
NO_UPLOAD=0

# オプション取得
while getopts buh OPT; do
		case $OPT in
				b)  NO_BUILD=1
						;;
				u)  NO_UPLOAD=1
						;;
				h)  usage_exit
						;;
				*) usage_exit
						;;
		esac
done
shift $((OPTIND - 1))


NAME="nicoliq"
ID="com.prograrts.nicoliq"

if [ ${NO_BUILD} -ne 1 ]; then
	# 起動時にパスワードを求める
	printf "sudo password: "
	read -s password
	echo
	# ビルド
	_exec ionic cordova build android --prod --release
	# 署名
	WORKSPACE=`pwd`
	_exec pushd ./platforms/android/app/build/outputs/apk/release
	_exec cp app-release-unsigned.apk app-release.apk
	
	echo -e "\e[33;1m\$ jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ${WORKSPACE}/${NAME}-key.jks app-release.apk ${NAME} \e[m"
	echo "$password" | jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore ${WORKSPACE}/${NAME}-key.jks app-release.apk ${NAME}

	_exec rm ${NAME}.apk
	_exec zipalign -v 4 app-release.apk ${NAME}.apk
	_exec popd
fi

if [ ${NO_UPLOAD} -ne 1 ]; then
	# アンインストール
	_exec adb uninstall ${ID}
	# インストール
	_exec adb install ./platforms/android/app/build/outputs/apk/release/${NAME}.apk
fi