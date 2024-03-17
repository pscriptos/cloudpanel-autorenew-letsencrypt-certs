#!/bin/bash
# Script Name:  cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Beschreibung: Erneuert automatisch Letsencrypt Zertifikate in Cloudpanel
# Aufruf:       bash ./cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Autor:        Patrick Asmus
# Web:          https://www.media-techport.de
# Git-Reposit.: https://git.media-techport.de/scriptos/cloudpanel-autorenew-letsencrypt-certs.git
# Version:      1.0
# Datum:        17.03.2024
# Modifikation: Initial
#####################################################

# Variablen
config_path="/etc/nginx/sites-enabled/"
log_dir="/var/log/script-logs"
log_file="$log_dir/cloudpanel-letsencrypt-renew.log"

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

