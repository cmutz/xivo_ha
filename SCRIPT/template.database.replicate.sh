#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2013, Clément Mutz <c.mutz@whoople.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@whoople.fr 

#================== Globals ==================================================
PATCH_TAR="/bin/tar"
PATCH_TMP="/tmp/"
PATCH_DATA="${PATCH_TMP}data_xivo"
PATCH_FOLDER_BACKUP="/var/backups/xivo/"
NAME_BACKUP="ha-xivo"

xivo-service stop;


#================== Sauvegarde network,host ... =============================================
cp /etc/network/interfaces /etc/network/interfaces.script.ha
cp /etc/hosts /etc/hosts.script.ha
cp /etc/hostname /etc/hostname.script.ha

$PATCH_TAR -zxvf ${PATCH_FOLDER_BACKUP}data-${NAME_BACKUP}.tgz -C /


$PATCH_TAR xvf ${PATCH_FOLDER_BACKUP}db-${NAME_BACKUP}.tgz -C ${PATCH_TMP}
cd ${PATCH_TMP}pg-backup
sudo -u postgres dropdb asterisk
sudo -u postgres pg_restore -C -d postgres asterisk-*.dump
sudo -u postgres dropdb xivo
sudo -u postgres pg_restore -C -d postgres xivo-*.dump

#================== clean directory ===========================================

cp /etc/network/interfaces.script.ha /etc/netxwork/interfaces
cp /etc/hosts.script.ha /etc/hosts
cp /etc/hostname.script.ha /etc/hostname

#================== Unset globals =============================================
unset PATCH_TAR
unset PATCH_TMP
unset PATCH_DATA
unset PATCH_FOLDER_BACKUP

