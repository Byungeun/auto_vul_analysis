function U-01() {
#	answer=$(ps -ef | grep -v "grep" |  grep sshd | wc -l)
#	if [ $answer -eq 0 ]; then
#		echo "sshd 서비스가 시작되지 않았습니다." | tee -a $RF  
#		return	
#	fi

	answer=$(systemctl status sshd | sed -n 3p | awk '{print }')
	if [[ $answer == "inactive" ]]; then
		echo "sshd 서비스가 시작되지 않았습니다." | tee -a $RF  
		return	
	fi

	answer=$(awk '/^PermitRootLogin/{print $2}' /etc/ssh/sshd_config)
#	echo "TEST0 $answer"
	if [ $? -ne 0 ]; then
		echo "ssh 서버가 설치 되지 않았습니다." | tee -a $RF 
	elif [[ $answer == "yes" ]]; then
		echo "root 계정 원격 접속이 허용되어 있습니다." | tee -a $RF
	elif [[ $answer == "no" ]]; then
		echo "root 계정 원격 차단 되어 있습니다."  | tee -a $RF
	elif [ -z $answer  ]; then
		echo "설정 파일을 확인하세요!" | tee -a $RF 
	else	
		echo "설정값이 잘못되었습니다" | tee -a $RF
	fi
}
