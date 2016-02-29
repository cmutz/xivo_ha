#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2013, Clément Mutz <c.mutz@servitics.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@servitics.fr 

#================== Globals ==================================================
PATCH_BASH="/bin/bash"
PATCH_CP="/bin/cp"
PATCH_LIBRARY="LIBRARY"
PATCH_PING="/bin/ping"
PATCH_MKDIR="/bin/mkdir"
IP_XIVO_SLAVE=""
ETAT_PING="KO"
USER="root" # we use user root by default 
PATCH_TMP="/tmp/"
PATCH_SSH="/usr/bin/ssh"
NAME_SCRIPT="scan-password-test.sh"
ETAT_SSH="KO"
PATCH_KEYGEN="/usr/bin/ssh-keygen"
PATCH_SSH_COPY_ID="/usr/bin/ssh-copy-id"
PATCH_SCP="/usr/bin/scp"
PORT_SSH="22" # by default
PATCH_FOLDER_BACKUP="/var/backups/xivo/"
NAME_BACKUP="ha-xivo"
PATCH_SCRIPT="SCRIPT/"
PATCH_EXPECT="/usr/bin/expect"


#================== Functions ================================================
. $PATCH_LIBRARY/functions.sh

#================ you must execute root user =================================
[ `whoami`  != "root" ] && println error "This script need to be launched as root." && exit 1

#===============================================================
#================ Verify pre-requisites ========================
#===============================================================

println info " \n\tVérification des pré requis necessaire au bon fonctionnement du script\n"

check_soft $PATCH_BASH
check_soft $PATCH_CP
check_soft $PATCH_PING
check_soft $PATCH_MKDIR
check_soft $PATCH_SSH
check_soft $PATCH_KEYGEN
check_soft $PATCH_SSH_COPY_ID
check_soft $PATCH_SCP
check_soft $PATCH_EXPECT

if [[ $check_soft = "KO" ]] ;then
        println error "\n\t-------> L'une des dépendences n'est pas respecté : Solutions pour y remédier : <-------"
        println error "\n\t-------> 1°/ Apt-get install du paquets en question <-------\n"
        println error "\n\t-------> 2°/ Modifier le(s) patch(s) du(es) paquet(s) dans le fichier install_ha.sh <-------\n"
         exit 1
fi

println info " \n\tVous êtes sur le point d'installer la procedure de replication des fichiers essentielles"
println info " \n\tXIVO sur un serveur esclave"
println info "\n\tPour commencer, nous allons commencer par établir une connection automatique avec le serveur distant"
println info "\n\t Veuillez renseigner l'IP PUBLIC du serveur CLOUD : "; read IP_XIVO_SLAVE
println info "\n\t Veuillez renseigner l'ip PUBLIC du serveur MASTER : "; read IP_MASTER
println info "\n\t Veuillez renseigner l'ip PUBLIC du serveur SLAVE : "; read IP_SLAVE

! isIPv4 $IP_XIVO_SLAVE && println error "\n\t-------> ADDRESS KO <-------" && exit 1 || println warn "\n\t-------> ADDRESS OK <-------"  

! verification_access_ping $IP_XIVO_SLAVE && println error "\n\t-------> PING KO <-------" && exit 1 || println warn "\n\t-------> PING OK <-------"
sleep 0.5

verification_connexion_ssh $USER $IP_XIVO_SLAVE
if [ $ETAT_SSH = "OK" ]; then 
    println ras "\n\t-------> Auto connection ssh OK <-------" 
else
    println error "\n\t-------> Auto connection ssh KO <-------\n\tBesoin d'utiliser paire de clé ssh"
	if ask_yn_question "\n\tVoulez-vous creer ou utiliser une paire de clé ssh avec l'application ssh-keygen ?"; then generate_pair_authentication_keys $USER $IP_XIVO_SLAVE
	else println error "\t\n It's not the end of the world but you must generate pair of authentication keys to finish installation"
	fi
fi
sleep 0.5
#===============================================================
#================ Installation =================================
#===============================================================
println info " \n\tLa connection ssh des serveurs est assuré"
println info " \n\tL'installation de la réplication va démarrer"

[ ! -d /opt/backup-ha-xivo/ ] && ${PATCH_MKDIR} -p /opt/backup-ha-xivo/

${PATCH_CP} -v ${PATCH_SCRIPT}template.replication_cloud.sh /opt/backup-ha-xivo/replication_cloud.sh
sed -iv s/'^IP_XIVO_SLAVE="IP-ADDRESS-VALIDE"'/'IP_XIVO_SLAVE='"$IP_XIVO_SLAVE"''/ /opt/backup-ha-xivo/replication_cloud.sh
sleep 0.5

