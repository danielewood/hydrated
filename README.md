# Hydrated
Hydrated was originally written to solve a problem, Lync/Skype4B Edge requires a costly SAN certificate.

## hydrated-pfx.sh
- Hydrated generates said certificate using Let's Encrypt with DNS Hooks in a format that can then be imported to Lync.
- It is designed for debian based distros. It will automatically download and install all the needed components to generate Let's Encrypt Certificates and interface with the GoDaddy DNS API.
- If you need another DNS provider's hooks, look here: https://github.com/lukas2511/dehydrated/wiki/Examples-for-DNS-01-hooks
- All you need to do is edit the .conf and put in your settings. You can pass any other config file as an argument. This makes for easy use of cron for generating multiple certificates using different conf files.
- A Powershell script will be added later, as well as a writeup, to allow automatic importation of certificates into Windows IIS and Lync servers.

## Install-LE-CsCertificate.ps1
- Description here...
## Install-LE-IISCertificate.ps1
- Description here...
## Send-NewCertificateNotification.ps1
- Description here...
## get-apache-certs.sh
- Description here...
## hydrated-pfx.conf
- Description here...
