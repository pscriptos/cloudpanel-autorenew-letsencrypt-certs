#!/bin/bash
# Script Name:  cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Beschreibung: Erneuert automatisch Letsencrypt Zertifikate in Cloudpanel
# Aufruf:       bash ./cloudpanel-autorenew-letsencrypt-certs.v1.sh
# Autor:        Patrick Asmus
# Web:          https://www.techniverse.net
# Git-Reposit.: https://git.techniverse.net/scriptos/cloudpanel-autorenew-letsencrypt-certs.git
# Version:      1.5
# Datum:        02.07.2024
# Modifikation: Alternative DNS Names werden nun auch unterstützt
#####################################################

# Variablen
hostname=$(hostname)
config_path="/etc/nginx/sites-enabled/"
log_dir="/var/log/script-logs"
log_file="$log_dir/cloudpanel-letsencrypt-renew.log"

email_from="mail@domain.com"
email_from_name="$hostname | CloudPanel Server"
email_to="mail@domain.com"
email_subject="Letsencrypt Zertifikate wurden auf $hostname erneuert"

days_until_expiry=14
exclude_domains="example.com other.example.com"

# Leite die Ausgaben in das Log-File um
mkdir -p $log_dir
exec > >(tee -i "$log_file")
exec 2>&1

# Funktion zur Erneuerung/Erstellung von Zertifikaten
renew_certificate() {
    local primary_domain=$1
    local subject_alternative_names=$2

    echo "Erneuere/Erstelle Zertifikat für: $primary_domain mit alternativen Namen: $subject_alternative_names"
    bash /usr/bin/clpctl lets-encrypt:install:certificate --domainName="$primary_domain" --subjectAlternativeName="$subject_alternative_names"
}

# Funktion zur Überprüfung des Ablaufdatums eines Zertifikats
check_certificate_expiry() {
    local primary_domain=$1
    local all_domains=$2
    local expiry_date=$(openssl s_client -connect $primary_domain:443 -servername $primary_domain < /dev/null 2>/dev/null | openssl x509 -noout -dates | grep 'notAfter=' | cut -d= -f2)
    local expiry_timestamp=$(date -d "$expiry_date" +%s)
    local current_timestamp=$(date +%s)
    local days_left=$(( (expiry_timestamp - current_timestamp) / 86400 ))

    if [[ $days_left -lt $days_until_expiry ]]; then
        echo "Das Zertifikat für $all_domains läuft in weniger als $days_until_expiry Tagen ab (in $days_left Tagen)."
        renew_certificate "$primary_domain" "$all_domains"
    else
        echo "Das Zertifikat für $all_domains ist noch $days_left Tage gültig. Keine Erneuerung erforderlich."
    fi
}

# Extrahiere Domains aus den Konfigurationsdateien und überprüfe Zertifikatsgültigkeit
for file in $config_path*; do
    primary_domain=$(grep "server_name" $file | awk '{print $2}' | tr -d ';' | sed 's/^www\.//' | tr -d '\r')
    all_domains=$(grep "server_name" $file | awk '{for (i=2; i<=NF; i++) print $i}' | tr -d ';' | sed 's/^www\.//' | tr -d '\r' | paste -sd "," -)

    if [ -n "$primary_domain" ]; then
        check_certificate_expiry "$primary_domain" "$all_domains"
    fi
done

# Senden einer E-Mail mit dem Logfile als Anhang
echo "Die Letsencrypt Zertifikate wurden auf $hostname überprüft und ggf. erneuert. Bitte überprüfe das angehängte Log für Details." | mail -a "$log_file" -s "$email_subject" -r "\"$email_from_name\" <$email_from>" "$email_to"
