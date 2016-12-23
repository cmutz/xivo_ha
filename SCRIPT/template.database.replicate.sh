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

#$PATCH_TAR -zcvf ${PATCH_FOLDER_BACKUP}data-ha.tgz etc/ usr/ var/
#cp ${PATCH_FOLDER_BACKUP}data-`date '+%d%m%Y'`.tgz 
$PATH_TAR -zxvf ${PATH_FOLDER_BACKUP}data.tgz -C /


$PATH_TAR xvf ${PATH_FOLDER_BACKUP}db.tgz -C ${PATH_TMP}
cd ${PATH_TMP}pg-backup
sudo -u postgres dropdb asterisk
sudo -u postgres pg_restore -C -d postgres asterisk-*.dump



######################################
### Plus valabe depuis la 15.19
#sudo -u postgres dropdb xivo
#sudo -u postgres pg_restore -C -d postgres xivo-*.dump
#sudo -u postgres pg_restore -d xivo -t entity -t entity_id_seq -c xivo-*.dump
#sudo -u postgres pg_restore -d xivo -t ldapserver -t ldapserver_id_seq -c xivo-*.dump
#sudo -u postgres pg_restore -d xivo -t stats_conf -t stats_conf_id_seq -c xivo-*.dump
#sudo -u postgres pg_restore -d xivo -t stats_conf_agent -c xivo-*.dump
#sudo -u postgres pg_restore -d xivo -t stats_conf_group -c xivo-*.dump
#sudo -u postgres pg_restore -d xivo -t stats_conf_incall -c xivo-*.dump
#sudo -u postgres pg_restore -d xivo -t stats_conf_queue -c xivo-*.dump
#sudo -u postgres pg_restore -d xivo -t stats_conf_user -c xivo-*.dump
#su postgres -c 'psql xivo -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO xivo"'
#su postgres -c 'psql xivo -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO xivo"'

#$PATCH_TAR cvf ${PATCH_FOLDER_BACKUP}db-ha.tgz *
######################################

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
