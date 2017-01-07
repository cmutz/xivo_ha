#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2013, Clément Mutz <c.mutz@whoople.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@whoople.fr 

#================== Globals ==================================================
PATH_RSYNC="/usr/bin/rsync"
PATCH_XIVO_BACKUP="/usr/sbin/xivo-backup"
PATH_FOLDER_BACKUP="/var/backups/xivo/"
PORT_SSH="22" # by default
USER="root" # we use user root by default 

IP_XIVO_SLAVE="IP-ADDRESS-VALIDE"

#================ Main =========================================
$PATH_XIVO_BACKUP db ${PATCH_FOLDER_BACKUP}db
$PATH_XIVO_BACKUP data ${PATCH_FOLDER_BACKUP}data
$PATH_RSYNC -av --rsh="ssh -p${PORT_SSH}" ${PATH_FOLDER_BACKUP} ${USER}@$IP_XIVO_SLAVE:${PATH_FOLDER_BACKUP}

#================== Unset globals =============================================
unset PATH_RSYNC
unset PATCH_XIVO_BACKUP
unset PATCH_FOLDER_BACKUP
unset PORT_SSH
unset NAME_BACKUP
unset IP_XIVO_SLAVE
