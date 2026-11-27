# Putting HomeCoffee on a server

This guide sets up one small Ubuntu server that runs everything: the API for
the app, the admin panel, live order status (Reverb), the queue worker, and
nightly backups. It takes about an hour the first time.

The files it uses are next to this guide:

| File | What it is |
| --- | --- |
| `nginx/homecoffee.conf` | The web server: HTTPS, the Laravel app, and the app's live-status socket |
| `supervisor/homecoffee.conf` | Keeps the queue worker and Reverb running |
| `crontab` | Runs the nightly jobs in `routes/console.php` |
| `.env.production.example` | Every setting the server needs |
| `deploy.sh` | Updates the server to the latest `main` |

## What you need first

| What | Suggestion | Cost |
| --- | --- | --- |
| A server | Ubuntu 24.04, 1 GB of memory or more, in Singapore (DigitalOcean, Vultr, Linode or Hetzner) | about $6 a month |
| A domain | Any registrar. The guide uses `homecoffee.example.com`: use your own everywhere you see it | about $10 a year |
| Email sending | [Resend](https://resend.com) free tier, with your domain verified, for sign-in codes and staff invites | free |
| Backup storage | A [Cloudflare R2](https://developers.cloudflare.com/r2/) bucket called `homecoffee-backups`, and an API token for it | free up to 10 GB |

## 1. Point the domain at the server

At your DNS provider, add an `A` record for `homecoffee.example.com` with the
server's IP address. It can take a few minutes to work.

## 2. Prepare the server

Sign in as root, then:

```sh
# A user that owns and runs the app
adduser --disabled-password --gecos "" homecoffee
mkdir -p /home/homecoffee/.ssh
cp ~/.ssh/authorized_keys /home/homecoffee/.ssh/
chown -R homecoffee:homecoffee /home/homecoffee/.ssh

# Only SSH and the web are open
ufw allow OpenSSH
ufw allow "Nginx Full"
ufw --force enable

# Everything the app needs
apt update
apt install -y nginx mysql-server supervisor certbot python3-certbot-nginx git unzip composer \
  php8.3-fpm php8.3-cli php8.3-mysql php8.3-mbstring php8.3-xml php8.3-curl php8.3-zip \
  php8.3-intl php8.3-gd php8.3-bcmath
```

PHP runs as the `homecoffee` user, so it can write the app's logs and uploads:

```sh
sed -i 's/^user = www-data/user = homecoffee/; s/^group = www-data/group = homecoffee/' /etc/php/8.3/fpm/pool.d/www.conf
systemctl restart php8.3-fpm
```

## 3. Create the database

```sh
mysql
```

```sql
CREATE DATABASE homecoffee CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'homecoffee'@'localhost' IDENTIFIED BY 'choose-a-long-password';
GRANT ALL PRIVILEGES ON homecoffee.* TO 'homecoffee'@'localhost';
-- The nightly backup reads table definitions too
GRANT PROCESS ON *.* TO 'homecoffee'@'localhost';
EXIT;
```

## 4. Install the app

```sh
mkdir -p /var/www/homecoffee && chown homecoffee:homecoffee /var/www/homecoffee
su - homecoffee
git clone https://github.com/codingspacekh/homecoffee.git /var/www/homecoffee
cd /var/www/homecoffee/backend
composer install --no-dev --optimize-autoloader
cp deploy/.env.production.example .env
nano .env        # fill in every value marked CHANGE
php artisan key:generate
php artisan migrate --seed --force     # tables, the menu and photos, the two promo codes
php artisan storage:link
php artisan homecoffee:owner you@example.com --name="Your name"
php artisan optimize
php artisan filament:optimize
exit
```

## 5. Turn on HTTPS and the website

```sh
# Get the certificate while nginx still shows its default page
certbot certonly --nginx -d homecoffee.example.com --agree-tos -m you@example.com --no-eff-email

cp /var/www/homecoffee/backend/deploy/nginx/homecoffee.conf /etc/nginx/sites-available/homecoffee
sed -i 's/homecoffee.example.com/YOUR.DOMAIN/g' /etc/nginx/sites-available/homecoffee
ln -s /etc/nginx/sites-available/homecoffee /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
```

Certbot renews the certificate by itself before it runs out.

## 6. Start the worker, Reverb and the nightly jobs

```sh
cp /var/www/homecoffee/backend/deploy/supervisor/homecoffee.conf /etc/supervisor/conf.d/
supervisorctl reread && supervisorctl update
supervisorctl status            # both should say RUNNING

crontab -u homecoffee /var/www/homecoffee/backend/deploy/crontab
```

## 7. Check it works

- `https://YOUR.DOMAIN/up` shows a green page.
- `https://YOUR.DOMAIN/admin` lets you sign in as the owner.
- `https://YOUR.DOMAIN/privacy` and `/delete-account` show the pages the app stores ask for.
- Make a first backup now instead of waiting for 2 AM:

  ```sh
  su - homecoffee -c "cd /var/www/homecoffee/backend && php artisan backup:run && php artisan backup:list"
  ```

  The list should show one backup on the `backups` disk.

Then build the app against this server (see the app's release guide, `apps/mobile/RELEASE.md`).

## Updating the server

Run `deploy/deploy.sh` as the `homecoffee` user. It pulls `main`, installs
packages, runs migrations, rebuilds caches, and restarts the worker and
Reverb.

To do this automatically after every merge, the **Deploy** workflow runs it
over SSH once CI passes. Set it up once:

1. On your computer, make a key just for deploying:
   `ssh-keygen -t ed25519 -f homecoffee_deploy -N ""`
2. Add `homecoffee_deploy.pub` to `/home/homecoffee/.ssh/authorized_keys` on the server.
3. Run `ssh-keyscan YOUR.DOMAIN` and copy what it prints.
4. In GitHub, under **Settings > Secrets and variables > Actions**, add
   `DEPLOY_HOST` (your domain), `DEPLOY_USER` (`homecoffee`),
   `DEPLOY_SSH_KEY` (the contents of `homecoffee_deploy`) and
   `DEPLOY_KNOWN_HOSTS` (what ssh-keyscan printed).

Until `DEPLOY_HOST` is set, the workflow does nothing.

## Backups

Every night at 2 AM Phnom Penh time the server zips the database and the
product photos, encrypts the zip with `BACKUP_ARCHIVE_PASSWORD`, and uploads
it to the bucket. Backups are kept for 4 months: every one for a week, then
one a day, one a week and one a month. Each morning at 8 AM the server checks
that last night's backup exists, and emails `BACKUP_NOTIFY_EMAIL` if it
doesn't or if a backup failed.

**Keep `BACKUP_ARCHIVE_PASSWORD` somewhere other than the server**, such as
your password manager. Without it a backup can't be opened.

To restore one (the zip is AES-encrypted, which `unzip` can't open, so use 7-Zip):

```sh
# Download the zip from the R2 dashboard, then on the server:
apt install -y 7zip
7z x -p'the backup password' -orestore 2026-12-01-02-00-00.zip
mysql -u homecoffee -p homecoffee < restore/db-dumps/mysql-homecoffee.sql
cp -r restore/storage/app/public/* /var/www/homecoffee/backend/storage/app/public/
```

## Where to look when something is wrong

| Problem | Look at |
| --- | --- |
| A page shows "Server error" | `storage/logs/laravel-YYYY-MM-DD.log` |
| Sign-in codes don't arrive | the same log, and the email provider's dashboard |
| Order status doesn't update live | `storage/logs/reverb.log`, and `supervisorctl status` |
| Emails or pushes are late | `storage/logs/worker.log`, and `php artisan queue:failed` |
| The site doesn't load at all | `systemctl status nginx php8.3-fpm`, and `/var/log/nginx/error.log` |
