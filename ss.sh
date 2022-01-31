Set_config_transfer(){
	while true
	do
	echo
	ssr_transfer=""
	[[ -z "$ssr_transfer" ]] && ssr_transfer="838868" && break
	echo $((${ssr_transfer}+0)) &>/dev/null
	if [[ $? == 0 ]]; then
		if [[ ${ssr_transfer} -ge 1 ]] && [[ ${ssr_transfer} -le 838868 ]]; then
			break
		else
			echo -e "${Error} Введите корректный номер(1-838868)"
		fi
	else
		echo -e "${Error} Введите корректный номер(1-838868)"
	fi
	done
}
Set_config_forbid(){
	ssr_forbid=""
	[[ -z "${ssr_forbid}" ]] && ssr_forbid=""
}
Set_config_enable(){
	user_total=$(echo $((${user_total}-1)))
	for((integer = 0; integer <= ${user_total}; integer++))
	do
		echo -e "integer=${integer}"
		port_jq=$(${jq_file} ".[${integer}].port" "${config_user_udb_file}")
		echo -e "port_jq=${port_jq}"
		if [[ "${ssr_port}" == "${port_jq}" ]]; then
			enable=$(${jq_file} ".[${integer}].enable" "${config_user_udb_file}")
			echo -e "enable=${enable}"
			[[ "${enable}" == "null" ]] && echo -e "${Error} Не удалось получить отключенный статус текущего порта [${ssr_port}]!" && exit 1
			ssr_port_nu=$(cat "${config_user_udb_file}"|grep -n '"port": '${ssr_port}','|awk -F ":" '{print $1}')
			echo -e "ssr_port_nu=${ssr_port_nu}"
			[[ "${ssr_port_nu}" == "null" ]] && echo -e "${Error} Не удалось получить количество строк текущего порта[${ssr_port}]!" && exit 1
			ssr_enable_nu=$(echo $((${ssr_port_nu}-5)))
			echo -e "ssr_enable_nu=${ssr_enable_nu}"
			break
		fi
	done
	if [[ "${enable}" == "1" ]]; then
		echo -e "Порт [${ssr_port}] находится в состоянии：${Green_font_prefix}включен${Font_color_suffix} , сменить статус на ${Red_font_prefix}выключен${Font_color_suffix} ?[Y/n]"
		read -e -p "(По умолчанию: Y):" ssr_enable_yn
		[[ -z "${ssr_enable_yn}" ]] && ssr_enable_yn="y"
		if [[ "${ssr_enable_yn}" == [Yy] ]]; then
			ssr_enable="0"
		else
			echo "Отмена..." && exit 0
		fi
	elif [[ "${enable}" == "0" ]]; then
		echo -e "Порт [${ssr_port}] находится в состоянии：${Green_font_prefix}отключен${Font_color_suffix} , сменить статус на  ${Red_font_prefix}включен${Font_color_suffix} ?[Y/n]"
		read -e -p "(По умолчанию: Y):" ssr_enable_yn
		[[ -z "${ssr_enable_yn}" ]] && ssr_enable_yn = "y"
		if [[ "${ssr_enable_yn}" == [Yy] ]]; then
			ssr_enable="1"
		else
			echo "Отмена..." && exit 0
		fi
	else
		echo -e "${Error} какая то ошибка с акком, гг[${enable}] !" && exit 1
	fi
}
Set_user_api_server_pub_addr(){
	addr=$1
	if [[ "${addr}" == "odify" ]]; then
		server_pub_addr=$(cat ${config_user_api_file}|grep "SERVER_PUB_ADDR = "|awk -F "[']" '{print $2}')
		if [[ -z ${server_pub_addr} ]]; then
			echo -e "${Error} Не получилось получить IP сервера！" && exit 1
		else
			echo -e "${Info} Текущий IP： ${Green_font_prefix}${server_pub_addr}${Font_color_suffix}"
		fi
	fi
	echo "Введите IP сервера"
	read -e -p "(Автоматическое определние IP при нажатии Enter):" ssr_server_pub_addr
	if [[ -z "${ssr_server_pub_addr}" ]]; then
		Get_IP
		if [[ ${ip} == "VPS_IP" ]]; then
			while true
			do
			read -e -p "${Error} Введите IP сервера сами!" ssr_server_pub_addr
			if [[ -z "$ssr_server_pub_addr" ]]; then
				echo -e "${Error} Не может быть пустым！"
			else
				break
			fi
			done
		else
			ssr_server_pub_addr="${ip}"
		fi
	fi
	echo && echo ${Separator_1} && echo -e "	IP сервера : ${Green_font_prefix}${ssr_server_pub_addr}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Set_config_all(){
	lal=$1
	if [[ "${lal}" == "odify" ]]; then
		Set_config_password
		Set_config_ethod
		Set_config_protocol
		Set_config_obfs
		Set_config_protocol_para
		Set_config_speed_liit_per_con
		Set_config_speed_liit_per_user
		Set_config_transfer
		Set_config_forbid
	else
		Set_config_user
		Set_config_port
		Set_config_password
		Set_config_ethod
		Set_config_protocol
		Set_config_obfs
		Set_config_protocol_para
		Set_config_speed_liit_per_con
		Set_config_speed_liit_per_user
		Set_config_transfer
		Set_config_forbid
	fi
}
# Изменить конфигурацию клиента
odify_config_password(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" -k "${ssr_password}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить пароль пользователя ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Пароль пользователя успешно изменен ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_ethod(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" - "${ssr_ethod}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить шифрование ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Шифрование успешно изменено ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_protocol(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" -O "${ssr_protocol}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить протокол ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Протокол успешно изменен ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_obfs(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" -o "${ssr_obfs}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить Obfs plugin ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Obfs plugin успешно изменен ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_protocol_para(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" -G "${ssr_protocol_para}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить лимит устройств ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Лимит устройств успешно изменен ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_speed_liit_per_con(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" -s "${ssr_speed_liit_per_con}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить лимит скорости ключа ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Лимит скорости ключа успешно изменен ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_speed_liit_per_user(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" -S "${ssr_speed_liit_per_user}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить лимит скорости пользователей ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Лимит скорости пользователей успешно изменен ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_connect_verbose_info(){
	sed -i 's/"connect_verbose_info": '"$(echo ${connect_verbose_info})"',/"connect_verbose_info": '"$(echo ${ssr_connect_verbose_info})"',/g' ${config_user_file}
}
odify_config_transfer(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" -t "${ssr_transfer}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить общий трафик пользователя ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Общий трафик пользователя успешно изменен ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_forbid(){
	atch_edit=$(python ujson_gr.py -e -p "${ssr_port}" -f "${ssr_forbid}"|grep -w "edit user ")
	if [[ -z "${atch_edit}" ]]; then
		echo -e "${Error} Не удалось изменить запрещенные порты пользователя ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} " && exit 1
	else
		echo -e "${Info} Запрещенные порты пользователя успешно изменены ${Green_font_prefix}[Порт: ${ssr_port}]${Font_color_suffix} (Может занять около 10 секунд для обновления конфигурации)"
	fi
}
odify_config_enable(){
	sed -i "${ssr_enable_nu}"'s/"enable": '"$(echo ${enable})"',/"enable": '"$(echo ${ssr_enable})"',/' ${config_user_udb_file}
}
odify_user_api_server_pub_addr(){
	sed -i "s/SERVER_PUB_ADDR = '${server_pub_addr}'/SERVER_PUB_ADDR = '${ssr_server_pub_addr}'/" ${config_user_api_file}
}
odify_config_all(){
	odify_config_password
	odify_config_ethod
	odify_config_protocol
	odify_config_obfs
	odify_config_protocol_para
	odify_config_speed_liit_per_con
	odify_config_speed_liit_per_user
	odify_config_transfer
	odify_config_forbid
}
Check_python(){
	python_ver=`python -h`
	if [[ -z ${python_ver} ]]; then
		echo -e "${Info} Python не установлен, начинаю установку..."
		if [[ ${release} == "centos" ]]; then
			yu install -y python
		else
			apt-get install -y python
		fi
	fi
}
Centos_yu(){
	yu update
	cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
	if [[ $? = 0 ]]; then
		yu install -y vi unzip crond net-tools
	else
		yu install -y vi unzip crond
	fi
}
Debian_apt(){
	apt-get update
	cat /etc/issue |grep 9\..*>/dev/null
	if [[ $? = 0 ]]; then
		apt-get install -y vi unzip cron net-tools
	else
		apt-get install -y vi unzip cron
	fi
}
# Скачать ShadowsocksR
Download_SSR(){
	cd "/usr/local"
	wget -N --no-check-certificate "https://github.co/ToyoDAdoubiBackup/shadowsocksr/archive/anyuser.zip"
	#git config --global http.sslVerify false
	#env GIT_SSL_NO_VERIFY=true git clone -b anyuser https://github.co/ToyoDAdoubiBackup/shadowsocksr.git
	#[[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR服务端 下载失败 !" && exit 1
	[[ ! -e "anyuser.zip" ]] && echo -e "${Error} Не удалось скачать архив с ShadowsocksR !" && r -rf anyuser.zip && exit 1
	unzip "anyuser.zip"
	[[ ! -e "/usr/local/shadowsocksr-anyuser/" ]] && echo -e "${Error} Ошибка распаковки ShadowsocksR !" && r -rf anyuser.zip && exit 1
	v "/usr/local/shadowsocksr-anyuser/" "/usr/local/shadowsocksr/"
	[[ ! -e "/usr/local/shadowsocksr/" ]] && echo -e "${Error} Переименование ShadowsocksR неуспешно !" && r -rf anyuser.zip && r -rf "/usr/local/shadowsocksr-anyuser/" && exit 1
	r -rf anyuser.zip
	cd "shadowsocksr"
	cp "${ssr_folder}/config.json" "${config_user_file}"
	cp "${ssr_folder}/ysql.json" "${ssr_folder}/userysql.json"
	cp "${ssr_folder}/apiconfig.py" "${config_user_api_file}"
	[[ ! -e ${config_user_api_file} ]] && echo -e "${Error} Не удалось скопировать apiconfig.py для ShadowsocksR !" && exit 1
	sed -i "s/API_INTERFACE = 'sspanelv2'/API_INTERFACE = 'udbjson'/" ${config_user_api_file}
	server_pub_addr="127.0.0.1"
	odify_user_api_server_pub_addr
	#sed -i "s/SERVER_PUB_ADDR = '127.0.0.1'/SERVER_PUB_ADDR = '${ip}'/" ${config_user_api_file}
	sed -i 's/ \/\/ only works under ulti-user ode//g' "${config_user_file}"
	echo -e "${Info} ShadowsocksR успешно установлен !"
}
Service_SSR(){
	if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/service/ssru_centos -O /etc/init.d/ssru; then
			echo -e "${Error} Не удалось загрузить скрипт для управления ShadowsocksR !" && exit 1
		fi
		chod +x /etc/init.d/ssru
		chkconfig --add ssru
		chkconfig ssru on
	else
		if ! wget --no-check-certificate https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/service/ssru_debian -O /etc/init.d/ssru; then
			echo -e "${Error} Не удалось загрузить скрипт для управления ShadowsocksR !" && exit 1
		fi
		chod +x /etc/init.d/ssru
		update-rc.d -f ssru defaults
	fi
	echo -e "${Info} Скрипт для управления ShadowsocksR успешно установлен !"
}
# Установить парсер JQ
JQ_install(){
	if [[ ! -e ${jq_file} ]]; then
		cd "${ssr_folder}"
		if [[ ${bit} = "x86_64" ]]; then
			v "jq-linux64" "jq"
			#wget --no-check-certificate "https://github.co/stedolan/jq/releases/download/jq-1.5/jq-linux64" -O ${jq_file}
		else
			v "jq-linux32" "jq"
			#wget --no-check-certificate "https://github.co/stedolan/jq/releases/download/jq-1.5/jq-linux32" -O ${jq_file}
		fi
		[[ ! -e ${jq_file} ]] && echo -e "${Error} Парсер JQ не удалось переименовать !" && exit 1
		chod +x ${jq_file}
		echo -e "${Info} Установка JQ завершена, продолжение..." 
	else
		echo -e "${Info} Парсер JQ успешно установлен..."
	fi
}
# Зависимость от установки
Installation_dependency(){
	if [[ ${release} == "centos" ]]; then
		Centos_yu
	else
		Debian_apt
	fi
	[[ ! -e "/usr/bin/unzip" ]] && echo -e "${Error} Установка unzip неуспешна !" && exit 1
	Check_python
	#echo "naeserver 8.8.8.8" > /etc/resolv.conf
	#echo "naeserver 8.8.4.4" >> /etc/resolv.conf
	\cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtie
	if [[ ${release} == "centos" ]]; then
		/etc/init.d/crond restart
	else
		/etc/init.d/cron restart
	fi
}
Install_SSR(){
	check_root
	[[ -e ${ssr_folder} ]] && echo -e "${Error} Shadowsocks уже установлен !" && exit 1
	echo -e "${Info} Подождите пожалуйста..."
	Set_user_api_server_pub_addr
	Set_config_all
	echo -e "${Info} Подождите пожалуйста..."
	Installation_dependency
	echo -e "${Info} Подождите пожалуйста..."
	Download_SSR
	echo -e "${Info} Подождите пожалуйста..."
	Service_SSR
	echo -e "${Info} Подождите пожалуйста..."
	JQ_install
	echo -e "${Info} Подождите пожалуйста..."
	Add_port_user "install"
	echo -e "${Info} Подождите пожалуйста..."
	Set_iptables
	echo -e "${Info} Подождите пожалуйста..."
	Add_iptables
	echo -e "${Info} Подождите пожалуйста..."
	Save_iptables
	echo -e "${Info} Подождите пожалуйста..."
	Start_SSR
	Get_User_info "${ssr_port}"
	Check_Libsodiu_ver
	if [[ ${release} == "centos" ]]; then
		yu update
		echo -e "${Info} Загрузка..."
		yu -y groupinstall "Developent Tools"
		echo -e "${Info} Скачивание..."
		#https://github.co/jedisct1/libsodiu/releases/download/1.0.18-RELEASE/libsodiu-1.0.18.tar.gz
		wget  --no-check-certificate -N "https://github.co/jedisct1/libsodiu/releases/download/${Libsodiur_ver}-RELEASE/libsodiu-${Libsodiur_ver}.tar.gz"
		echo -e "${Info} Распаковка..."
		tar -xzf libsodiu-${Libsodiur_ver}.tar.gz && cd libsodiu-${Libsodiur_ver}
		echo -e "${Info} Установка..."
		./configure --disable-aintainer-ode && ake -j2 && ake install
		echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	else
apt-get update -y && apt install git -y && apt install curl -y && apt install net-tools -y && apt install iptables -y && apt install sudo -y && apt install jq -y && apt install sshpass -y
		echo -e "${Info} Загрузка..."
		apt-get install -y build-essential
		echo -e "${Info} Скачивание..."
		wget  --no-check-certificate -N "https://github.co/jedisct1/libsodiu/releases/download/${Libsodiur_ver}-RELEASE/libsodiu-${Libsodiur_ver}.tar.gz"
		echo -e "${Info} Распаковка..."
		tar -xzf libsodiu-${Libsodiur_ver}.tar.gz && cd libsodiu-${Libsodiur_ver}
		echo -e "${Info} Установка..."
		./configure --disable-aintainer-ode && ake -j2 && ake install
	fi
	ldconfig
	cd .. && r -rf libsodiu-${Libsodiur_ver}.tar.gz && r -rf libsodiu-${Libsodiur_ver}
	[[ ! -e ${Libsodiur_file} ]] && echo -e "${Error} Ошибка установки libsodiu !" && exit 1
	echo && echo -e "${Info} libsodiu успешно установлен !" && echo
View_User_info
}
Update_SSR(){
	SSR_installation_status
	echo -e "Данная функция отключена."
	#cd ${ssr_folder}
	#git pull
	#Restart_SSR
}
Uninstall_SSR(){
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR не установлен !" && exit 1
	echo "Удалить ShadowsocksR？[y/N]" && echo
	read -e -p "(По умолчанию: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		check_pid
		[[ ! -z "${PID}" ]] && kill -9 ${PID}
		user_info=$(python ujson_gr.py -l)
		user_total=$(echo "${user_info}"|wc -l)
		if [[ ! -z ${user_info} ]]; then
			for((integer = 1; integer <= ${user_total}; integer++))
			do
				port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
				Del_iptables
			done
			Save_iptables
		fi
		if [[ ! -z $(crontab -l | grep "ssru.sh") ]]; then
			crontab_onitor_ssr_cron_stop
			Clear_transfer_all_cron_stop
		fi
		if [[ ${release} = "centos" ]]; then
			chkconfig --del ssru
		else
			update-rc.d -f ssru reove
		fi
		r -rf ${ssr_folder} && r -rf /etc/init.d/ssru
		echo && echo " ShadowsocksR успешно удален !" && echo
	else
		echo && echo " Отмена..." && echo
	fi
}
Check_Libsodiu_ver(){
	echo -e "${Info} Начинаю получение последней версии libsodiu..."
	Libsodiur_ver=$(wget -qO- "https://github.co/jedisct1/libsodiu/tags"|grep "/jedisct1/libsodiu/releases/tag/"|head -1|sed -r 's/.*tag\/(.+)\">.*/\1/')
	[[ -z ${Libsodiur_ver} ]] && Libsodiur_ver=${Libsodiur_ver_backup}
	echo -e "${Info} Последняя версия libsodiu: ${Green_font_prefix}${Libsodiur_ver}${Font_color_suffix} !"
}
Install_Libsodiu(){
	if [[ -e ${Libsodiur_file} ]]; then
		echo -e "${Error} libsodiu уже установлен, желаете перезаписать(обновить)？[y/N]"
		read -e -p "(По умолчанию: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Nn] ]]; then
			echo "Отмена..." && exit 1
		fi
	else
		echo -e "${Info} libsodiu не установлен, начинаю установку..."
	fi
	Check_Libsodiu_ver
	if [[ ${release} == "centos" ]]; then
		yu update
		echo -e "${Info} бла бла бла..."
		yu -y groupinstall "Developent Tools"
		echo -e "${Info} скачивание..."
		#https://github.co/jedisct1/libsodiu/releases/download/1.0.18-RELEASE/libsodiu-1.0.18.tar.gz
		wget  --no-check-certificate -N "https://github.co/jedisct1/libsodiu/releases/download/${Libsodiur_ver}-RELEASE/libsodiu-${Libsodiur_ver}.tar.gz"
		echo -e "${Info} распаковка..."
		tar -xzf libsodiu-${Libsodiur_ver}.tar.gz && cd libsodiu-${Libsodiur_ver}
		echo -e "${Info} установка..."
		./configure --disable-aintainer-ode && ake -j2 && ake install
		echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
	else
		apt-get update
		echo -e "${Info} бла бла бла..."
		apt-get install -y build-essential
		echo -e "${Info} скачивание..."
		wget  --no-check-certificate -N "https://github.co/jedisct1/libsodiu/releases/download/${Libsodiur_ver}-RELEASE/libsodiu-${Libsodiur_ver}.tar.gz"
		echo -e "${Info} распаковка..."
		tar -xzf libsodiu-${Libsodiur_ver}.tar.gz && cd libsodiu-${Libsodiur_ver}
		echo -e "${Info} установка..."
		./configure --disable-aintainer-ode && ake -j2 && ake install
	fi
	ldconfig
	cd .. && r -rf libsodiu-${Libsodiur_ver}.tar.gz && r -rf libsodiu-${Libsodiur_ver}
	[[ ! -e ${Libsodiur_file} ]] && echo -e "${Error} Установка libsodiu неуспешна !" && exit 1
	echo && echo -e "${Info} libsodiu успешно установлен !" && echo
}
# Отображение информации о подключении
debian_View_user_connection_info(){
	forat_1=$1
	user_info=$(python ujson_gr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} Пользователь не найден !" && exit 1
	IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |wc -l`
	user_list_all=""
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp6' |grep ":${user_port} " |awk '{print $5}' |awk -F ":" '{print $1}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
		if [[ -z ${user_IP_1} ]]; then
			user_IP_total="0"
		else
			user_IP_total=`echo -e "${user_IP_1}"|wc -l`
			if [[ ${forat_1} == "IP_address" ]]; then
				get_IP_address
			else
				user_IP=`echo -e "\n${user_IP_1}"`
			fi
		fi
		user_info_233=$(python ujson_gr.py -l|grep -w "${user_port}"|awk '{print $2}'|sed 's/\[//g;s/\]//g')
		user_list_all=${user_list_all}"Юзер: ${Green_font_prefix}"${user_info_233}"${Font_color_suffix} Порт: ${Green_font_prefix}"${user_port}"${Font_color_suffix} Кол-во IP: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix} Подкл. юзеры: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
		user_IP=""
	done
	echo -e "Всего пользователей: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} Общее число IP адресов: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix} "
	echo -e "${user_list_all}"
}
centos_View_user_connection_info(){
	forat_1=$1
	user_info=$(python ujson_gr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} Пользователь не найден !" && exit 1
	IP_total=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp' | grep '::ffff:' |awk '{print $5}' |awk -F ":" '{print $4}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" |wc -l`
	user_list_all=""
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		user_IP_1=`netstat -anp |grep 'ESTABLISHED' |grep 'python' |grep 'tcp' |grep ":${user_port} "|grep '::ffff:' |awk '{print $5}' |awk -F ":" '{print $4}' |sort -u |grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
		if [[ -z ${user_IP_1} ]]; then
			user_IP_total="0"
		else
			user_IP_total=`echo -e "${user_IP_1}"|wc -l`
			if [[ ${forat_1} == "IP_address" ]]; then
				get_IP_address
			else
				user_IP=`echo -e "\n${user_IP_1}"`
			fi
		fi
		user_info_233=$(python ujson_gr.py -l|grep -w "${user_port}"|awk '{print $2}'|sed 's/\[//g;s/\]//g')
		user_list_all=${user_list_all}"Юзер: ${Green_font_prefix}"${user_info_233}"${Font_color_suffix} Порт: ${Green_font_prefix}"${user_port}"${Font_color_suffix} Кол-во IP: ${Green_font_prefix}"${user_IP_total}"${Font_color_suffix} Подкл. юзеры: ${Green_font_prefix}${user_IP}${Font_color_suffix}\n"
		user_IP=""
	done
	echo -e "Всего пользователей: ${Green_background_prefix} "${user_total}" ${Font_color_suffix} Всего IP адресов: ${Green_background_prefix} "${IP_total}" ${Font_color_suffix} "
	echo -e "${user_list_all}"
}
View_user_connection_info(){
	SSR_installation_status
	echo && ssr_connection_info="1"
	if [[ ${ssr_connection_info} == "1" ]]; then
		View_user_connection_info_1 ""
	elif [[ ${ssr_connection_info} == "2" ]]; then
		echo -e "${Tip} Замечен(ipip.net)，если там больше IP адресов, может занять больше времени..."
		View_user_connection_info_1 "IP_address"
	else
		echo -e "${Error} Введите корректный номер(1-2)" && exit 1
	fi
}
View_user_connection_info_1(){
	forat=$1
	if [[ ${release} = "centos" ]]; then
		cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
		if [[ $? = 0 ]]; then
			debian_View_user_connection_info "$forat"
		else
			centos_View_user_connection_info "$forat"
		fi
	else
		debian_View_user_connection_info "$forat"
	fi
}
get_IP_address(){
	#echo "user_IP_1=${user_IP_1}"
	if [[ ! -z ${user_IP_1} ]]; then
	#echo "user_IP_total=${user_IP_total}"
		for((integer_1 = ${user_IP_total}; integer_1 >= 1; integer_1--))
		do
			IP=`echo "${user_IP_1}" |sed -n "$integer_1"p`
			#echo "IP=${IP}"
			IP_address=`wget -qO- -t1 -T2 http://freeapi.ipip.net/${IP}|sed 's/\"//g;s/,//g;s/\[//g;s/\]//g'`
			#echo "IP_address=${IP_address}"
			user_IP="${user_IP}\n${IP}(${IP_address})"
			#echo "user_IP=${user_IP}"
			sleep 1s
		done
	fi
}
# Изменить конфигурацию пользователя
odify_port(){
	List_port_user
	Set_config_password
	odify_config_password
	while true
	do
		echo -e "Введите порт пользователя, аккаунт которого нужно изменить"
		read -e -p "(По умолчанию: отмена):" ssr_port
		[[ -z "${ssr_port}" ]] && echo -e "已取消..." && exit 1
		odify_user=$(cat "${config_user_udb_file}"|grep '"port": '"${ssr_port}"',')
		if [[ ! -z ${odify_user} ]]; then
			break
		else
			echo -e "${Error} Введите правильный порт !"
		fi
	done
}
odify_Config(){
	SSR_installation_status
	echo && echo -e "Что вы хотите сделать？
 ${Green_font_prefix}1.${Font_color_suffix}  Добавить новую конфигурацию
 ${Green_font_prefix}2.${Font_color_suffix}  Удалить конфигурацию пользователя
————— Изменить конфигурацию пользователя —————
 ${Green_font_prefix}3.${Font_color_suffix}  Изменить пароль пользователя
 ${Green_font_prefix}4.${Font_color_suffix}  Изменить метод шифорвания
 ${Green_font_prefix}5.${Font_color_suffix}  Изменить протокол
 ${Green_font_prefix}6.${Font_color_suffix}  Изменить obfs плагин
 ${Green_font_prefix}7.${Font_color_suffix}  Изменить количество устройств
 ${Green_font_prefix}8.${Font_color_suffix}  Изменить общий лимит скорости
 ${Green_font_prefix}9.${Font_color_suffix}  Изменить лимит скорости у пользователя
 ${Green_font_prefix}10.${Font_color_suffix} Изменить общий трафик
 ${Green_font_prefix}11.${Font_color_suffix} Изменить запрещенные порты
 ${Green_font_prefix}12.${Font_color_suffix} Изменить все конфигурации
————— Другое —————
 ${Green_font_prefix}13.${Font_color_suffix} Изменить IP адрес для пользователя
 
 ${Tip} Для изменения имени пользователя и его порта используйте ручную модификацию !" && echo
	read -e -p "(По умолчанию: отмена):" ssr_odify
	[[ -z "${ssr_odify}" ]] && echo "Отмена..." && exit 1
	if [[ ${ssr_odify} == "1" ]]; then
		Add_port_user
	elif [[ ${ssr_odify} == "2" ]]; then
		Del_port_user
	elif [[ ${ssr_odify} == "3" ]]; then
		odify_port
		Set_config_password
		odify_config_password
	elif [[ ${ssr_odify} == "4" ]]; then
		odify_port
		Set_config_ethod
		odify_config_ethod
	elif [[ ${ssr_odify} == "5" ]]; then
		odify_port
		Set_config_protocol
		odify_config_protocol
	elif [[ ${ssr_odify} == "6" ]]; then
		odify_port
		Set_config_obfs
		odify_config_obfs
	elif [[ ${ssr_odify} == "7" ]]; then
		odify_port
		Set_config_protocol_para
		odify_config_protocol_para
	elif [[ ${ssr_odify} == "8" ]]; then
		odify_port
		Set_config_speed_liit_per_con
		odify_config_speed_liit_per_con
	elif [[ ${ssr_odify} == "9" ]]; then
		odify_port
		Set_config_speed_liit_per_user
		odify_config_speed_liit_per_user
	elif [[ ${ssr_odify} == "10" ]]; then
		odify_port
		Set_config_transfer
		odify_config_transfer
	elif [[ ${ssr_odify} == "11" ]]; then
		odify_port
		Set_config_forbid
		odify_config_forbid
	elif [[ ${ssr_odify} == "12" ]]; then
		odify_port
		Set_config_all "odify"
		odify_config_all
	elif [[ ${ssr_odify} == "13" ]]; then
		Set_user_api_server_pub_addr "odify"
		odify_user_api_server_pub_addr
	else
		echo -e "${Error} Введите корректный номер(1-13)" && exit 1
	fi
}
List_port_user(){
	user_info=$(python ujson_gr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} Пользователь не найден !" && exit 1
	user_list_all=""
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		user_usernae=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $2}'|sed 's/\[//g;s/\]//g')
		Get_User_transfer "${user_port}"
		transfer_enable_Used_233=$(echo $((${transfer_enable_Used_233}+${transfer_enable_Used_2_1})))
		user_list_all=${user_list_all}"Пользователь: ${Green_font_prefix} "${user_usernae}"${Font_color_suffix} Порт: ${Green_font_prefix}"${user_port}"${Font_color_suffix} Трафик: ${Green_font_prefix}${transfer_enable_Used_2}${Font_color_suffix}\n"
	done
	Get_User_transfer_all
	echo && echo -e "=== Всего пользователей: ${Green_background_prefix} "${user_total}" ${Font_color_suffix}"
	echo -e ${user_list_all}
	echo -e "=== Общий трафик всех пользователей: ${Green_background_prefix} ${transfer_enable_Used_233_2} ${Font_color_suffix}\n"
}
Add_port_user(){
	lalal=$1
	if [[ "$lalal" == "install" ]]; then
		atch_add=$(python ujson_gr.py -a -u "${ssr_user}" -p "${ssr_port}" -k "${ssr_password}" - "${ssr_ethod}" -O "${ssr_protocol}" -G "${ssr_protocol_para}" -o "${ssr_obfs}" -s "${ssr_speed_liit_per_con}" -S "${ssr_speed_liit_per_user}" -t "${ssr_transfer}" -f "${ssr_forbid}"|grep -w "add user info")
	else
		while true
		do
			Set_config_all
			atch_port=$(python ujson_gr.py -l|grep -w "port ${ssr_port}$")
			[[ ! -z "${atch_port}" ]] && echo -e "${Error} Порт [${ssr_port}] уже используется, выберите другой !" && exit 1
			atch_usernae=$(python ujson_gr.py -l|grep -w "user \[${ssr_user}]")
			[[ ! -z "${atch_usernae}" ]] && echo -e "${Error} Имя пользователя [${ssr_user}] уже используется, выберите другое !" && exit 1
			atch_add=$(python ujson_gr.py -a -u "${ssr_user}" -p "${ssr_port}" -k "${ssr_password}" - "${ssr_ethod}" -O "${ssr_protocol}" -G "${ssr_protocol_para}" -o "${ssr_obfs}" -s "${ssr_speed_liit_per_con}" -S "${ssr_speed_liit_per_user}" -t "${ssr_transfer}" -f "${ssr_forbid}"|grep -w "add user info")
			if [[ -z "${atch_add}" ]]; then
				echo -e "${Error} Не удалось добавить пользователя ${Green_font_prefix}[Имя пользователя: ${ssr_user} , Порт: ${ssr_port}]${Font_color_suffix} "
				break
			else
				Add_iptables
				Save_iptables
				echo -e "${Info} Пользователь добавлен успешно ${Green_font_prefix}[Пользователь: ${ssr_user} , Порт: ${ssr_port}]${Font_color_suffix} "
				echo
				read -e -p "Хотите продолжить настройку пользователя？[Y/n]:" addyn
				[[ -z ${addyn} ]] && addyn="y"
				if [[ ${addyn} == [Nn] ]]; then
					Get_User_info "${ssr_port}"
					View_User_info
					read -e -p "Хотите настроить автоудаление пользователя?[Y/n]:" autoyn
					[[ -z ${autoyn} ]] && autoyn="y"
					if [[ ${autoyn} == [Yy] ]]; then
						apt install at
						sudo systectl enable --now atd
						port=${ssr_port}
						clear
						echo
						echo
						echo
						echo
						echo		
						read -e -p "Введите период удаления в днях:" periodofdel
						at now +$periodofdel days <<ENDARKER
python "/usr/local/shadowsocksr/ujson_gr.py" -d -p '${ssr_port}'
ENDARKER
						clear
						echo
						echo
						echo
						echo -e "Пользователь с портом ${Green_font_prefix}$ssr_port${Font_color_suffix} будет удален через $periodofdel дней."
						break
					fi					
					break
				else
					echo -e "${Info} Продолжение изменения конфигурации пользователя..."
				fi
			fi
		done
	fi
}
Del_port_user(){
	List_port_user
	while true
	do
		echo -e "Введите порт пользователя для удаления"
		read -e -p "(По умолчанию: отмена):" del_user_port
		[[ -z "${del_user_port}" ]] && echo -e "Отмена..." && exit 1
		del_user=$(cat "${config_user_udb_file}"|grep '"port": '"${del_user_port}"',')
		if [[ ! -z ${del_user} ]]; then
			port=${del_user_port}
			atch_del=$(python ujson_gr.py -d -p "${del_user_port}"|grep -w "delete user ")
			if [[ -z "${atch_del}" ]]; then
				echo -e "${Error} Удаление пользователя неуспешно ${Green_font_prefix}[Порт: ${del_user_port}]${Font_color_suffix} "
				break
			else
				Del_iptables
				Save_iptables
				echo -e "${Info} Удаление пользователя успешно ${Green_font_prefix}[Порт: ${del_user_port}]${Font_color_suffix} "
				echo
				read -e -p "Хотите продолжить удаление пользователей？[Y/n]:" delyn
				[[ -z ${delyn} ]] && delyn="y"
				if [[ ${delyn} == [Nn] ]]; then
					break
				else
					echo -e "${Info} Продолжение удаления конфигурации пользователя..."
					Del_port_user
				fi
			fi
			break
		else
			echo -e "${Error} Введите корректный порт !"
		fi
	done
}
anually_odify_Config(){
	SSR_installation_status
	nano ${config_user_udb_file}
	echo "Вы хотите перезагрузить Shadowsocks сейчас？[Y/n]" && echo
	read -e -p "(По умолчанию: y):" yn
	[[ -z ${yn} ]] && yn="y"
	if [[ ${yn} == [Yy] ]]; then
		Restart_SSR
	fi
}
Clear_transfer(){
	SSR_installation_status
	echo && echo -e "Что вы хотите делать？
 ${Green_font_prefix}1.${Font_color_suffix}  Удалить трафик, использованные одним пользователем
 ${Green_font_prefix}2.${Font_color_suffix}  Удалить трафик всех пользователей
 ${Green_font_prefix}3.${Font_color_suffix}  Запустить самоочистку трафика пользователей
 ${Green_font_prefix}4.${Font_color_suffix}  Остановить самоочистку трафика пользователей
 ${Green_font_prefix}5.${Font_color_suffix}  Модификация времени самоочистки трафика пользователей" && echo
	read -e -p "(По умолчанию: Отмена):" ssr_odify
	[[ -z "${ssr_odify}" ]] && echo "Отмена..." && exit 1
	if [[ ${ssr_odify} == "1" ]]; then
		Clear_transfer_one
	elif [[ ${ssr_odify} == "2" ]]; then
		echo "Вы действительно хотите удалить трафик всех пользователей？[y/N]" && echo
		read -e -p "(По умолчанию: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Yy] ]]; then
			Clear_transfer_all
		else
			echo "Отмена..."
		fi
	elif [[ ${ssr_odify} == "3" ]]; then
		check_crontab
		Set_crontab
		Clear_transfer_all_cron_start
	elif [[ ${ssr_odify} == "4" ]]; then
		check_crontab
		Clear_transfer_all_cron_stop
	elif [[ ${ssr_odify} == "5" ]]; then
		check_crontab
		Clear_transfer_all_cron_odify
	else
		echo -e "${Error} Введите корректный номер(1-5)" && exit 1
	fi
}
Clear_transfer_one(){
	List_port_user
	while true
	do
		echo -e "Введите порт пользователя, трафик которого нужно удалить"
		read -e -p "(По умолчанию: отмена):" Clear_transfer_user_port
		[[ -z "${Clear_transfer_user_port}" ]] && echo -e "Отмена..." && exit 1
		Clear_transfer_user=$(cat "${config_user_udb_file}"|grep '"port": '"${Clear_transfer_user_port}"',')
		if [[ ! -z ${Clear_transfer_user} ]]; then
			atch_clear=$(python ujson_gr.py -c -p "${Clear_transfer_user_port}"|grep -w "clear user ")
			if [[ -z "${atch_clear}" ]]; then
				echo -e "${Error} Не удалось удалить трафик пользователя! ${Green_font_prefix}[Порт: ${Clear_transfer_user_port}]${Font_color_suffix} "
			else
				echo -e "${Info} Трафик пользователя успешно удален! ${Green_font_prefix}[Порт: ${Clear_transfer_user_port}]${Font_color_suffix} "
			fi
			break
		else
			echo -e "${Error} Введите корректный порт !"
		fi
	done
}
Clear_transfer_all(){
	cd "${ssr_folder}"
	user_info=$(python ujson_gr.py -l)
	user_total=$(echo "${user_info}"|wc -l)
	[[ -z ${user_info} ]] && echo -e "${Error} Не найдено пользователей !" && exit 1
	for((integer = 1; integer <= ${user_total}; integer++))
	do
		user_port=$(echo "${user_info}"|sed -n "${integer}p"|awk '{print $4}')
		atch_clear=$(python ujson_gr.py -c -p "${user_port}"|grep -w "clear user ")
		if [[ -z "${atch_clear}" ]]; then
			echo -e "${Error} Не удалось удалить трафик пользователя!  ${Green_font_prefix}[Порт: ${user_port}]${Font_color_suffix} "
		else
			echo -e "${Info} Трафик пользователя успешно удален! ${Green_font_prefix}[Порт: ${user_port}]${Font_color_suffix} "
		fi
	done
	echo -e "${Info} Весь трафик пользователей успешно удален !"
}
Clear_transfer_all_cron_start(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssru.sh/d" "$file/crontab.bak"
	echo -e "\n${Crontab_tie} /bin/bash $file/ssru.sh clearall" >> "$file/crontab.bak"
	crontab "$file/crontab.bak"
	r -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssru.sh")
	if [[ -z ${cron_config} ]]; then
		echo -e "${Error} Удаление трафика пользователей регулярно не запущено !" && exit 1
	else
		echo -e "${Info} Удаление трафика пользователей регулярно запущено !"
	fi
}
Clear_transfer_all_cron_stop(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssru.sh/d" "$file/crontab.bak"
	crontab "$file/crontab.bak"
	r -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssru.sh")
	if [[ ! -z ${cron_config} ]]; then
		echo -e "${Error} Не удалось остановить самоочистку трафика пользователей !" && exit 1
	else
		echo -e "${Info} Удалось остановить самоочистку трафика пользователей !"
	fi
}
Clear_transfer_all_cron_odify(){
	Set_crontab
	Clear_transfer_all_cron_stop
	Clear_transfer_all_cron_start
}
Set_crontab(){
		echo -e "Введите временный интервал для очистки трафика
 === Описание формата ===
 * * * * * Минуты, часы, дни, месяцы, недели
 ${Green_font_prefix} 0 2 1 * * ${Font_color_suffix} Означает каждый месяц 1ого числа в 2 часа
 ${Green_font_prefix} 0 2 15 * * ${Font_color_suffix} Означает каждый месяц 15ого числа в 2 часа
 ${Green_font_prefix} 0 2 */7 * * ${Font_color_suffix} Каждые 7 дней в 2 часа
 ${Green_font_prefix} 0 2 * * 0 ${Font_color_suffix} Каждое воскресенье
 ${Green_font_prefix} 0 2 * * 3 ${Font_color_suffix} Каждую среду" && echo
	read -e -p "(По умолчанию: 0 2 1 * * Тоесть каждое 1ое число месяца в 2 часа):" Crontab_tie
	[[ -z "${Crontab_tie}" ]] && Crontab_tie="0 2 1 * *"
}
Start_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Shadowsocks запущен !" && exit 1
	/etc/init.d/ssru start
}
Stop_SSR(){
	SSR_installation_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Shadowsocks не запущен !" && exit 1
	/etc/init.d/ssru stop
}
Restart_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/ssru stop
	/etc/init.d/ssru start
}
View_Log(){
	SSR_installation_status
	[[ ! -e ${ssr_log_file} ]] && echo -e "${Error} Лог Shadowsocks не существует !" && exit 1
	echo && echo -e "${Tip} Нажмите ${Red_font_prefix}Ctrl+C${Font_color_suffix} для остановки просмотра лога" && echo -e "Если вам нужен полный лог, то напишите ${Red_font_prefix}cat ${ssr_log_file}${Font_color_suffix} 。" && echo
	tail -f ${ssr_log_file}
}
# Резкая скорость
Configure_Server_Speeder(){
	echo && echo -e "Что вы хотите сделать？
 ${Green_font_prefix}1.${Font_color_suffix} Установить Sharp Speed
 ${Green_font_prefix}2.${Font_color_suffix} Удалить Sharp Speed
————————
 ${Green_font_prefix}3.${Font_color_suffix} Запустить Sharp Speed
 ${Green_font_prefix}4.${Font_color_suffix} Остановить Sharp Speed
 ${Green_font_prefix}5.${Font_color_suffix} Перезапустить Sharp Speed
 ${Green_font_prefix}6.${Font_color_suffix} Просмотреть статус Sharp Speed
 
 Заметка: LotServer и Rui Su не могут быть установлены в одно и тоже время！" && echo
	read -e -p "(По умолчанию: отмена):" server_speeder_nu
	[[ -z "${server_speeder_nu}" ]] && echo "Отмена..." && exit 1
	if [[ ${server_speeder_nu} == "1" ]]; then
		Install_ServerSpeeder
	elif [[ ${server_speeder_nu} == "2" ]]; then
		Server_Speeder_installation_status
		Uninstall_ServerSpeeder
	elif [[ ${server_speeder_nu} == "3" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} start
		${Server_Speeder_file} status
	elif [[ ${server_speeder_nu} == "4" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} stop
	elif [[ ${server_speeder_nu} == "5" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} restart
		${Server_Speeder_file} status
	elif [[ ${server_speeder_nu} == "6" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} status
	else
		echo -e "${Error} Введите корректный номер(1-6)" && exit 1
	fi
}
Install_ServerSpeeder(){
	[[ -e ${Server_Speeder_file} ]] && echo -e "${Error} Server Speeder уже установлен !" && exit 1
	#借用91yun.rog的开心版锐速
	wget --no-check-certificate -qO /tp/serverspeeder.sh https://raw.githubusercontent.co/91yun/serverspeeder/aster/serverspeeder.sh
	[[ ! -e "/tp/serverspeeder.sh" ]] && echo -e "${Error} Загрузка скрипта Rui Su неуспешна !" && exit 1
	bash /tp/serverspeeder.sh
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "serverspeeder" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		r -rf /tp/serverspeeder.sh
		r -rf /tp/91yunserverspeeder
		r -rf /tp/91yunserverspeeder.tar.gz
		echo -e "${Info} Server Speeder успешно установлен !" && exit 1
	else
		echo -e "${Error} Не удалось установить Server Speeder !" && exit 1
	fi
}
Uninstall_ServerSpeeder(){
	echo "Вы уверены что хотите деинсталлировать Server Speeder？[y/N]" && echo
	read -e -p "(По умолчанию: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "Отмена..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		chattr -i /serverspeeder/etc/apx*
		/serverspeeder/bin/serverSpeeder.sh uninstall -f
		echo && echo "Server Speeder успешно удален !" && echo
	fi
}
# LotServer
Configure_LotServer(){
	echo && echo -e "Что вы хотите сделать？
 ${Green_font_prefix}1.${Font_color_suffix} Установить LotServer
 ${Green_font_prefix}2.${Font_color_suffix} Деинсталлировать LotServer
————————
 ${Green_font_prefix}3.${Font_color_suffix} Запустить LotServer
 ${Green_font_prefix}4.${Font_color_suffix} Остановить LotServer
 ${Green_font_prefix}5.${Font_color_suffix} Перезапустить LotServer
 ${Green_font_prefix}6.${Font_color_suffix} Проверить статус LotServer 
 
 Заметка: LotServer и Rui Su не могут быть установлены в одно и тоже время！" && echo
	read -e -p "(По умолчанию: отмена):" lotserver_nu
	[[ -z "${lotserver_nu}" ]] && echo "Отмена..." && exit 1
	if [[ ${lotserver_nu} == "1" ]]; then
		Install_LotServer
	elif [[ ${lotserver_nu} == "2" ]]; then
		LotServer_installation_status
		Uninstall_LotServer
	elif [[ ${lotserver_nu} == "3" ]]; then
		LotServer_installation_status
		${LotServer_file} start
		${LotServer_file} status
	elif [[ ${lotserver_nu} == "4" ]]; then
		LotServer_installation_status
		${LotServer_file} stop
	elif [[ ${lotserver_nu} == "5" ]]; then
		LotServer_installation_status
		${LotServer_file} restart
		${LotServer_file} status
	elif [[ ${lotserver_nu} == "6" ]]; then
		LotServer_installation_status
		${LotServer_file} status
	else
		echo -e "${Error} Введите корректный номер(1-6)" && exit 1
	fi
}
Install_LotServer(){
	[[ -e ${LotServer_file} ]] && echo -e "${Error} LotServer уже установлен !" && exit 1
	#Github: https://github.co/0oVicero0/serverSpeeder_Install
	wget --no-check-certificate -qO /tp/appex.sh "https://raw.githubusercontent.co/0oVicero0/serverSpeeder_Install/aster/appex.sh"
	[[ ! -e "/tp/appex.sh" ]] && echo -e "${Error} Загрузка скрипта LotServer провалена !" && exit 1
	bash /tp/appex.sh 'install'
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "appex" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		echo -e "${Info} LotServer успешно установлен !" && exit 1
	else
		echo -e "${Error} Не удалось установить LotServer  !" && exit 1
	fi
}
Uninstall_LotServer(){
	echo "Вы уверены что хотите удалить LotServer？[y/N]" && echo
	read -e -p "(По умолчанию: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "Отмена..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		wget --no-check-certificate -qO /tp/appex.sh "https://raw.githubusercontent.co/0oVicero0/serverSpeeder_Install/aster/appex.sh" && bash /tp/appex.sh 'uninstall'
		echo && echo "LotServer успешно деинсталлирован !" && echo
	fi
}
# BBR
Configure_BBR(){
	echo && echo -e "  Что будем делать？
	
 ${Green_font_prefix}1.${Font_color_suffix} Установить BBR
————————
 ${Green_font_prefix}2.${Font_color_suffix} Запустить BBR
 ${Green_font_prefix}3.${Font_color_suffix} Остановить BBR
 ${Green_font_prefix}4.${Font_color_suffix} Просмотреть статус BBR" && echo
echo -e "${Green_font_prefix} [ВНИМАТЕЛЬНО ПРОЧИТАЙТЕ ТЕКСТ СНИЗУ!!!] ${Font_color_suffix}
1. Для успешной установки BBR нужно заменить ядро, что может привести к поломке сервера
2. OpenVZ и Docker не поддерживают данную функцию, нужен Debian/Ubuntu!
3. Если у вас система Debian, то при выборе [ При остановке деинсталлирования ядра ] ，то выберите ${Green_font_prefix} NO ${Font_color_suffix}" && echo
	read -e -p "(По умолчанию: отмена):" bbr_nu
	[[ -z "${bbr_nu}" ]] && echo "Отмена..." && exit 1
	if [[ ${bbr_nu} == "1" ]]; then
		Install_BBR
	elif [[ ${bbr_nu} == "2" ]]; then
		Start_BBR
	elif [[ ${bbr_nu} == "3" ]]; then
		Stop_BBR
	elif [[ ${bbr_nu} == "4" ]]; then
		Status_BBR
	else
		echo -e "${Error} Выберите корректный номер(1-4)" && exit 1
	fi
}
Install_BBR(){
	[[ ${release} = "centos" ]] && echo -e "${Error} Скрипт не поддерживает установку BBR на CentOS !" && exit 1
	BBR_installation_status
	bash "${BBR_file}"
}
Start_BBR(){
	BBR_installation_status
	bash "${BBR_file}" start
}
Stop_BBR(){
	BBR_installation_status
	bash "${BBR_file}" stop
}
Status_BBR(){
	BBR_installation_status
	bash "${BBR_file}" status
}
# Прочие функции
Other_functions(){
	echo && echo -e "  Что будем делать？
	
  ${Green_font_prefix}1.${Font_color_suffix} Настроить BBR
  ${Green_font_prefix}2.${Font_color_suffix} Настроить Sharp Speed(ServerSpeeder)
  ${Green_font_prefix}3.${Font_color_suffix} Настроить LotServer(дочерняя программа Rui Speed)
  ${Tip} Rui Su/LotServer/BBR не поддерживают OpenVZ！
  ${Tip} Sharp Speed и LotServer не могут быть установлены вместе！
————————————
  ${Green_font_prefix}4.${Font_color_suffix} 一Блокировка BT/PT/SPA в один клик (iptables)
  ${Green_font_prefix}5.${Font_color_suffix} 一Разблокировка BT/PT/SPA в один клик (iptables)
————————————
  ${Green_font_prefix}6.${Font_color_suffix} Изменить тип вывода лога Shadowsocks
  —— Подсказка：SSR по умолчанию выводит только ошибочные логи. Лог можно изменить на более детализированный。
  ${Green_font_prefix}7.${Font_color_suffix} Монитор текущего статуса Shadowsocks
  —— Подсказка： Эта функция очень полезна если SSR часто выключается. Каждую минуту скрипт будеть проверять статус ShadowsocksR, и если он выключен, включать его" && echo
	read -e -p "(По умолчанию: отмена):" other_nu
	[[ -z "${other_nu}" ]] && echo "Отмена..." && exit 1
	if [[ ${other_nu} == "1" ]]; then
		Configure_BBR
	elif [[ ${other_nu} == "2" ]]; then
		Configure_Server_Speeder
	elif [[ ${other_nu} == "3" ]]; then
		Configure_LotServer
	elif [[ ${other_nu} == "4" ]]; then
		BanBTPTSPA
	elif [[ ${other_nu} == "5" ]]; then
		UnBanBTPTSPA
	elif [[ ${other_nu} == "6" ]]; then
		Set_config_connect_verbose_info
	elif [[ ${other_nu} == "7" ]]; then
		Set_crontab_onitor_ssr
	else
		echo -e "${Error} Введите корректный номер [1-7]" && exit 1
	fi
}
# Запретить BT PT SPA
BanBTPTSPA(){
	wget -N --no-check-certificate https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/ban_iptables.sh && chod +x ban_iptables.sh && bash ban_iptables.sh banall
	r -rf ban_iptables.sh
}
# Разблокировать BT PT SPA
UnBanBTPTSPA(){
	wget -N --no-check-certificate https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/ban_iptables.sh && chod +x ban_iptables.sh && bash ban_iptables.sh unbanall
	r -rf ban_iptables.sh
}
Set_config_connect_verbose_info(){
	SSR_installation_status
	[[ ! -e ${jq_file} ]] && echo -e "${Error} Отсутствует парсер JQ !" && exit 1
	connect_verbose_info=`${jq_file} '.connect_verbose_info' ${config_user_file}`
	if [[ ${connect_verbose_info} = "0" ]]; then
		echo && echo -e "Текущий режим логирования: ${Green_font_prefix}простой（только ошибки）${Font_color_suffix}" && echo
		echo -e "Вы уверены, что хотите сменить его на  ${Green_font_prefix}детализированный(Детальный лог соединений + ошибки)${Font_color_suffix}？[y/N]"
		read -e -p "(По умолчанию: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="1"
			odify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "	Отмена..." && echo
		fi
	else
		echo && echo -e "Текущий режим логирования: ${Green_font_prefix}детализированный(Детальный лог соединений + ошибки)${Font_color_suffix}" && echo
		echo -e "Вы уверены, что хотите сменить его на  ${Green_font_prefix}простой（только ошибки）${Font_color_suffix}？[y/N]"
		read -e -p "(По умолчанию: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="0"
			odify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "	Отмена..." && echo
		fi
	fi
}
Set_crontab_onitor_ssr(){
	SSR_installation_status
	crontab_onitor_ssr_status=$(crontab -l|grep "ssru.sh onitor")
	if [[ -z "${crontab_onitor_ssr_status}" ]]; then
		echo && echo -e "Текущий статус мониторинга: ${Green_font_prefix}выключен${Font_color_suffix}" && echo
		echo -e "Вы уверены что хотите включить ${Green_font_prefix}функцию мониторинга ShadowsocksR${Font_color_suffix}？(При отключении SSR, он будет запущен автоматически)[Y/n]"
		read -e -p "(По умолчанию: y):" crontab_onitor_ssr_status_ny
		[[ -z "${crontab_onitor_ssr_status_ny}" ]] && crontab_onitor_ssr_status_ny="y"
		if [[ ${crontab_onitor_ssr_status_ny} == [Yy] ]]; then
			crontab_onitor_ssr_cron_start
		else
			echo && echo "	Отмена..." && echo
		fi
	else
		echo && echo -e "Текущий статус мониторинга: ${Green_font_prefix}включен${Font_color_suffix}" && echo
		echo -e "Вы уверены что хотите выключить ${Green_font_prefix}функцию мониторинга ShadowsocksR${Font_color_suffix}？(При отключении SSR, он будет запущен автоматически)[y/N]"
		read -e -p "(По умолчанию: n):" crontab_onitor_ssr_status_ny
		[[ -z "${crontab_onitor_ssr_status_ny}" ]] && crontab_onitor_ssr_status_ny="n"
		if [[ ${crontab_onitor_ssr_status_ny} == [Yy] ]]; then
			crontab_onitor_ssr_cron_stop
		else
			echo && echo "	Отмена..." && echo
		fi
	fi
}
crontab_onitor_ssr(){
	SSR_installation_status
	check_pid
	if [[ -z ${PID} ]]; then
		echo -e "${Error} [$(date "+%Y-%-%d %H:%:%S %u %Z")] Замечено что SSR не запущен, запускаю..." | tee -a ${ssr_log_file}
		/etc/init.d/ssru start
		sleep 1s
		check_pid
		if [[ -z ${PID} ]]; then
			echo -e "${Error} [$(date "+%Y-%-%d %H:%:%S %u %Z")] ShadowsocksR не удалось запустить..." | tee -a ${ssr_log_file} && exit 1
		else
			echo -e "${Info} [$(date "+%Y-%-%d %H:%:%S %u %Z")] ShadowsocksR успешно установлен..." | tee -a ${ssr_log_file} && exit 1
		fi
	else
		echo -e "${Info} [$(date "+%Y-%-%d %H:%:%S %u %Z")] ShadowsocksR успешно работает..." exit 0
	fi
}
crontab_onitor_ssr_cron_start(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssru.sh onitor/d" "$file/crontab.bak"
	echo -e "\n* * * * * /bin/bash $file/ssru.sh onitor" >> "$file/crontab.bak"
	crontab "$file/crontab.bak"
	r -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssru.sh onitor")
	if [[ -z ${cron_config} ]]; then
		echo -e "${Error} Не удалось запустить функцию мониторинга ShadowsocksR  !" && exit 1
	else
		echo -e "${Info} Функция мониторинга ShadowsocksR успешно запущена !"
	fi
}
crontab_onitor_ssr_cron_stop(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssru.sh onitor/d" "$file/crontab.bak"
	crontab "$file/crontab.bak"
	r -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssru.sh onitor")
	if [[ ! -z ${cron_config} ]]; then
		echo -e "${Error} Не удалось остановить функцию моинторинга сервера ShadowsocksR !" && exit 1
	else
		echo -e "${Info} Функция мониторинга сервера ShadowsocksR успешно остановлена !"
	fi
}
Update_Shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/ssru.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} Не удается подключиться к Github !" && exit 0
	if [[ -e "/etc/init.d/ssru" ]]; then
		r -rf /etc/init.d/ssru
		Service_SSR
	fi
	cd "${file}"
	wget -N --no-check-certificate "https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/ssru.sh" && chod +x ssru.sh
	echo -e "Скрипт успешно обновлен до версии[ ${sh_new_ver} ] !(Так как обновление - перезапись, то далее могут выйти ошибки, просто инорируйте их)" && exit 0
}
# Отображение статуса меню
enu_status(){
	if [[ -e ${ssr_folder} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e " Текущий статус: ${Green_font_prefix}установлен${Font_color_suffix} и ${Green_font_prefix}запущен${Font_color_suffix}"
		else
			echo -e " Текущий статус: ${Green_font_prefix}установлен${Font_color_suffix} но ${Red_font_prefix}не запущен${Font_color_suffix}"
		fi
		cd "${ssr_folder}"
	else
		echo -e " Текущий статус: ${Red_font_prefix}не установлен${Font_color_suffix}"
	fi
}
Upload_DB(){
upload_link="$(curl -F "file=@/usr/local/shadowsocksr/udb.json" "https://file.io" | jq ".link")" && clear
	echo -e "${Green_font_prefix} $upload_link${Font_color_suffix} && echo -e " ${Green_font_prefix} Закрытие программы ... ${Font_color_suffix} "
}
Download_DB(){
	echo -e "${Green_font_prefix} Внимание: это приведет к перезаписи всей базы пользователей, вы готовы что хотите продолжить?${Font_color_suffix}(y/n)"
	read -e -p "(По умолчанию: отмена):" base_override
	[[ -z "${base_override}" ]] && echo "Отмена..." && exit 1
	if [[ ${base_override} == "y" ]]; then
		read -e -p "${Green_font_prefix} Введите ссылку на базу: (полученная в 15 пункте):(Если вы ее не сделали, то введите 'n')${Font_color_suffix}" base_link && echo
		[[ -z "${base_link}" ]] && echo "Отмена..." && exit 1
		if [[ ${base_link} == "n" ]]; then
   echo "Отмена..." && exit 1
else 
   cd /usr/local/shadowsocksr
   r "/usr/local/shadowsocksr/udb.json"
   curl -o "udb.json" "${base_link}"   
   echo -e "База успешно импортирована!"
fi
	elif [[ ${base_override} == "n" ]]; then
		echo "Отмена..." && exit 1
	fi
}
Fastexit(){
	exit
}
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
action=$1
if [[ "${action}" == "clearall" ]]; then
	Clear_transfer_all
elif [[ "${action}" == "onitor" ]]; then
	crontab_onitor_ssr
else
       domainofserver=$(cat ${config_user_api_file} | grep "SERVER_PUB_ADDR = " | awk -F "[']" '{print $2}')
        serverip123=$(curl ifconfig.me)
        user_info=$(python "/usr/local/shadowsocksr/mujson_mgr.py" -l)
		    user_total=$(echo "${user_info}" | wc -l)
	clear
  echo
	echo -e " Скрипт модерации сервера Shadowsocks ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
	---- VPN USER CONTROL ----"
	echo
  echo -e "Здравствуйте, администратор сервера! Дата : $(date +"%d-%-%Y")
echo -e " 
IP сервера : $serverip123
Домен сервера : $doainofserver
Всего на сервере : $user_total

———————————— Управление ключами ————————————
 ${Green_font_prefix}1.${Font_color_suffix} Создать ключ
 ${Green_font_prefix}2.${Font_color_suffix} Удалить ключ
 ${Green_font_prefix}3.${Font_color_suffix} Изменить пароль ключа
 ${Green_font_prefix}4.${Font_color_suffix} Информация о пользователях
 ${Green_font_prefix}5.${Font_color_suffix} Показать подключённые IP адреса
———————————— Управление базой ————————————
 ${Green_font_prefix}6.${Font_color_suffix} Выгрузить базу
 ${Green_font_prefix}7.${Font_color_suffix} Загрузить базу
 ${Green_font_prefix}8.${Font_color_suffix} Редактировать базу в ручную
 ${Green_font_prefix}9.${Font_color_suffix} Изменить адрес сервера
———————————— Управление скриптом ————————————
 ${Green_font_prefix}10.${Font_color_suffix} Включить Shadowsocks
 ${Green_font_prefix}11.${Font_color_suffix} Выключить Shadowsocks
 ${Green_font_prefix}12.${Font_color_suffix} Перезапустить Shadowsocks
 ${Green_font_prefix}13.${Font_color_suffix} Очистка трафика пользователей
 ${Green_font_prefix}14.${Font_color_suffix} Просмотреть лог Shadowsocks
 ${Green_font_prefix}15.${Font_color_suffix} Другие функции
———————————— Установка скрипта ————————————
${Green_font_prefix}16.${Font_color_suffix} Установить Shadowsocks
${Green_font_prefix}17.${Font_color_suffix} Удалить Shadowsocks
———————————————————————————————————————————
${Green_font_prefix}18.${Font_color_suffix} Выход
 "
 
	enu_status
	echo && read -e -p "Введите корректный номер [1-18]：" num
case "$num" in
	1)
	Add_port_user
	;;
	2)
	Del_port_user
	;;
	3)
	odify_port
	;;
	4)
	View_User
	;;
	5)
	View_user_connection_info
	;;
	6)
	Upload_DB
	;;
	7)
	Download_DB
	;;
	8)
	anually_odify_Config
	;;
	9)
	Set_user_api_server_pub_addr "odify"
	odify_user_api_server_pub_addr
	;;
	10)
	Start_SSR
	;;
	11)
	Stop_SSR
	;;
	12)
	Restart_SSR
	;;
	13)
	Clear_transfer
	;;
	14)
	View_Log
	;;
	15)
	Other_functions
	;;
	16)
	Install_SSR
	;;
	17)
	Uninstall_SSR
  ;;
  18)
	Fastexit
  ;;
	*)
	echo -e "${Error} Введите корректный номер [1-18]"
	;;
