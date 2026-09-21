#!/usr/bin/env bash
# neofire Core System – Installation auf einem Webserver ohne Docker (PHP, MySQL/MariaDB).
# Aufruf im leeren Web-Verzeichnis:
#   bash <(curl -fsSL https://raw.githubusercontent.com/neofire-core-system/neofire-core-system/main/install.sh)
set -euo pipefail

ZIP_URL="${NEOFIRE_ZIP_URL:-https://www.neofire.de/downloads/neofire-core-1.0.0.0.zip}"
TARGET="${NEOFIRE_TARGET:-$(pwd)}"

say()  { printf '\n  %s\n' "$*"; }
fail() { printf '\n  Fehler: %s\n\n' "$*" >&2; exit 1; }

ask() {
    local var="$1" label="$2" default="${3:-}" secret="${4:-}" value=""
    if [ -n "${!var:-}" ]; then return; fi
    if [ -n "$secret" ]; then
        read -r -s -p "  $label: " value < /dev/tty; echo
    else
        read -r -p "  $label${default:+ [$default]}: " value < /dev/tty
    fi
    value="${value:-$default}"
    export "$var=$value"
}

for tool in php curl unzip; do
    command -v "$tool" > /dev/null 2>&1 || fail "$tool ist nicht installiert."
done
php -r 'exit(version_compare(PHP_VERSION, "7.4.0", ">=") ? 0 : 1);' || fail "PHP 7.4 oder neuer wird benötigt."

cd "$TARGET"
if [ -f index.php ] || [ -d vendor/neofire ]; then
    fail "In $TARGET liegt schon ein Shop. Bitte ein leeres Verzeichnis verwenden."
fi

say "neofire Core System wird geladen …"
curl -fsSL "$ZIP_URL?install=$(date +%s)" -o .neofire-install.zip || fail "Paket konnte nicht geladen werden."
unzip -q -o .neofire-install.zip || fail "Paket konnte nicht entpackt werden."
rm -f .neofire-install.zip
[ -f vendor/neofire/core/setup/cli.php ] || fail "Paket unvollständig."
say "Version $(cat VERSION 2>/dev/null || echo '?') entpackt."

say "Datenbank (muss leer sein)"
ask DB_HOST "Host" "localhost"
ask DB_NAME "Datenbankname"
ask DB_USER "Benutzer"
ask DB_PASS "Passwort" "" secret

say "Shop"
ask SHOP_URL "Adresse des Shops, z. B. https://shop.example.de/"
ask SHOP_NAME "Name des Shops"
ask SHOP_EMAIL "E-Mail-Adresse des Shops"

say "Betreiber (für Impressum und Belege)"
ask COMPANY "Firma"
ask STREET "Straße und Hausnummer"
ask POSTCODE "PLZ"
ask CITY "Ort"

say "Zugang zur Verwaltung"
ask ADMIN_USER "Benutzername" "admin"
ask ADMIN_EMAIL "E-Mail-Adresse" "${SHOP_EMAIL:-}"
ask ADMIN_PASS "Passwort (mindestens 8 Zeichen)" "" secret

if [ -z "${ACCEPT_TERMS:-}" ]; then
    say "Es gelten die AGB und die Datenschutzerklärung von neofire:"
    say "https://www.neofire.de/agb · https://www.neofire.de/datenschutz"
    read -r -p "  Akzeptieren? (ja/nein): " ACCEPT_TERMS < /dev/tty
    export ACCEPT_TERMS
fi

say "Einrichtung läuft …"
php vendor/neofire/core/setup/cli.php

say "Fertig. Letzter Schritt: In der Verwaltung unter System > Cronjobs steht die Cron-Adresse."
say "Diese im Hosting-Panel jede Minute aufrufen lassen."
echo
