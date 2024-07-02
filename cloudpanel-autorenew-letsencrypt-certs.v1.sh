#!/bin/bash
# Script Name:  cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Beschreibung: Erneuert automatisch Letsencrypt Zertifikate in Cloudpanel
# Aufruf:       bash ./cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Autor:        Patrick Asmus
# Web:          https://www.techniverse.net
# Git-Reposit.: https://git.techniverse.net/scriptos/cloudpanel-autorenew-letsencrypt-certs.git
# Version:      1.4
# Datum:        02.07.2024
# Modifikation: Überprüfung der Zertifikate hinzugefügt
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
email_subject="Letsencrypt Zertifikate wurden auf $hostname erneuert"

# Exclude Domains
days_until_expiry=14
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

# Funktion zur Überprüfung des Ablaufdatums eines Zertifikats
check_certificate_expiry() {
    local domain=$1
    local expiry_date=$(openssl s_client -connect $domain:443 -servername $domain < /dev/null 2>/dev/null | openssl x509 -noout -dates | grep 'notAfter=' | cut -d= -f2)
    local expiry_timestamp=$(date -d "$expiry_date" +%s)
    local current_timestamp=$(date +%s)
    local days_left=$(( (expiry_timestamp - current_timestamp) / 86400 ))

    if [[ $days_left -lt $days_until_expiry ]]; then
        echo "Das Zertifikat für $domain läuft in weniger als $days_until_expiry Tagen ab (in $days_left Tagen)."
        renew_certificate $domain
    else
        echo "Das Zertifikat für $domain ist noch $days_left Tage gültig. Keine Erneuerung erforderlich."
    fi
}

# Extrahiere Domains aus den Konfigurationsdateien und überprüfe Zertifikatsgültigkeit
for file in $config_path*; do
    domains=$(grep "server_name" $file | awk '{print $2}' | tr -d ';' | sed 's/^www\.//' | tr -d '\r')
    for domain in $domains; do
        if [ "$domain" != "_" ]; then
            check_certificate_expiry $domain
        fi
    done
done

# Senden einer E-Mail mit dem Logfile als Anhang
echo "Die Letsencrypt Zertifikate wurden auf $HOSTNAME überprüft und ggf. erneuert. Bitte überprüfe das angehängte Log für Details." | mail -a "$log_file" -s "$email_subject" -r "\"$email_from_name\" <$email_from>" "$email_to"
