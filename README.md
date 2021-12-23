# Irgat

Irgat is a bash script which creates Wordpress website on top of a LAMP stack and configures Cloudflare Origin certificate with Apache2 to use Cloudflare Strict Mode SSL.

## What you need?

- Working LAMP stack
- Cloudflare account

## Before you start

- Add your domain to cloudflare
- Go to 'Cloudflare>yourdomain>SSL/TLS>Overview' and select strict mode.
- In SSL/TLS section go to Origin Server tab and select 'Generate private key and CSR with Cloudflare' option with RSA (2048) type and create certificate. Cloudflare will prompt your key and cert codes leave that window open for later use.

## Installation

```
git clone https://github.com/ilovepilav/Irgat
cd Irgat
sudo bash irgat.sh
```

Script will ask your;

- Domain name
- Database name
- Database username
- Database user password
- Cloudflare Certificate
- Cloudflare Private Key

It will create MySQL database, user and gives all privileges to given user.

For the cloudflare part just paste your codes and wait 2 seconds.

Script will create these folders if non-exist;

```
/var/www/yourdomain/public_html
/etc/cloudflare
```

Created cloudflare files will be moved /etc/cloudflare.

Script will give 755 to wordpress folders and 644 to wordpress files except wp-config it will be 400 and make www-data user which is apache2 owner of files and folders.

Lastly script will create yourdomain.conf file for apache2 in /etc/apache2/sites-available and activate it.

## Why i created this?

Creating multiple wordpress in the same linux server was always my anxiety so i heal my problem by creating this.

I used CPanel, CyberPanel even Plesk for hosting management but most of them are paid and generally doesn't work with aarch64 servers.

## Contributing

If you want to add some functuality like creating LAMP stack if doesn't exists or some if-else statements for asking user if user wants to implement SSL etc. feel free to open pull request, all appreciated.

## License

[MIT](https://choosealicense.com/licenses/mit/)
