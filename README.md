# Autorenew der Letsencrypt Zertifikate mit CloudPanel

## Was macht dieses Script?

Das Skript `cloudpanel-autorenew-letsencrypt-certs.v1.sh` automatisiert die Erneuerung und Installation von Let's Encrypt-Zertifikaten für alle Domains und Subdomains, die auf einem CloudPanel-Server konfiguriert sind. Es durchsucht die Nginx-Konfigurationsdateien im Verzeichnis `/etc/nginx/sites-enabled/` nach Domain-Namen, extrahiert diese und führt für jede gefundene Domain den Befehl `clpctl lets-encrypt:install:certificate` aus, um das entsprechende SSL-Zertifikat zu erneuern oder zu installieren. Das Skript protokolliert alle seine Aktivitäten in eine Log-Datei, die im Verzeichnis `/var/log/script-logs` gespeichert wird.

## Ausführung:

1. **Klonen des Repositorys**
`git clone https://git.techniverse.net/scriptos/cloudpanel-autorenew-letsencrypt-certs.git`

2. **Email Settings im Script anpassen**

Folgende Variablen stehen zur Auswahl:
```
email_from="mail@domain.com"
email_from_name="$hostname | CloudPanel Server"
email_to="mail@domain.com"
email_subject="Letsencrypt Zertifikate wurden auf $HOSTNAME erneuert"
```

3. **Ausführen des Scripts**
`bash cloudpanel-autorenew-letsencrypt-certs.v1.sh`

Die Ausgabe sollte folgendermaßen aussehen:

![autorenew](https://git.techniverse.net/scriptos/cloudpanel-autorenew-letsencrypt-certs/raw/branch/main/assets/autorenew1.png)

## Cronjob:

Der Cronjob kann wiefolgt konfiguriert werden.
Ich für meinen Teil lasse dieses Script einmal im Monat laufen.

1. Aufrufen des Crontabs
`crontab -e`

2. Konfiguration Cronjob
`@monthly bash /home/scripts/default/cloudpanel-autorenew-letsencrypt-certs.v1.sh >/dev/null 2>&1`
