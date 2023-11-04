#!/bin/bash -e

CERT_PATH=/usr/local/share/ca-certificates
CERT_NAME=crt.crt
openssl s_client -connect 192.168.1.1:443 2>/dev/null </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $CERT_NAME
echo "We need to be sudo"
sudo echo ""
sudo cp $CERT_NAME $CERT_PATH/
sudo mv $CERT_PATH/$CERT_NAME $CERT_PATH/router.crt

rm $CERT_NAME







# Update
sudo update-ca-certificates
