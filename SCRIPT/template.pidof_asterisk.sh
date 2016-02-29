#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2013, Clément Mutz <c.mutz@whoople.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@whoople.fr 

#================== Globals ==================================================
IP_MASTER=IP



#================== Main ==================================================

if [ -z "$IP_MASTER" ]; then
    echo "usage: $(basename $0) IP_MASTER"
    exit 1
fi

ping -c $ping_count -i $ping_interval $IP_MASTER
ssh root@${IP_MASTER} "pidof asterisk"
if [ ! $? -eq 0 ]; then
	echo -e "\t\n le procesus Asterisk n'a pas l'air de réagir. Retry dans 30s ....\n"
	sleep 15
	echo -e "\t Retry dans 15s\n"
	sleep 15
	ssh root@${IP_MASTER} "pidof asterisk"
	if [ ! $? -eq 0 ]; then 
		echo -e "\t\n le procesus Asterisk n'a pas l'air de réagir. Retry dans 30s ....\n"
  		sleep 15
        	echo -e "\t Retry dans 15s\n"
        	sleep 15
		ssh root@${IP_MASTER} "pidof asterisk"
		if [ ! $? -eq 0 ]; then 
			xivo-service start
			mutt -s "Le xivo cloud a effectue un xivo-service start le `date +%Y-%m-%d-%H:%M:%S`, car le processus est peut etre down ?" infrastructure@whoople.fr
		fi
	fi
else
    xivo-service stop
fi

#================== Unset globals =============================================
unset IP_MASTER 
