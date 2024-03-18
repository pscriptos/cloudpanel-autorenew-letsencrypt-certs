#!/bin/bash
# Script Name:  cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Beschreibung: Erneuert automatisch Letsencrypt Zertifikate in Cloudpanel
# Aufruf:       bash ./cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Autor:        Patrick Asmus
# Web:          https://www.media-techport.de
# Git-Reposit.: https://git.media-techport.de/scriptos/cloudpanel-autorenew-letsencrypt-certs.git
# Version:      1.1
# Datum:        18.03.2024
# Modifikation: Benachrichtigung per Email hinzugefuegt
#####################################################

# Variablen
config_path="/etc/nginx/sites-enabled/"
log_dir="/var/log/script-logs"
log_file="$log_dir/cloudpanel-letsencrypt-renew.log"

email_to="system@media-techport.de"
email_from="noreply@media-techport.de"
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
echo "Die Letsencrypt Zertifikate wurden auf $HOSTNAME erneuert. Bitte überprüfe das angehängte Log für Details." | mail -a "$log_file" -s "$email_subject" -r "$email_from" "$email_to"