esac
fiix} 0 2 1 * * ${Font_color_suffix} Означает каждый месяц 1ого числа в 2 часа
 ${Green_font_prefix} 0 2 15 * * ${Font_color_suffix} Означает каждый месяц 15ого числа в 2 часа
 ${Green_font_prefix} 0 2 */7 * * ${Font_color_suffix} Каждые 7 дней в 2 часа
 ${Green_font_prefix} 0 2 * * 0 ${Font_color_suffix} Каждое воскресенье
 ${Green_font_prefix} 0 2 * * 3 ${Font_color_suffix} Каждую среду" && echo
	read -e -p "(По умолчанию: 0 2 1 * * Тоесть каждое 1ое число месяца в 2 часа):" Crontab_tie
	[[ -z "${Crontab_tie}" ]] && Crontab_tie="0 2 1 * *"
}
Start_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Shadowsocks запущен !" && exit 1
	/etc/init.d/ssru start
}
Stop_SSR(){
	SSR_installation_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Shadowsocks не запущен !" && exit 1
	/etc/init.d/ssru stop
}
Restart_SSR(){
	SSR_installation_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/ssru stop
	/etc/init.d/ssru start
}
View_Log(){
	SSR_installation_status
	[[ ! -e ${ssr_log_file} ]] && echo -e "${Error} Лог Shadowsocks не существует !" && exit 1
	echo && echo -e "${Tip} Нажмите ${Red_font_prefix}Ctrl+C${Font_color_suffix} для остановки просмотра лога" && echo -e "Если вам нужен полный лог, то напишите ${Red_font_prefix}cat ${ssr_log_file}${Font_color_suffix} 。" && echo
	tail -f ${ssr_log_file}
}
# Резкая скорость
Configure_Server_Speeder(){
	echo && echo -e "Что вы хотите сделать？
 ${Green_font_prefix}1.${Font_color_suffix} Установить Sharp Speed
 ${Green_font_prefix}2.${Font_color_suffix} Удалить Sharp Speed
————————
 ${Green_font_prefix}3.${Font_color_suffix} Запустить Sharp Speed
 ${Green_font_prefix}4.${Font_color_suffix} Остановить Sharp Speed
 ${Green_font_prefix}5.${Font_color_suffix} Перезапустить Sharp Speed
 ${Green_font_prefix}6.${Font_color_suffix} Просмотреть статус Sharp Speed
 
 Заметка: LotServer и Rui Su не могут быть установлены в одно и тоже время！" && echo
	read -e -p "(По умолчанию: отмена):" server_speeder_nu
	[[ -z "${server_speeder_nu}" ]] && echo "Отмена..." && exit 1
	if [[ ${server_speeder_nu} == "1" ]]; then
		Install_ServerSpeeder
	elif [[ ${server_speeder_nu} == "2" ]]; then
		Server_Speeder_installation_status
		Uninstall_ServerSpeeder
	elif [[ ${server_speeder_nu} == "3" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} start
		${Server_Speeder_file} status
	elif [[ ${server_speeder_nu} == "4" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} stop
	elif [[ ${server_speeder_nu} == "5" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} restart
		${Server_Speeder_file} status
	elif [[ ${server_speeder_nu} == "6" ]]; then
		Server_Speeder_installation_status
		${Server_Speeder_file} status
	else
		echo -e "${Error} Введите корректный номер(1-6)" && exit 1
	fi
}
Install_ServerSpeeder(){
	[[ -e ${Server_Speeder_file} ]] && echo -e "${Error} Server Speeder уже установлен !" && exit 1
	#借用91yun.rog的开心版锐速
	wget --no-check-certificate -qO /tp/serverspeeder.sh https://raw.githubusercontent.co/91yun/serverspeeder/aster/serverspeeder.sh
	[[ ! -e "/tp/serverspeeder.sh" ]] && echo -e "${Error} Загрузка скрипта Rui Su неуспешна !" && exit 1
	bash /tp/serverspeeder.sh
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "serverspeeder" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		r -rf /tp/serverspeeder.sh
		r -rf /tp/91yunserverspeeder
		r -rf /tp/91yunserverspeeder.tar.gz
		echo -e "${Info} Server Speeder успешно установлен !" && exit 1
	else
		echo -e "${Error} Не удалось установить Server Speeder !" && exit 1
	fi
}
Uninstall_ServerSpeeder(){
	echo "Вы уверены что хотите деинсталлировать Server Speeder？[y/N]" && echo
	read -e -p "(По умолчанию: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "Отмена..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		chattr -i /serverspeeder/etc/apx*
		/serverspeeder/bin/serverSpeeder.sh uninstall -f
		echo && echo "Server Speeder успешно удален !" && echo
	fi
}
# LotServer
Configure_LotServer(){
	echo && echo -e "Что вы хотите сделать？
 ${Green_font_prefix}1.${Font_color_suffix} Установить LotServer
 ${Green_font_prefix}2.${Font_color_suffix} Деинсталлировать LotServer
————————
 ${Green_font_prefix}3.${Font_color_suffix} Запустить LotServer
 ${Green_font_prefix}4.${Font_color_suffix} Остановить LotServer
 ${Green_font_prefix}5.${Font_color_suffix} Перезапустить LotServer
 ${Green_font_prefix}6.${Font_color_suffix} Проверить статус LotServer 
 
 Заметка: LotServer и Rui Su не могут быть установлены в одно и тоже время！" && echo
	read -e -p "(По умолчанию: отмена):" lotserver_nu
	[[ -z "${lotserver_nu}" ]] && echo "Отмена..." && exit 1
	if [[ ${lotserver_nu} == "1" ]]; then
		Install_LotServer
	elif [[ ${lotserver_nu} == "2" ]]; then
		LotServer_installation_status
		Uninstall_LotServer
	elif [[ ${lotserver_nu} == "3" ]]; then
		LotServer_installation_status
		${LotServer_file} start
		${LotServer_file} status
	elif [[ ${lotserver_nu} == "4" ]]; then
		LotServer_installation_status
		${LotServer_file} stop
	elif [[ ${lotserver_nu} == "5" ]]; then
		LotServer_installation_status
		${LotServer_file} restart
		${LotServer_file} status
	elif [[ ${lotserver_nu} == "6" ]]; then
		LotServer_installation_status
		${LotServer_file} status
	else
		echo -e "${Error} Введите корректный номер(1-6)" && exit 1
	fi
}
Install_LotServer(){
	[[ -e ${LotServer_file} ]] && echo -e "${Error} LotServer уже установлен !" && exit 1
	#Github: https://github.co/0oVicero0/serverSpeeder_Install
	wget --no-check-certificate -qO /tp/appex.sh "https://raw.githubusercontent.co/0oVicero0/serverSpeeder_Install/aster/appex.sh"
	[[ ! -e "/tp/appex.sh" ]] && echo -e "${Error} Загрузка скрипта LotServer провалена !" && exit 1
	bash /tp/appex.sh 'install'
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "appex" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		echo -e "${Info} LotServer успешно установлен !" && exit 1
	else
		echo -e "${Error} Не удалось установить LotServer  !" && exit 1
	fi
}
Uninstall_LotServer(){
	echo "Вы уверены что хотите удалить LotServer？[y/N]" && echo
	read -e -p "(По умолчанию: n):" unyn
	[[ -z ${unyn} ]] && echo && echo "Отмена..." && exit 1
	if [[ ${unyn} == [Yy] ]]; then
		wget --no-check-certificate -qO /tp/appex.sh "https://raw.githubusercontent.co/0oVicero0/serverSpeeder_Install/aster/appex.sh" && bash /tp/appex.sh 'uninstall'
		echo && echo "LotServer успешно деинсталлирован !" && echo
	fi
}
# BBR
Configure_BBR(){
	echo && echo -e "  Что будем делать？
	
 ${Green_font_prefix}1.${Font_color_suffix} Установить BBR
————————
 ${Green_font_prefix}2.${Font_color_suffix} Запустить BBR
 ${Green_font_prefix}3.${Font_color_suffix} Остановить BBR
 ${Green_font_prefix}4.${Font_color_suffix} Просмотреть статус BBR" && echo
echo -e "${Green_font_prefix} [ВНИМАТЕЛЬНО ПРОЧИТАЙТЕ ТЕКСТ СНИЗУ!!!] ${Font_color_suffix}
1. Для успешной установки BBR нужно заменить ядро, что может привести к поломке сервера
2. OpenVZ и Docker не поддерживают данную функцию, нужен Debian/Ubuntu!
3. Если у вас система Debian, то при выборе [ При остановке деинсталлирования ядра ] ，то выберите ${Green_font_prefix} NO ${Font_color_suffix}" && echo
	read -e -p "(По умолчанию: отмена):" bbr_nu
	[[ -z "${bbr_nu}" ]] && echo "Отмена..." && exit 1
	if [[ ${bbr_nu} == "1" ]]; then
		Install_BBR
	elif [[ ${bbr_nu} == "2" ]]; then
		Start_BBR
	elif [[ ${bbr_nu} == "3" ]]; then
		Stop_BBR
	elif [[ ${bbr_nu} == "4" ]]; then
		Status_BBR
	else
		echo -e "${Error} Выберите корректный номер(1-4)" && exit 1
	fi
}
Install_BBR(){
	[[ ${release} = "centos" ]] && echo -e "${Error} Скрипт не поддерживает установку BBR на CentOS !" && exit 1
	BBR_installation_status
	bash "${BBR_file}"
}
Start_BBR(){
	BBR_installation_status
	bash "${BBR_file}" start
}
Stop_BBR(){
	BBR_installation_status
	bash "${BBR_file}" stop
}
Status_BBR(){
	BBR_installation_status
	bash "${BBR_file}" status
}
# Прочие функции
Other_functions(){
	echo && echo -e "  Что будем делать？
	
  ${Green_font_prefix}1.${Font_color_suffix} Настроить BBR
  ${Green_font_prefix}2.${Font_color_suffix} Настроить Sharp Speed(ServerSpeeder)
  ${Green_font_prefix}3.${Font_color_suffix} Настроить LotServer(дочерняя программа Rui Speed)
  ${Tip} Rui Su/LotServer/BBR не поддерживают OpenVZ！
  ${Tip} Sharp Speed и LotServer не могут быть установлены вместе！
————————————
  ${Green_font_prefix}4.${Font_color_suffix} 一Блокировка BT/PT/SPA в один клик (iptables)
  ${Green_font_prefix}5.${Font_color_suffix} 一Разблокировка BT/PT/SPA в один клик (iptables)
————————————
  ${Green_font_prefix}6.${Font_color_suffix} Изменить тип вывода лога Shadowsocks
  —— Подсказка：SSR по умолчанию выводит только ошибочные логи. Лог можно изменить на более детализированный。
  ${Green_font_prefix}7.${Font_color_suffix} Монитор текущего статуса Shadowsocks
  —— Подсказка： Эта функция очень полезна если SSR часто выключается. Каждую минуту скрипт будеть проверять статус ShadowsocksR, и если он выключен, включать его" && echo
	read -e -p "(По умолчанию: отмена):" other_nu
	[[ -z "${other_nu}" ]] && echo "Отмена..." && exit 1
	if [[ ${other_nu} == "1" ]]; then
		Configure_BBR
	elif [[ ${other_nu} == "2" ]]; then
		Configure_Server_Speeder
	elif [[ ${other_nu} == "3" ]]; then
		Configure_LotServer
	elif [[ ${other_nu} == "4" ]]; then
		BanBTPTSPA
	elif [[ ${other_nu} == "5" ]]; then
		UnBanBTPTSPA
	elif [[ ${other_nu} == "6" ]]; then
		Set_config_connect_verbose_info
	elif [[ ${other_nu} == "7" ]]; then
		Set_crontab_onitor_ssr
	else
		echo -e "${Error} Введите корректный номер [1-7]" && exit 1
	fi
}
# Запретить BT PT SPA
BanBTPTSPA(){
	wget -N --no-check-certificate https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/ban_iptables.sh && chod +x ban_iptables.sh && bash ban_iptables.sh banall
	r -rf ban_iptables.sh
}
# Разблокировать BT PT SPA
UnBanBTPTSPA(){
	wget -N --no-check-certificate https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/ban_iptables.sh && chod +x ban_iptables.sh && bash ban_iptables.sh unbanall
	r -rf ban_iptables.sh
}
Set_config_connect_verbose_info(){
	SSR_installation_status
	[[ ! -e ${jq_file} ]] && echo -e "${Error} Отсутствует парсер JQ !" && exit 1
	connect_verbose_info=`${jq_file} '.connect_verbose_info' ${config_user_file}`
	if [[ ${connect_verbose_info} = "0" ]]; then
		echo && echo -e "Текущий режим логирования: ${Green_font_prefix}простой（только ошибки）${Font_color_suffix}" && echo
		echo -e "Вы уверены, что хотите сменить его на  ${Green_font_prefix}детализированный(Детальный лог соединений + ошибки)${Font_color_suffix}？[y/N]"
		read -e -p "(По умолчанию: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="1"
			odify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "	Отмена..." && echo
		fi
	else
		echo && echo -e "Текущий режим логирования: ${Green_font_prefix}детализированный(Детальный лог соединений + ошибки)${Font_color_suffix}" && echo
		echo -e "Вы уверены, что хотите сменить его на  ${Green_font_prefix}простой（только ошибки）${Font_color_suffix}？[y/N]"
		read -e -p "(По умолчанию: n):" connect_verbose_info_ny
		[[ -z "${connect_verbose_info_ny}" ]] && connect_verbose_info_ny="n"
		if [[ ${connect_verbose_info_ny} == [Yy] ]]; then
			ssr_connect_verbose_info="0"
			odify_config_connect_verbose_info
			Restart_SSR
		else
			echo && echo "	Отмена..." && echo
		fi
	fi
}
Set_crontab_onitor_ssr(){
	SSR_installation_status
	crontab_onitor_ssr_status=$(crontab -l|grep "ssru.sh onitor")
	if [[ -z "${crontab_onitor_ssr_status}" ]]; then
		echo && echo -e "Текущий статус мониторинга: ${Green_font_prefix}выключен${Font_color_suffix}" && echo
		echo -e "Вы уверены что хотите включить ${Green_font_prefix}функцию мониторинга ShadowsocksR${Font_color_suffix}？(При отключении SSR, он будет запущен автоматически)[Y/n]"
		read -e -p "(По умолчанию: y):" crontab_onitor_ssr_status_ny
		[[ -z "${crontab_onitor_ssr_status_ny}" ]] && crontab_onitor_ssr_status_ny="y"
		if [[ ${crontab_onitor_ssr_status_ny} == [Yy] ]]; then
			crontab_onitor_ssr_cron_start
		else
			echo && echo "	Отмена..." && echo
		fi
	else
		echo && echo -e "Текущий статус мониторинга: ${Green_font_prefix}включен${Font_color_suffix}" && echo
		echo -e "Вы уверены что хотите выключить ${Green_font_prefix}функцию мониторинга ShadowsocksR${Font_color_suffix}？(При отключении SSR, он будет запущен автоматически)[y/N]"
		read -e -p "(По умолчанию: n):" crontab_onitor_ssr_status_ny
		[[ -z "${crontab_onitor_ssr_status_ny}" ]] && crontab_onitor_ssr_status_ny="n"
		if [[ ${crontab_onitor_ssr_status_ny} == [Yy] ]]; then
			crontab_onitor_ssr_cron_stop
		else
			echo && echo "	Отмена..." && echo
		fi
	fi
}
crontab_onitor_ssr(){
	SSR_installation_status
	check_pid
	if [[ -z ${PID} ]]; then
		echo -e "${Error} [$(date "+%Y-%-%d %H:%:%S %u %Z")] Замечено что SSR не запущен, запускаю..." | tee -a ${ssr_log_file}
		/etc/init.d/ssru start
		sleep 1s
		check_pid
		if [[ -z ${PID} ]]; then
			echo -e "${Error} [$(date "+%Y-%-%d %H:%:%S %u %Z")] ShadowsocksR не удалось запустить..." | tee -a ${ssr_log_file} && exit 1
		else
			echo -e "${Info} [$(date "+%Y-%-%d %H:%:%S %u %Z")] ShadowsocksR успешно установлен..." | tee -a ${ssr_log_file} && exit 1
		fi
	else
		echo -e "${Info} [$(date "+%Y-%-%d %H:%:%S %u %Z")] ShadowsocksR успешно работает..." exit 0
	fi
}
crontab_onitor_ssr_cron_start(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssru.sh onitor/d" "$file/crontab.bak"
	echo -e "\n* * * * * /bin/bash $file/ssru.sh onitor" >> "$file/crontab.bak"
	crontab "$file/crontab.bak"
	r -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssru.sh onitor")
	if [[ -z ${cron_config} ]]; then
		echo -e "${Error} Не удалось запустить функцию мониторинга ShadowsocksR  !" && exit 1
	else
		echo -e "${Info} Функция мониторинга ShadowsocksR успешно запущена !"
	fi
}
crontab_onitor_ssr_cron_stop(){
	crontab -l > "$file/crontab.bak"
	sed -i "/ssru.sh onitor/d" "$file/crontab.bak"
	crontab "$file/crontab.bak"
	r -r "$file/crontab.bak"
	cron_config=$(crontab -l | grep "ssru.sh onitor")
	if [[ ! -z ${cron_config} ]]; then
		echo -e "${Error} Не удалось остановить функцию моинторинга сервера ShadowsocksR !" && exit 1
	else
		echo -e "${Info} Функция мониторинга сервера ShadowsocksR успешно остановлена !"
	fi
}
Update_Shell(){
	sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/ssru.sh"|grep 'sh_ver="'|awk -F "=" '{print $NF}'|sed 's/\"//g'|head -1) && sh_new_type="github"
	[[ -z ${sh_new_ver} ]] && echo -e "${Error} Не удается подключиться к Github !" && exit 0
	if [[ -e "/etc/init.d/ssru" ]]; then
		r -rf /etc/init.d/ssru
		Service_SSR
	fi
	cd "${file}"
	wget -N --no-check-certificate "https://raw.githubusercontent.co/ToyoDAdoubiBackup/doubi/aster/ssru.sh" && chod +x ssru.sh
	echo -e "Скрипт успешно обновлен до версии[ ${sh_new_ver} ] !(Так как обновление - перезапись, то далее могут выйти ошибки, просто инорируйте их)" && exit 0
}
# Отображение статуса меню
enu_status(){
	if [[ -e ${ssr_folder} ]]; then
		check_pid
		if [[ ! -z "${PID}" ]]; then
			echo -e " Текущий статус: ${Green_font_prefix}установлен${Font_color_suffix} и ${Green_font_prefix}запущен${Font_color_suffix}"
		else
			echo -e " Текущий статус: ${Green_font_prefix}установлен${Font_color_suffix} но ${Red_font_prefix}не запущен${Font_color_suffix}"
		fi
		cd "${ssr_folder}"
	else
		echo -e " Текущий статус: ${Red_font_prefix}не установлен${Font_color_suffix}"
	fi
}
Upload_DB(){
upload_link="$(curl -F "file=@/usr/local/shadowsocksr/udb.json" "https://file.io" | jq ".link")" && clear
	echo -e "${Green_font_prefix} $upload_link${Font_color_suffix} && echo -e " ${Green_font_prefix} Закрытие программы ... ${Font_color_suffix} "
}
Download_DB(){
	echo -e "${Green_font_prefix} Внимание: это приведет к перезаписи всей базы пользователей, вы готовы что хотите продолжить?${Font_color_suffix}(y/n)"
	read -e -p "(По умолчанию: отмена):" base_override
	[[ -z "${base_override}" ]] && echo "Отмена..." && exit 1
	if [[ ${base_override} == "y" ]]; then
		read -e -p "${Green_font_prefix} Введите ссылку на базу: (полученная в 15 пункте):(Если вы ее не сделали, то введите 'n')${Font_color_suffix}" base_link && echo
		[[ -z "${base_link}" ]] && echo "Отмена..." && exit 1
		if [[ ${base_link} == "n" ]]; then
   echo "Отмена..." && exit 1
else 
   cd /usr/local/shadowsocksr
   r "/usr/local/shadowsocksr/udb.json"
   curl -o "udb.json" "${base_link}"   
   echo -e "База успешно импортирована!"
fi
	elif [[ ${base_override} == "n" ]]; then
		echo "Отмена..." && exit 1
	fi
}
Fastexit(){
	exit
}
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
action=$1
if [[ "${action}" == "clearall" ]]; then
	Clear_transfer_all
elif [[ "${action}" == "onitor" ]]; then
	crontab_onitor_ssr
else
       domainofserver=$(cat ${config_user_api_file} | grep "SERVER_PUB_ADDR = " | awk -F "[']" '{print $2}')
        serverip123=$(curl ifconfig.me)
        user_info=$(python "/usr/local/shadowsocksr/mujson_mgr.py" -l)
		    user_total=$(echo "${user_info}" | wc -l)
	clear
  echo
	echo -e " Скрипт модерации сервера Shadowsocks ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
	---- VPN USER CONTROL ----"
	echo
  echo -e "Здравствуйте, администратор сервера! Дата : $(date +"%d-%-%Y")
echo -e " 
IP сервера : $serverip123
Домен сервера : $doainofserver
Всего на сервере : $user_total

———————————— Управление ключами ————————————
 ${Green_font_prefix}1.${Font_color_suffix} Создать ключ
 ${Green_font_prefix}2.${Font_color_suffix} Удалить ключ
 ${Green_font_prefix}3.${Font_color_suffix} Изменить пароль ключа
 ${Green_font_prefix}4.${Font_color_suffix} Информация о пользователях
 ${Green_font_prefix}5.${Font_color_suffix} Показать подключённые IP адреса
———————————— Управление базой ————————————
 ${Green_font_prefix}6.${Font_color_suffix} Выгрузить базу
 ${Green_font_prefix}7.${Font_color_suffix} Загрузить базу
 ${Green_font_prefix}8.${Font_color_suffix} Редактировать базу в ручную
 ${Green_font_prefix}9.${Font_color_suffix} Изменить адрес сервера
———————————— Управление скриптом ————————————
 ${Green_font_prefix}10.${Font_color_suffix} Включить Shadowsocks
 ${Green_font_prefix}11.${Font_color_suffix} Выключить Shadowsocks
 ${Green_font_prefix}12.${Font_color_suffix} Перезапустить Shadowsocks
 ${Green_font_prefix}13.${Font_color_suffix} Очистка трафика пользователей
 ${Green_font_prefix}14.${Font_color_suffix} Просмотреть лог Shadowsocks
 ${Green_font_prefix}15.${Font_color_suffix} Другие функции
———————————— Установка скрипта ————————————
${Green_font_prefix}16.${Font_color_suffix} Установить Shadowsocks
${Green_font_prefix}17.${Font_color_suffix} Удалить Shadowsocks
———————————————————————————————————————————
${Green_font_prefix}18.${Font_color_suffix} Выход
 "
 
	enu_status
	echo && read -e -p "Введите корректный номер [1-18]：" num
case "$num" in
	1)
	Add_port_user
	;;
	2)
	Del_port_user
	;;
	3)
	odify_port
	;;
	4)
	View_User
	;;
	5)
	View_user_connection_info
	;;
	6)
	Upload_DB
	;;
	7)
	Download_DB
	;;
	8)
	anually_odify_Config
	;;
	9)
	Set_user_api_server_pub_addr "odify"
	odify_user_api_server_pub_addr
	;;
	10)
	Start_SSR
	;;
	11)
	Stop_SSR
	;;
	12)
	Restart_SSR
	;;
	13)
	Clear_transfer
	;;
	14)
	View_Log
	;;
	15)
	Other_functions
	;;
	16)
	Install_SSR
	;;
	17)
	Uninstall_SSR
  ;;
  18)
	Fastexit
  ;;
	*)
	echo -e "${Error} Введите корректный номер [1-18]"
	;;
esac
fi
