#!/usr/bin/env bash
# Updates the server to the latest main. Run as the homecoffee user:
#   /var/www/homecoffee/backend/deploy/deploy.sh
# The GitHub "Deploy" workflow runs it over SSH after CI passes on main.
set -euo pipefail

cd "$(dirname "$0")/.."

git pull --ff-only --quiet origin main
echo "At $(git log -1 --format='%h %s')"

composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --quiet

php artisan migrate --force
php artisan storage:link --quiet 2>/dev/null || true
php artisan optimize
php artisan filament:optimize

# Workers pick up the new code once their current job is done
php artisan queue:restart
php artisan reverb:restart

url=$(grep -E '^APP_URL=' .env | cut -d= -f2- | tr -d '"')
curl --silent --fail --max-time 10 "$url/up" > /dev/null
echo "Deployed, and $url/up answers."
