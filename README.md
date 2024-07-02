# Autorenew der Letsencrypt Zertifikate mit CloudPanel


## Was macht dieses Script?

Dieses Script prüft im ersten Schritt, wie lange das Zertifikat der angegeben Domain noch gültig ist.
Wenn die Gültigkeit einen Wert in Tagen unterschreitet, welcher in der Variable `days_until_expiry=` angegebenen wurde, wird ein neues LetsEncrypt Zertifikat für besagte Domain erstellt.
Der Wert ist mit 14 Tagen voreingestellt und kann nach belieben verändert werden.

## Wie wird das Zertifikat erzeugt?

Es durchsucht die Nginx-Konfigurationsdateien im Verzeichnis `/etc/nginx/sites-enabled/` nach dem Domain-Namen, extrahiert diesen und führt den Befehl `clpctl lets-encrypt:install:certificate` aus, um das entsprechende SSL-Zertifikat zu erneuern oder zu installieren. Das Skript protokolliert alle seine Aktivitäten in eine Log-Datei, die im Verzeichnis `/var/log/script-logs` gespeichert wird.

## Features dieses Scriptes:

Domains können jetzt ausgeschlossen werden.
Das kann ganz einfach geschehen, in dem die auszuschließenden Domains in der Variable `exclude_domains=` gepflegt werden.

**Ein Beispiel:**

`exclude_domains="git.techniverse.net techniverse.net"`

In diesem Beispiel werden die Domains (Subdomains) `git.techniverse.net` und `techniverse.net` vom verlängern bzw. erstellen der LetzEncrypt Zertifikate ausgeschlossen.
Domains müssen immer durch Leerzeichen getrennt werden.
Sollen keine Domains ausgeschlossen werden, reicht es, die Variable leer zu lassen: `exclude_domains=""`


## Ausführung:

1. **Klonen des Repositorys**

`git clone https://git.techniverse.net/scriptos/cloudpanel-autorenew-letsencrypt-certs.git`


2. **Email Settings im Script anpassen**

Folgende Variablen stehen zur Auswahl, wenn der Emailversand genutzt werden soll:
```bash
email_from="mail@domain.com"
email_from_name="$hostname | CloudPanel Server"
email_to="mail@domain.com"
email_subject="Letsencrypt Zertifikate wurden auf $HOSTNAME erneuert"
```


3. **Ausführen des Scripts**

`bash cloudpanel-autorenew-letsencrypt-certs.v1.sh`

Die Ausgabe sieht folgendermaßen aus:
```bash
Das Zertifikat für cloud.media-techport.de läuft in weniger als 59 Tagen ab (in 58 Tagen).
Erneuere/Erstelle Zertifikat für: cloud.media-techport.de
Certificate installation was successful.
```

Wenn eine Domain übersprungen wird, sieht die Ausgabe folgendermaßen aus:

`Überspringe techniverse.net, da es ausgeschlossen ist.`

Wenn ein Zertifikat länger gültig ist, als in der Variable angegeben, sieht die Ausgabe folgendermaßen aus:

`Das Zertifikat für dl.techniverse.net ist noch 88 Tage gültig. Keine Erneuerung erforderlich.`

Wenn ein Zertifikat mit einem Alternativ DNS Name verlängert / erstellt wird, sieht die Ausgabe folgend aus:

```bash
Das Zertifikat für cloud.media-techport.de,cloud.techniverse.net läuft in weniger als 29 Tagen ab (in 27 Tagen).
Erneuere/Erstelle Zertifikat für: cloud.media-techport.de mit alternativen Namen: cloud.media-techport.de,cloud.techniverse.net
Certificate installation was successful.
```


## Cronjob:

Der Cronjob kann wiefolgt konfiguriert werden.

1. Aufrufen des Crontabs
`crontab -e`

2. Konfiguration Cronjob
`@daily bash /home/scripts/default/cloudpanel-autorenew-letsencrypt-certs.v1.sh >/dev/null 2>&1`

<p align="center">
  <img src="https://assets.techniverse.net/f1/git/graphics/gray0-catonline.svg" alt="">
</p>

<p align="center">
<img src="https://assets.techniverse.net/f1/logos/small/license.png" alt="License" width="15" height="15"> <a href="./cloudpanel-autorenew-letsencrypt-certs/src/branch/main/LICENSE">License</a> | <img src="https://assets.techniverse.net/f1/logos/small/matrix2.svg" alt="Matrix" width="15" height="15"> <a href="https://matrix.to/#/#community:techniverse.net">Matrix</a> | <img src="https://assets.techniverse.net/f1/logos/small/mastodon2.svg" alt="Matrix" width="15" height="15"> <a href="https://social.techniverse.net/@donnerwolke">Mastodon</a>
</p>