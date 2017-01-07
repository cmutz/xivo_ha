#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2013, Clément Mutz <c.mutz@whoople.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@whoople.fr 

#================== Globals ==============
source global.sh

IP_XIVO_SLAVE="IP-ADDRESS-VALIDE"

#================ Main =========================================
${PATH_XIVO_BACKUP} db ${PATH_FOLDER_BACKUP}db
${PATH_XIVO_BACKUP} data ${PATH_FOLDER_BACKUP}data
$PATH_RSYNC -av --rsh="ssh -p${PORT_SSH}" ${PATH_FOLDER_BACKUP} ${USER}@$IP_XIVO_SLAVE:${PATH_FOLDER_BACKUP}
