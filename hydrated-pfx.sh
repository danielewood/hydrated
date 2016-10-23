#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    /bin/echo -e "Alternatively, you may use: '\e[1;31mbash $0\e[0m'" 1>&2
    exit 1
fi

# Colors
COLOR_RED='\e[1;31m'
COLOR_GREEN='\e[92m'
COLOR_LTBLUE='\e[94m'
COLOR_OFF='\e[0m'

# Error checking:
if [ -z "$1" ]
  then
    CONFIG_FILE="hydrated-pfx.conf"
    echo -e "No argument supplied, using config file: "$COLOR_GREEN"$CONFIG_FILE"$COLOR_OFF
    source $CONFIG_FILE
  else
    CONFIG_FILE="$1"
    source $CONFIG_FILE
    echo -e "Using config file: "$COLOR_GREEN"$CONFIG_FILE"$COLOR_OFF
fi

if [ -z "$CERT_FileName" ]
  then
    echo -e "\e[1;31mWARNING:\e[0m" "Missing parameters from $CONFIG_FILE"
    echo -e "Exiting script..."
    exit 1
fi


#exit 1

#Check if tools/scripts are already setup in $SCRIPT_DIR, if not, perform setup:
if [ ! -d "$SCRIPT_DIR/dehydrated" ]; then
  # Set exit on error (set -e)
  set -e
  mkdir -p $SCRIPT_DIR
  # Remove later - sudo chown -R $CURRENT_USER:$CURRENT_USER $SCRIPT_DIR
  cd $SCRIPT_DIR
  # Set continue on error (set +e)
  set +e
  # Install letsencrypt.sh aka dehydrated
  git clone https://github.com/lukas2511/dehydrated
  # Install le-godaddy-dns
  git clone https://github.com/josteink/le-godaddy-dns
  sudo apt-get --assume-yes install python3 python3-pip curl
  python3 -m pip install --user godaddypy
fi

for CERT_ROOT in $CERT_ROOTS
do
    for CERT_SAN in $CERT_SANS
    do
       TEMP_SAN="$TEMP_SAN $CERT_SAN.$CERT_ROOT"
    done
    # Only enable if hostname is also valid for all $CERT_ROOTS: TEMP_SAN="$TEMP_SAN $(echo $CERT_CommonName | awk -F'.' '{print $1}').$CERT_ROOT"
    if [[ "$ROOTS_AS_SANS" == *"True"* ]]; then
      TEMP_SAN="$TEMP_SAN $CERT_ROOT"
    fi
done

#Remove duplicates + remove CERT_CommonName so it can be added later at the beginning (LE has issues otherwise)
CERT_SANS=$(echo "$TEMP_SAN" | xargs -n1 | sort -u | xargs | sed "s/$CERT_CommonName//g")

echo "Dehydrated:"
echo -e $COLOR_LTBLUE
#Lync Cert Common Name + SAN (CN must be in SAN field as well for a valid Lync Cert)
$SCRIPT_DIR/dehydrated/dehydrated --challenge $DEHYDRATED_CHALLENGE -k $SCRIPT_DIR/$DEHYDRATED_HOOK -c --domain "$CERT_CommonName $CERT_CommonName $CERT_SANS"
#$SCRIPT_DIR/dehydrated/dehydrated --challenge dns-01 -k $SCRIPT_DIR/le-godaddy-dns/godaddy.py -c --domain "$CERT_CommonName $CERT_CommonName $CERT_SANS"
echo -e $COLOR_OFF

#Check if fullchain.pem is less than 2 minutes old so we don't create a new PFX if the PEM was not updated
if [ $(find "$SCRIPT_DIR/dehydrated/certs/$CERT_CommonName" -mmin -2 -name "fullchain.pem") ]
  then
    #echo 'fullchain.pem < 2 minutes old'
    openssl pkcs12 -export -out $CERT_PFX_PATH/$CERT_FileName.pfx -inkey $SCRIPT_DIR/dehydrated/certs/$CERT_CommonName/privkey.pem -in $SCRIPT_DIR/dehydrated/certs/$CERT_CommonName/fullchain.pem -name $CERT_FriendlyName -password pass:CERT_Password
    echo -e "Exported Windows-compatible PFX certificate to \e[1;32m$CERT_PFX_PATH/$CERT_FileName.pfx\e[0m"
    echo "Certificate Details:"
    CERT_TEXT=$(openssl pkcs12 -info -in $CERT_PFX_PATH/$CERT_FileName.pfx -nokeys -password pass:$CERT_Password)
    echo -e "Certificate Friendly Name: "$COLOR_GREEN$(echo "$CERT_TEXT" | grep "friendlyName:" | awk -F': ' '{print $2}')$COLOR_OFF
    echo -e "Certificate Thumbprint: "$COLOR_GREEN$(echo "$CERT_TEXT" | grep "localKeyID:" | awk -F': ' '{print $2}' |  sed 's/ //g')$COLOR_OFF
    #Probably not needed:
      #chown $CURRENT_USER:$CURRENT_USER $CERT_PFX_PATH/$CERT_FileName.pfx
      #chmod 600 $CERT_PFX_PATH/$CERT_FileName.pfx
    CERT_TEXT=$(openssl x509 -in "$SCRIPT_DIR/dehydrated/certs/$CERT_CommonName/fullchain.pem" -text)
    echo -e "$CERT_TEXT" | grep "CN=$CERT_CommonName" -B4 | sed 's/        //g'
    echo -e "$CERT_TEXT"| grep "DNS:$CERT_CommonName" | xargs -n1 | sed 's/,//g' | sed 's/DNS:/    SAN: /g'
  else
    echo -e "\e[1;31mWARNING:\e[0m" "$CERT_CommonName/fullchain.pem was not updated, skipping writing new $CERT_FileName.pfx"
fi

if [[ "$CERT_TEXT" == *"Fake LE Intermediate"* ]]
  then
    echo " "
    echo -e "\e[1;31mWARNING:\e[0m" "You are using the Let's Encrypt Staging Server and not the Production Server"
fi
echo " "
