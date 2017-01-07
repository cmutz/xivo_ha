#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2016, Clément Mutz <c.mutz@whoople.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@whoople.fr 

#================== Globals ==================================================
PATH_TAR="/bin/tar"
PATH_TMP="/tmp/"
PATH_DATA="${PATH_TMP}data_xivo"
PATH_FOLDER_BACKUP="/var/backups/xivo/"
NAME_BACKUP="ha-xivo"

xivo-service stop;


#================== Sauvegarde network,host ... =============================================
cp /etc/network/interfaces /etc/network/interfaces.script.ha
cp /etc/hosts /etc/hosts.script.ha
cp /etc/hostname /etc/hostname.script.ha

$PATH_TAR -zxvf ${PATH_FOLDER_BACKUP}data.tgz -C /

$PATH_TAR xvf ${PATH_FOLDER_BACKUP}db.tgz -C ${PATH_TMP}
cd ${PATH_TMP}pg-backup
sudo -u postgres dropdb asterisk
sudo -u postgres pg_restore -C -d postgres asterisk-*.dump


#================== finalising backup =========================================

xivo-update-keys

source /etc/profile.d/xivo_uuid.sh
systemctl set-environment XIVO_UUID=$XIVO_UUID
systemctl daemon-reload


#================== clean directory ===========================================

cp /etc/network/interfaces.script.ha /etc/network/interfaces
cp /etc/hosts.script.ha /etc/hosts
cp /etc/hostname.script.ha /etc/hostname
#rm -rf /tmp/pg-backup

#================== Unset globals =============================================
unset PATH_TAR
unset PATH_TMP
unset PATH_DATA
unset PATH_FOLDER_BACKUP
