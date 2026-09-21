<?php
$root = getenv('NEOFIRE_ROOT') ?: '/var/www/html';
chdir($root);
define('NF_ROOT', $root);
define('NF_BASE', NF_ROOT . '/vendor/neofire');
define('NF_CORE', NF_BASE . '/core');
define('NF_PUBLIC', NF_BASE . '/public');
define('NF_ADMIN', NF_BASE . '/admin');
if (!is_file(NF_ROOT . '/.nf_installed') || !is_file(NF_ADMIN . '/cron.php')) {
    exit(0);
}
require NF_ADMIN . '/cron.php';
