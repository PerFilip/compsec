#!/bin/bash

#
# FOR CLIENT
#

answer1=".\n.\n.\n.\n.\nCA\n."
answer2="David Bergh(da7700be-s)/Tilda Glas(ti7462gl-s)/Filip Hedén(fi6468he-s)/Oliver Nilssen(ol0716ni-s)\n.\n.\n.\n.\n.\nyes\npassword\npassword"

#Generate private key
openssl genrsa -out ca.key 2048

#Create client certificate locked with private key
echo -e $answer1 | openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.crt

#Create client truststore with client certificate
echo -e "yes" | keytool -importcert -file ca.crt -alias client -keystore clienttruststore -storetype jks -storepass password

#Generate keypair for client (private and public) and puts it in the keystore
echo -e $answer2 | keytool -genkeypair -alias client -keyalg RSA -keysize 2048 -keystore clientkeystore -validity 365 -storetype JKS -storepass password

# Create clientreq
keytool -certreq -alias client -keystore clientkeystore -file clientreq.csr -storepass password

# Create certificate
openssl x509 -req -in clientreq.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out clientcert.crt -days 365 -sha256

#Import certificate
echo -e "yes" | keytool -importcert -trustcacerts -keystore clientkeystore -storepass password -file ca.crt

# Import cert
keytool -importcert -trustcacerts -keystore clientkeystore -storepass password -file clientcert.crt -alias client

#
# FOR SERVER
#
answer3="Myserver\n.\n.\n.\n.\n.\nyes\npassword\npassword"

#Create keypair for server 
echo -e $answer3 | keytool -genkeypair -alias server -keyalg RSA -keysize 2048 -keystore serverkeystore -validity 365 -storetype JKS -storepass password 

# Create server keystore
echo -e "password" | keytool -certreq -keystore serverkeystore -alias server -keyalg rsa -file serverreq.csr

# Create server certificate
openssl  x509  -req -CA ca.crt -CAkey ca.key -in serverreq.csr -out servercert.crt -days 365 -CAserial ca.srl

# Create server something
echo -e "yes" | keytool -importcert -keystore serverkeystore -file ca.crt -alias rootCA -storepass password

# Something 
echo -e "yes" | keytool -importcert -trustcacerts -keystore serverkeystore -storepass password -alias server -file servercert.crt

# Something
echo -e "yes" | keytool -import -file ca.crt -alias server -keystore servertruststore -storepass password

# something more
keytool -list -v -keystore serverkeystore -storepass password

# ...
keytool -list -v -keystore clientkeystore -storepass password 

