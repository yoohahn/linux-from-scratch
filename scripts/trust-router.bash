#!/bin/bash -e

## Add router cert to trusted
CERT_PATH=/usr/local/share/ca-certificates
CERT_NAME=crt.crt
openssl s_client -connect 192.168.1.1:443 2>/dev/null </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $CERT_NAME

sudo cp $CERT_NAME $CERT_PATH/
sudo mv $CERT_PATH/$CERT_NAME $CERT_PATH/router.crt

rm $CERT_NAME

# Update
sudo update-ca-certificates

echo "192.168.1.1        unifi.local" | sudo tee -a /etc/hosts > /dev/null
