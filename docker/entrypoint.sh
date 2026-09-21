#!/bin/bash
set -euo pipefail

WEB=/var/www/html
DIST=/opt/neofire/dist

log() { echo "[neofire] $*"; }

if [ ! -f "$WEB/index.php" ]; then
    log "first start: copying neofire Core into $WEB"
    cp -a "$DIST/." "$WEB/"
    chown -R www-data:www-data "$WEB"
elif [ "${NEOFIRE_AUTO_UPDATE:-1}" = "1" ] && [ -f "$WEB/.nf_installed" ] && ! cmp -s "$DIST/.neofire-build" "$WEB/.neofire-build" 2>/dev/null; then
    log "updating the core (vendor/neofire) to build $(cat "$DIST/.neofire-build")"
    rsync -a "$DIST/vendor/neofire/" "$WEB/vendor/neofire/"
    cp -a "$DIST/VERSION" "$DIST/.neofire-build" "$WEB/"
    chown -R www-data:www-data "$WEB/vendor/neofire" "$WEB/VERSION" "$WEB/.neofire-build"
fi

wait_for_database() {
    local tries=0
    until php -r '
        $h = getenv("DB_HOST") ?: "localhost"; $p = getenv("DB_PORT") ?: "3306";
        try { new PDO("mysql:host=$h;port=$p;dbname=" . getenv("DB_NAME"), getenv("DB_USER"), getenv("DB_PASS") ?: ""); exit(0); }
        catch (Throwable $e) { exit(1); }' 2>/dev/null; do
        tries=$((tries + 1))
        if [ "$tries" -ge 90 ]; then log "database not reachable after 3 minutes"; return 1; fi
        sleep 2
    done
}

if [ ! -f "$WEB/.nf_installed" ] && [ "${NEOFIRE_AUTO_INSTALL:-1}" = "1" ] && [ -n "${DB_NAME:-}" ] && [ -n "${ADMIN_PASS:-}" ]; then
    log "waiting for the database"
    wait_for_database
    log "installing neofire Core"
    php "$WEB/vendor/neofire/core/setup/cli.php"
    chown -R www-data:www-data "$WEB"
fi

if [ "${NEOFIRE_CRON:-1}" = "1" ]; then
    (
        while true; do
            sleep 60
            runuser -u www-data -- php /usr/local/lib/neofire/cron.php > /dev/null 2>&1 || true
        done
    ) &
fi

exec docker-php-entrypoint "$@"
