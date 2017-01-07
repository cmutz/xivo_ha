#!/bin/bash
#########################################
# Original script by Clément
# # Copyright (c) 2016, Clément Mutz <c.mutz@whoople.fr>
# #########################################
# # Modified by Clément Mutz
# # Contact at c.mutz@whoople.fr 



# changement de repertoire courant !
cd "$(dirname "$0")"



#================== Globals ==================================================
. global_install.sh
source global_install.sh



#================== Functions ================================================
if [[ ! -d $PATH_LIBRARY ]]
then
        git clone https://github.com/cmutz/fonction_perso_bash LIBRARY
else
        rm -r $PATH_LIBRARY && git clone https://github.com/cmutz/fonction_perso_bash LIBRARY
fi
. $PATH_LIBRARY/functions.sh
rsync -av $PATH_LIBRARY etc/xivo_ha/



#===============================================================
#================ Verify pre-requisites ========================
#===============================================================
println info " \n\tVérification des pré requis necessaire au bon fonctionnement du script\n"

f_check_soft $PATH_BASH
f_check_soft $PATH_CP
f_check_soft $PATH_PING
f_check_soft $PATH_MKDIR
f_check_soft $PATH_SSH
f_check_soft $PATH_KEYGEN
f_check_soft $PATH_SSH_COPY_ID
f_check_soft $PATH_SCP
f_check_soft $PATH_EXPECT

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

! f_isIPv4 $IP_XIVO_SLAVE && println error "\n\t-------> ADDRESS KO <-------" && exit 1 || println warn "\n\t-------> ADDRESS OK <-------"  

! f_verification_access_ping $IP_XIVO_SLAVE && println error "\n\t-------> PING KO <-------" && exit 1 || println warn "\n\t-------> PING OK <-------"
sleep 0.5

f_verification_connexion_ssh $USER $IP_XIVO_SLAVE $PORT_SSH
if [ $ETAT_SSH = "OK" ]; then 
    println ras "\n\t-------> Auto connection ssh OK <-------" 
else
    println error "\n\t-------> Auto connection ssh KO <-------\n\tBesoin d'utiliser paire de clé ssh"
    if f_ask_yn_question "\n\tVoulez-vous creer ou utiliser une paire de clé ssh avec l'application ssh-keygen ?"; then f_generate_pair_authentication_keys $USER $IP_XIVO_SLAVE $PORT_SSH
    else println error "\t\n It's not the end of the world but you must generate pair of authentication keys to finish installation"
    fi
fi
sleep 0.5

#===============================================================
#================ Installation =================================
#===============================================================
println info " \n\tLa connection ssh des serveurs est assuré"
println info " \n\tL'installation de la réplication va démarrer"

[ ! -d /etc/xivo_ha/ ] && ${PATH_MKDIR} -p /etc/xivo_ha/

${PATH_CP} -v ${PATH_SCRIPT}template.replication_cloud.sh /etc/xivo_ha/replication_cloud.sh
sed -iv s/'^IP_XIVO_SLAVE="IP-ADDRESS-VALIDE"'/'IP_XIVO_SLAVE='"$IP_XIVO_SLAVE"''/ /etc/xivo_ha/replication_cloud.sh
sleep 0.5

${PATH_SSH} -p ${PORT_SSH} ${USER}@$IP_XIVO_SLAVE ${PATH_MKDIR} -p /opt/backup-ha-xivo/
${PATH_SSH} -p ${PORT_SSH} ${USER}@$IP_XIVO_SLAVE ${PATH_MKDIR} -p /etc/xivo_ha/
sleep 0.5

${PATH_SCP} -P ${PORT_SSH} ${PATH_SCRIPT}template.check_xivo.sh ${USER}@$IP_XIVO_SLAVE:/etc/xivo_ha/check_xivo.sh
${PATH_SSH} -p ${PORT_SSH} ${USER}@$IP_XIVO_SLAVE sed -iv s/'^IP_MASTER=IP'/'IP_MASTER='$IP_MASTER''/ /etc/xivo_ha/check_xivo.sh
${PATH_SSH} -p ${PORT_SSH} ${USER}@$IP_XIVO_SLAVE sed -iv s/'^IP_SLAVE=IP'/'IP_SLAVE='$IP_SLAVE''/ /etc/xivo_ha/check_xivo.sh
sleep 0.5

${PATH_SCP} -P ${PORT_SSH} ${PATH_SCRIPT}template.database.replicate.sh ${USER}@$IP_XIVO_SLAVE:/etc/xivo_ha/database.replicate.sh
sleep 0.5

${PATH_SCP} -P ${PORT_SSH} ${PATH_SCRIPT}template.pidof_asterisk.sh ${USER}@$IP_XIVO_SLAVE:/etc/xivo_ha/pidof_asterisk.sh
sleep 0.5

echo "30 6 * * * root bash /etc/xivo_ha/replication_cloud.sh" >> /etc/cron.d/xivo_ha
sleep 0.5

${PATH_SSH} -p ${PORT_SSH} ${USER}@$IP_XIVO_SLAVE "echo '*/5 * * * * root bash /etc/xivo_ha/check_xivo.sh' >> /etc/cron.d/xivo_ha"
sleep 0.5

${PATH_SSH} -p ${PORT_SSH} ${USER}@$IP_XIVO_SLAVE "echo '0 7 * * * root bash /etc/xivo_ha/database.replicate.sh' >> /etc/cron.d/xivo_ha"
sleep 0.5

println warn " \n\t#######################################################################"
println warn " \n\t###################### INSTALLATION TERMINE ###########################"
println warn " \n\t#######################################################################\n"
