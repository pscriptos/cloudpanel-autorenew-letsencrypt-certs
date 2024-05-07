#!/bin/bash
# Script Name:  cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Beschreibung: Erneuert automatisch Letsencrypt Zertifikate in Cloudpanel
# Aufruf:       bash ./cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Autor:        Patrick Asmus
# Web:          https://www.techniverse.net
# Git-Reposit.: https://git.techniverse.net/scriptos/cloudpanel-autorenew-letsencrypt-certs.git
# Version:      1.2
# Datum:        07.05.2024
# Modifikation: Domain geändert, Doku erweitert und Email Settings angepasst
#####################################################

# Variablen
hostname=$(hostname)
config_path="/etc/nginx/sites-enabled/"
log_dir="/var/log/script-logs"
log_file="$log_dir/cloudpanel-letsencrypt-renew.log"

email_from="mail@domain.com"
email_from_name="$hostname | CloudPanel Server"
email_to="mail@domain.com"
email_subject="Letsencrypt Zertifikate wurden auf $HOSTNAME erneuert"

# Leite die Ausgaben in das Log-File um
mkdir -p $log_dir
exec > >(tee -i "$log_file")
exec 2>&1

# Funktion zur Erneuerung/Erstellung von Zertifikaten
renew_certificate() {
    local domain=$1
    echo "Erneuere/Erstelle Zertifikat für: $domain"
    bash /usr/bin/clpctl lets-encrypt:install:certificate --domainName=$domain
}

# Extrahiere Domains aus den Konfigurationsdateien und führe Zertifikatserneuerung aus
for file in $config_path*; do
    domains=$(grep "server_name" $file | awk '{print $2}' | tr -d ';' | sed 's/^www\.//' | tr -d '\r')
    for domain in $domains; do
        if [ "$domain" != "_" ]; then
            renew_certificate $domain
        fi
    done
done

# Senden einer E-Mail mit dem Logfile als Anhang
echo "Die Letsencrypt Zertifikate wurden auf $HOSTNAME erneuert. Bitte überprüfe das angehängte Log für Details." | mail -a "$log_file" -s "$email_subject" -r "\"$email_from_name\" <$email_from>" "$email_to"
