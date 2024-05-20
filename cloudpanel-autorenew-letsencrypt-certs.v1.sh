#!/bin/bash
# Script Name:  cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Beschreibung: Erneuert automatisch Letsencrypt Zertifikate in Cloudpanel
# Aufruf:       bash ./cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Autor:        Patrick Asmus
# Web:          https://www.techniverse.net
# Git-Reposit.: https://git.techniverse.net/scriptos/cloudpanel-autorenew-letsencrypt-certs.git
# Version:      1.3
# Datum:        20.05.2024
# Modifikation: Domains können nun von der Zertifikatenerneuerung ausgeschlossen werden
#####################################################

# Variables
hostname=$(hostname)
config_path="/etc/nginx/sites-enabled/"
log_dir="/var/log/script-logs"
log_file="$log_dir/cloudpanel-letsencrypt-renew.log"

# Email Settings
email_from="mail@domain.com"
email_from_name="$hostname | CloudPanel Server"
email_to="mail@domain.com"
email_subject="Letsencrypt Zertifikate wurden auf $HOSTNAME erneuert"

# Exclude Domains
exclude_domains="example.com other.example.com"

# Leite die Ausgaben in das Log-File um
mkdir -p $log_dir
exec > >(tee -i "$log_file")
exec 2>&1

# Funktion zur Erneuerung/Erstellung von Zertifikaten
renew_certificate() {
    local domain=$1
    if [[ ! $exclude_domains =~ (^|[[:space:]])$domain($|[[:space:]]) ]]; then
        echo "Erneuere/Erstelle Zertifikat für: $domain"
        bash /usr/bin/clpctl lets-encrypt:install:certificate --domainName=$domain
    else
        echo "Überspringe $domain, da es ausgeschlossen ist."
    fi
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
