#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2013, Clément Mutz <c.mutz@whoople.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@whoople.fr 

#================== Globals ==================================================
IP_MASTER=IP
IP_SLAVE=IP

ping_count="3"
ping_interval="5"

###########
# test 30 fois l'ip par interval de 5 secondes (2min30s)
ping_count_fail="30"
ping_interval_fail="5"

#================== Main ==================================================

if [ -z "$IP_MASTER" ]; then
    echo "usage: $(basename $0) IP_MASTER"
    exit 1
fi

ping -c $ping_count -i $ping_interval $IP_MASTER
if [ ! $? -eq 0 ]; then
    ping -c $ping_count_fail -i $ping_interval_fail $IP_MASTER
	if [ ! $? -eq 0 ]; then 
		ping -c $ping_count -i $ping_interval $IP_SLAVE
		if [ ! $? -eq 0 ]; then 
			xivo-service start
			echo "Le xivo cloud a effectue un xivo-service start le `date +%Y-%m-%d-%H:%M:%S`, les ip ${IP_MASTER} ET ${IP_SLAVE} sont peut etre down ?" | mail test infrastructure@whoople.fr
		fi
	fi
else
    xivo-service stop
fi

#================== Unset globals =============================================
unset IP_MASTER 
unset IP_SLAVE
unset ping_count
unset ping_interval
