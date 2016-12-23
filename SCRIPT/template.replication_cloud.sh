#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2013, Clément Mutz <c.mutz@whoople.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@whoople.fr 

#================== Globals ==================================================
#PATCH_SSH="/usr/bin/ssh"
#PATCH_SCP="/usr/bin/scp"
#PATCH_MKDIR="/bin/mkdir"
#PATCH_TMP="/tmp/"
PATH_RSYNC="/usr/bin/rsync"
#PATCH_TAR="/bin/tar"
#PATCH_XIVO_BACKUP="/usr/sbin/xivo-backup"
PATH_FOLDER_BACKUP="/var/backups/xivo/"
#PATCH_DATA="${PATCH_TMP}data_xivo"
PORT_SSH="22" # by default
USER="root" # we use user root by default 
#NAME_BACKUP="ha-xivo"
IP_XIVO_SLAVE="IP-ADDRESS-VALIDE"

#================ Verify pre-requisites ========================
#[ ! -d ${PATCH_DATA} ] && ${PATCH_MKDIR} -p ${PATCH_DATA}

#================ Main =========================================
$PATH_RSYNC -av --rsh="ssh -p${PORT_SSH}" ${PATH_FOLDER_BACKUP} ${USER}@$IP_XIVO_SLAVE:${PATH_FOLDER_BACKUP}
#$PATCH_XIVO_BACKUP db ${PATCH_FOLDER_BACKUP}db-${NAME_BACKUP}
#$PATCH_XIVO_BACKUP data ${PATCH_FOLDER_BACKUP}data-${NAME_BACKUP}

#$PATCH_TAR xvf ${PATCH_FOLDER_BACKUP}db-${NAME_BACKUP}.tgz -C ${PATCH_TMP}

#$PATCH_TAR zxvfp ${PATCH_FOLDER_BACKUP}data-${NAME_BACKUP}.tgz -C ${PATCH_DATA}

#${PATCH_SCP} -P ${PORT_SSH} ${PATCH_FOLDER_BACKUP}db-${NAME_BACKUP}.tgz ${USER}@$IP_XIVO_SLAVE:${PATCH_FOLDER_BACKUP}
#${PATCH_SCP} -P ${PORT_SSH} ${PATCH_FOLDER_BACKUP}data-${NAME_BACKUP}.tgz ${USER}@$IP_XIVO_SLAVE:${PATCH_FOLDER_BACKUP}


#$PATCH_RSYNC -e "ssh -p${PORT_SSH}" -avz --delete-after ${PATCH_TMP}pg-backup $USER@$IP_XIVO_SLAVE:${PATCH_TMP}/
#$PATCH_RSYNC -e "ssh -p${PORT_SSH}" -avz --exclude 'data_xivo/etc/network/interfaces' --exclude 'data_xivo/etc/resolv.conf' --exclude 'data_xivo/etc/hosts' --exclude 'data_xivo/etc/hostname'  --delete-after ${PATCH_DATA} $USER@$IP_XIVO_SLAVE:${PATCH_TMP}/


#================== Unset globals =============================================
unset PATCH_SSH
unset PATCH_SCP
unset PATCH_MKDIR
unset PATCH_TMP
unset PATCH_XIVO_BACKUP
unset PATCH_FOLDER_BACKUP
unset PORT_SSH
unset USER 
unset NAME_BACKUP
unset IP_XIVO_SLAVE
