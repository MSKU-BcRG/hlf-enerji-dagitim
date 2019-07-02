#!/bin/bash

#Setting Client and Server Path for Users
setenv(){
    export FABRIC_CA_CLIENT_HOME=/hlf-enerji/fabric-ca/client/$1/$2
    export FABRIC_CA_SERVER_HOME=/hlf-enerji/fabric-ca/server/$1/$2
}

killall fabric-ca-server  2> /dev/null
#----------------------------------------------------------
#                   Fabric CA Server
#----------------------------------------------------------
#   CA Admin Identity Creating

# Creating a new folder
mkdir -p /hlf-enerji/fabric-ca
# FABRIC_CA_CLIENT_HOME
export FABRIC_CA_CLIENT_HOME=/hlf-enerji/fabric-ca/client  
# FABRIC_CA_SERVER_HOME
export FABRIC_CA_SERVER_HOME=/hlf-enerji/fabric-ca/server
mkdir -p $FABRIC_CA_SERVER_HOME
#Initializing the CA Server
fabric-ca-server init -b admin:pwd -n ca.localhost.com
# Config Path -- Maybe Later
DEFAULT_CLIENT_CONFIG_YAML=/hlf-enerji/config/fabric-ca-server-config.yaml
# Set Path for Client
cp $DEFAULT_CLIENT_CONFIG_YAML  "/hlf-enerji/fabric-ca/server/"

#----------------------------------------------------------
#                   Fabric CA Server
#----------------------------------------------------------
#   Launch

echo 'Launching network on ca.server.com'

# # Set the location
# export FABRIC_CA_SERVER_HOME=/hlf-enerji/fabric-ca/server
# export FABRIC_CA_CLIENT_HOME=/hlf-enerji/fabric-ca/client

# Launch network
fabric-ca-server -n ca.server.com -p 7054 start &

sleep 5

#----------------------------------------------------------
#                   Fabric CA Server
#----------------------------------------------------------
#   Enroll CA Admin Identity

DEFAULT_CLIENT_CONFIG_YAML=/hlf-enerji/config/fabric-ca-client-config.yaml

# Set Path for Client
export FABRIC_CA_CLIENT_HOME=/hlf-enerji/fabric-ca/client/caserver/admin
# new folder for admin
mkdir -p $FABRIC_CA_CLIENT_HOME
cp $DEFAULT_CLIENT_CONFIG_YAML  "$FABRIC_CA_CLIENT_HOME/"
# enroll ca admin 
fabric-ca-client enroll -u http://admin:pwd@localhost:7054
echo "For Checking Identity"
fabric-ca-client identity list


#----------------------------------------------------------
#                   Fabric CA Server
#----------------------------------------------------------
#   Registering Identities of Orgs's Admins

setenv caserver admin
echo "Registering Process for Admins"
# Register orderer-admin
ATTRIBUTES='"hf.Registrar.Roles=orderer,user,client"'
fabric-ca-client register --id.type client --id.name "orderer-admin" --id.secret pwd --id.affiliation orderer --id.attrs $ATTRIBUTES
echo "Registered orderer-admin"
# Register enerjisa-admin
ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"'
fabric-ca-client register --id.type client --id.name "enerjisa-admin" --id.secret pwd --id.affiliation enerjisa --id.attrs $ATTRIBUTES
echo "Registered enerjisa-admin"
# Register aydem-admin
ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"'
fabric-ca-client register --id.type client --id.name "aydem-admin" --id.secret pwd --id.affiliation aydem --id.attrs $ATTRIBUTES
echo "Registered aydem-admin"
# Register kamukurumu-admin
ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true"'
fabric-ca-client register --id.type client --id.name "kamukurumu-admin" --id.secret pwd --id.affiliation kamukurumu --id.attrs $ATTRIBUTES
echo "Registered kamukurumu-admin"

echo "Register Process Over"

#----------------------------------------------------------
#                   Fabric CA Server
#----------------------------------------------------------
#   Enrolling Admin Identities

echo "Enrolling Process for Admins"
# Enroll the orderer-admin identity
setenv orderer admin
fabric-ca-client enroll -u http://orderer-admin:pwd@localhost:7054
echo "orderer-admin Enrolled!"
# Setup MSP 
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
echo "====> $FABRIC_CA_CLIENT_HOME/msp/admincerts"
cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts

# Enroll the enerjisa-admin identity
setenv enerjisa admin
fabric-ca-client enroll -u http://enerjisa-admin:pwd@localhost:7054
echo "enerjisa-admin Enrolled!"
# Setup MSP 
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
echo "====> $FABRIC_CA_CLIENT_HOME/msp/admincerts"
cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts

# Enroll the aydem-admin identity
setenv aydem admin
fabric-ca-client enroll -u http://aydem-admin:pwd@localhost:7054
echo "aydem-admin Enrolled!"
# Setup MSP 
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
echo "====> $FABRIC_CA_CLIENT_HOME/msp/admincerts"
cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts

# Enroll the kamukurumu-admin identity
setenv kamukurumu admin
fabric-ca-client enroll -u http://kamukurumu-admin:pwd@localhost:7054
echo "kamukurumu-admin Enrolled!"
# Setup MSP 
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
echo "====> $FABRIC_CA_CLIENT_HOME/msp/admincerts"
cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts

#----------------------------------------------------------
#                   Fabric CA Server
#----------------------------------------------------------
#   Installing Admin MSPs
export FABRIC_CA_SERVER_HOME=/hlf-enerji/fabric-ca/server
export FABRIC_CA_CLIENT_HOME=/hlf-enerji/fabric-ca/client

ROOT_CA=$FABRIC_CA_SERVER_HOME/ca-cert.pem


echo "MSP Setup starting"
for entry in `ls $FABRIC_CA_CLIENT_HOME -Icaserver`
    do
    echo "For $entry admin"
    # Paths for copying
    DESTINATION=$FABRIC_CA_CLIENT_HOME/$entry
    CURRENT=$DESTINATION/admin

    # Org Msp Directories Generated
    mkdir -p $DESTINATION/msp/admincerts
    mkdir -p $DESTINATION/msp/cacerts
    mkdir -p $DESTINATION/msp/keystore

    # Copying Server CA to Org MSP
    echo "Copying Server Certs from $ROOT_CA to $DESTINATION/msp/cacerts"
    cp -ru $ROOT_CA $DESTINATION/msp/cacerts

    # Copying peer admin signcerts to Org MSP
    echo "Copying Admin Certs from $FABRIC_CA_CLIENT_HOME/msp/signcerts/ to $DESTINATION/msp/admincerts"
    cp $DESTINATION/admin/msp/signcerts/* $DESTINATION/msp/admincerts
    done

echo "MSP SETUP DONE"

#----------------------------------------------------------
#                   Fabric CA Server
#----------------------------------------------------------
#   Generating Orderer Identities

setenv orderer admin

echo "Orderer Register Starting..."
fabric-ca-client register --id.type orderer --id.name orderer --id.secret pwd --id.affiliation orderer
echo "Orderer Register Completed with orderer"

export FABRIC_CA_CLIENT_HOME=/hlf-enerji/fabric-ca/client/orderer/orderer
echo http://orderer:pwd@localhost:7054
echo $FABRIC_CA_CLIENT_HOME
fabric-ca-client enroll -u http://orderer:pwd@localhost:7054
echo "Orderer Enrolled on localhost:7054"
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
cp /hlf-enerji/fabric-ca/client/orderer/admin/msp/signcerts/* $FABRIC_CA_CLIENT_HOME/msp/admincerts

read