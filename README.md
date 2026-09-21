# neofire Core System

Bestellsystem für Produkte, Termine, Vermietung und Abos – selbst gehostet mit Docker. Mehr unter [neofire.de](https://www.neofire.de).

```
ghcr.io/neofire-core-system/core:1
```

## Schnellstart

```bash
cp .env.example .env    # Werte eintragen
docker compose up -d
```

Beim ersten Start wartet der Container auf die Datenbank und richtet den Shop automatisch ein. Danach ist er unter `SHOP_URL` erreichbar, die Verwaltung unter `SHOP_URL/admin`.

## Ohne Docker (Webserver mit PHP und MySQL)

Im leeren Web-Verzeichnis per SSH:

```bash
curl -fsSL https://raw.githubusercontent.com/neofire-core-system/neofire-core-system/main/install.sh -o /tmp/neofire-install.sh
bash /tmp/neofire-install.sh
```

Das Skript lädt die aktuelle Version von neofire.de, fragt Datenbank, Shop- und Betreiberdaten ab und richtet den Shop ein.

## Umgebungsvariablen

| Variable | Pflicht | Bedeutung |
|---|---|---|
| `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS` | ja | Zugang zur MariaDB/MySQL-Datenbank |
| `SHOP_URL` | ja | öffentliche Adresse des Shops, z. B. `https://shop.example.de` |
| `SHOP_EMAIL` | ja | E-Mail-Adresse des Shops |
| `ADMIN_USER`, `ADMIN_EMAIL`, `ADMIN_PASS` | Passwort ja | erster Zugang zur Verwaltung |
| `COMPANY`, `STREET`, `POSTCODE`, `CITY` | ja | Betreiberangaben (Impressum, Belege) |
| `ACCEPT_TERMS` | ja | `1` = Lizenzbedingungen, AGB und Datenschutz von neofire akzeptiert |
| `NEOFIRE_AUTO_INSTALL` | nein | `0` schaltet die automatische Einrichtung ab |
| `NEOFIRE_AUTO_UPDATE` | nein | `0` verhindert, dass ein neues Image den Kern (`vendor/neofire`) aktualisiert |
| `NEOFIRE_CRON` | nein | `0` schaltet die eingebaute Cron-Schleife ab |

Alle Daten (Einstellungen, Medien, Dokumente, Erweiterungen) liegen im Volume `/var/www/html`. Ein neues Image aktualisiert nur den Kern unter `vendor/neofire`.

## Lizenz

neofire Core ist proprietäre Software. Es gelten die [AGB](https://www.neofire.de/agb) und die [Datenschutzerklärung](https://www.neofire.de/datenschutz) von neofire. Dieses Repository enthält nur die Bauanleitung des Images; der Shop wird beim Bau aus dem offiziellen Paket geladen.
