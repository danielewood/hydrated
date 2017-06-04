# Hydrated
Hydrated was originally written to solve a problem, Lync/Skype4B Edge requires a costly SAN certificate. This script adds a layer to `dehydrated` to make adding multiple sets of SSL certificate in an automated manner easier to manage.

## Installation

```
cd ~
git clone https://github.com/danielewood/hydrated
cd hydrated
git clone https://github.com/lukas2511/dehydrated
cd dehydrated
mkdir hooks
git clone https://github.com/kappataumu/letsencrypt-cloudflare-hook hooks/cloudflare
```

If you are using Python 3 on CentOS 7:
```
sudo yum install epel-release
sudo yum install python34-setuptools
sudo easy_install-3.4 pip
```

CloudFlare Hooks:
```
sudo pip install -r hooks/cloudflare/requirements.txt
```

GoDaddy Hooks:
```
sudo pip install -r hooks/cloudflare/requirements.txt
```



## hydrated-pfx.sh
- Hydrated generates said certificate using Let's Encrypt with DNS Hooks in a format that can then be imported to Lync/S4B.
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



# CloudFlare hook for `dehydrated`

This is a hook for the [Let's Encrypt](https://letsencrypt.org/) ACME client [dehydrated](https://github.com/lukas2511/dehydrated) (previously known as `letsencrypt.sh`) that allows you to use [CloudFlare](https://www.cloudflare.com/) DNS records to respond to `dns-01` challenges. Requires Python and your CloudFlare account e-mail and API key being in the environment.



Otherwise, if you are using Python 2 (make sure to also check the [urllib3 documentation](http://urllib3.readthedocs.org/en/latest/security.html#installing-urllib3-with-sni-support-and-certificates) for possible caveats):

```
$ pip install -r hooks/cloudflare/requirements-python-2.txt
```


## Configuration

Your account's CloudFlare email and API key are expected to be in the environment, so make sure to:

```
$ export CF_EMAIL='user@example.com'
$ export CF_KEY='K9uX2HyUjeWg5AhAb'
```

Optionally, you can specify the DNS servers to be used for propagation checking via the `CF_DNS_SERVERS` environment variable (props [bennettp123](https://github.com/bennettp123)):

```
$ export CF_DNS_SERVERS='8.8.8.8 8.8.4.4'
```

If you want more information about what is going on while the hook is running:

```
$ export CF_DEBUG='true'
```

Alternatively, these statements can be placed in `dehydrated/config`, which is automatically sourced by `dehydrated` on startup:

```
echo "export CF_EMAIL=user@example.com" >> config
echo "export CF_KEY=K9uX2HyUjeWg5AhAb" >> config
echo "export CF_DEBUG=true" >> config
```




## Usage

```
$ ./dehydrated -c -d example.com -t dns-01 -k 'hooks/cloudflare/hook.py'
#
# !! WARNING !! No main config file found, using default config!
#
Processing example.com
 + Signing domains...
 + Creating new directory /home/user/dehydrated/certs/example.com ...
 + Generating private key...
 + Generating signing request...
 + Requesting challenge for example.com...
 + CloudFlare hook executing: deploy_challenge
 + DNS not propagated, waiting 30s...
 + DNS not propagated, waiting 30s...
 + Responding to challenge for example.com...
 + CloudFlare hook executing: clean_challenge
 + Challenge is valid!
 + Requesting certificate...
 + Checking certificate...
 + Done!
 + Creating fullchain.pem...
 + CloudFlare hook executing: deploy_cert
 + ssl_certificate: /home/user/dehydrated/certs/example.com/fullchain.pem
 + ssl_certificate_key: /home/user/dehydrated/certs/example.com/privkey.pem
 + Done!
```

## Further reading
If you want some prose to go with the code, check out the relevant blog post here: [From StartSSL to Let's Encrypt, using CloudFlare DNS](http://kappataumu.com/articles/letsencrypt-cloudflare-dns-01-hook.html).




```
git clone https://github.com/lukas2511/dehydrated
cd dehydrated
mkdir hooks
git clone https://github.com/kappataumu/letsencrypt-cloudflare-hook hooks/cloudflare



sudo yum install epel-release
sudo yum install python34-setuptools
sudo easy_install-3.4 pip
sudo pip install -r hooks/cloudflare/requirements.txt
```
