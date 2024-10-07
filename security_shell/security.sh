#!/bin/bash
RED="\e[31m"
GREEN="\e[32m"
YELLO="\e[33m"
BLUE="\e[34m"
RESET="\e[00m"

#RF=`hostname`"_"`date +%F__%T`.txt    #result file name
RF=report.txt

function func_print_msg() {
	if [[ $1 =~ "Yes" ]]; then	#Yes/No 질문시 줄바꿈 및 파일 저장 안함 
		echo -n -e $2 $1 ${RESET}	#2번째 파라메터는 Color 
	elif  [[ $# == 2  ]]; then
		echo -e $2 $1 ${RESET}	#2번째 파라메터는 Color 
	else   						#파라메터개수가 1개일때 
        echo $1 | tee -a $RF
	fi
}
function func_system_info() {

	func_print_msg "===========리눅스 취약점 진단 스크립트===========" 
	func_print_msg "	시스템 기본 정보" 
    func_print_msg "	- 운영체제	:  `cat /etc/lsb-release | sed -n 4p | awk -F '\"' '{print $2}'`"
    func_print_msg "	- 호스트이름	:  $(uname -n) ($(ifconfig enp0s3 | sed -n 2p | awk '{printf $2}' )) " 
    func_print_msg "	- 커널 버전	:  `uname -r` "
	func_print_msg "================================================="
	func_print_msg ""
}


if [ "$EUID" -ne 0 ]; then 
	func_print_msg " root 권한으로 스크립트를 실행하세요." $RED
	exit
fi

clear
func_print_msg " 리눅스 서버 취약점 분석/평가를 진행합니다 (Yes/No)? " $BLUE 
read answer
if [[ $answer =~ ^([nN]|[nN][oO])$ ]]; then
	exit 1
fi

clear
echo | tee $RF
func_system_info
IFS=$'\n'
menuList=($(cat menulist))
menuCount=${#menuList[@]}
#echo ${menuList[@]}
func_print_msg "=== 메 뉴 ==="
while [ "$menu" != "종료" ] 
do
	PS3="Select a menu (1-${menuCount}) : "
	select menu in ${menuList[@]}; do
        funcName=$(echo "${menu}" | awk -F':' '{printf $1}')
        if [[ "$funcName" =~ "U-" ]]; then		#U-01	
			source ${funcName}.sh 2> /dev/null
			if [ $? -eq 0 ]; then
        		$funcName				#함수 호출 
			else
				func_print_msg "${funcName}.sh 파일이 없습니다 "
			fi
		fi
		case $menu in ${menuList[$menuCount-1]}) 		#마지막메뉴 "종료"	
			break;;	
		esac
       	read -p "Press enter to go back to menu "
		clear
		func_print_msg "=== 메 뉴 ==="
	done
done
cat $RF