${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE ${PATCH_MKDIR} -p /opt/backup-ha-xivo/
sleep 0.5

${PATCH_SCP} ${PATCH_SCRIPT}template.check_xivo.sh ${USER}@$IP_XIVO_SLAVE:/opt/backup-ha-xivo/check_xivo.sh
${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE sed -iv s/'^IP_MASTER=IP'/'IP_MASTER='$IP_MASTER''/ /opt/backup-ha-xivo/check_xivo.sh
${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE sed -iv s/'^IP_SLAVE=IP'/'IP_SLAVE='$IP_SLAVE''/ /opt/backup-ha-xivo/check_xivo.sh
sleep 0.5

${PATCH_SCP} ${PATCH_SCRIPT}template.database.replicate.sh ${USER}@$IP_XIVO_SLAVE:/opt/backup-ha-xivo/database.replicate.sh
sleep 0.5

${PATCH_SCP} ${PATCH_SCRIPT}template.pidof_asterisk.sh ${USER}@$IP_XIVO_SLAVE:/opt/backup-ha-xivo/pidof_asterisk.sh
sleep 0.5

grep 'bash /opt/backup-ha-xivo/replication_cloud.sh' /etc/crontab
if [[ $? == 1 ]];then echo '30 6 * * * root bash /opt/backup-ha-xivo/replication_cloud.sh' >> /etc/crontab; fi
sleep 0.5

${PATCH_SSH} ${USER}@${IP_XIVO_SLAVE} "grep 'bash /opt/backup-ha-xivo/check_xivo.sh' /etc/crontab"
if [[ $? == 1 ]];then ${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE "echo '*/5 * * * * root bash /opt/backup-ha-xivo/check_xivo.sh' >> /etc/crontab"; fi
sleep 0.5

${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE "grep 'bash /opt/backup-ha-xivo/database.replicate.sh' /etc/crontab" 
if [[ $? == 1 ]];then ${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE "echo '0 7 * * * root bash /opt/backup-ha-xivo/database.replicate.sh' >> /etc/crontab"; fi
sleep 0.5

#${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE "grep 'bash /opt/backup-ha-xivo/pidof_asterisk.sh' /etc/crontab" 
#if [[ $? == 1 ]];then ${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE "echo '#*/3 * * * * root bash /opt/backup-ha-xivo/pidof_asterisk.sh' >> /etc/crontab"; fi
#${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE sed -iv s/'^IP_SLAVE=IP'/'IP_SLAVE='$IP_SLAVE''/ /opt/backup-ha-xivo/pidof_asterisk.sh
#sleep 0.5

#${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE "mv /etc/logrotate.d/xivo-backup /etc/logrotate.d/xivo-backup.old.script"
sleep 0.5
${PATCH_SSH} ${USER}@$IP_XIVO_SLAVE " cat > /etc/logrotate.d/xivo-backup << EOF
/var/backups/xivo/data-ha-xivo.tgz {
        daily
        rotate 7
        nocompress
        create 640 root www-data
        nocreate
}
/var/backups/xivo/db-ha-xivo.tgz {
	daily
        rotate 7
        nocompress
        create 640 root www-data
        nocreate
}
EOF
"
sleep 0.5


#================== Unset globals ==============================================
unset PATCH_BASH
unset PATCH_CP
unset PATCH_LIBRARY
unset PATCH_PING
unset PATCH_MKDIR
unset IP_XIVO_SLAVE
unset ETAT_PING
unset USER 
unset PATCH_TMP
unset PATCH_SSH
unset NAME_SCRIPT
unset ETAT_SSH
unset PATCH_KEYGEN
unset PATCH_SSH_COPY_ID
unset PATCH_SCP
unset PORT_SSH
unset PATCH_FOLDER_BACKUP
unset NAME_BACKUP
unset PATCH_SCRIPT
unset PATCH_EXPECT


println warn " \n\t#######################################################################"
println warn " \n\t###################### INSTALLATION TERMINE ###########################"
#println warn " \n\t######## Veuillez remplacer sur le serveur cloud ######################"
#println warn " \n\t######## le fichier /etc/logrotate.d/xivo-backup ######################"
#println warn " \n\t######## les lignes var/backups/xivo/data-(date du jour).tgz ET #######"
#println warn " \n\t######## var/backups/xivo/db-(date du jour).tgz PAR ###################"
#println warn " \n\t######## var/backups/xivo/data-\`date '+%d%m%Y'\`.tgz ET ################"
#println warn " \n\t######## var/backups/xivo/db-\`date '+%d%m%Y'\`.tgz #####################"
println warn " \n\t#######################################################################\n"
