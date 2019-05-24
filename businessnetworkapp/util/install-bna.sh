#!/bin/bash
setenv(){
    # Variables
    ORG_NAME=$1
    IDENTITY=$2
    PORT_NUMBER_BASE=$3

    # Paths
    PATH_ORG="$(tr '[:upper:]' '[:lower:]' <<< $ORG_NAME)"
    export CORE_PEER_MSPCONFIGPATH="$PWD/fabric-ca/client/$PATH_ORG/$IDENTITY/msp"
    echo CORE_PEER_MSPCONFIGPATH="$PWD/fabric-ca/client/$PATH_ORG/$IDENTITY/msp"
    MSP_ID="$(tr '[:lower:]' '[:upper:]' <<< ${ORG_NAME:0:1})${ORG_NAME:1}" 
    export CORE_PEER_LOCALMSPID=$MSP_ID"MSP"
    echo CORE_PEER_LOCALMSPID=$MSP_ID"MSP"
    CURRENT_PORT=$((PORT_NUMBER_BASE+1))
    export CORE_PEER_LISTENADDRESS=0.0.0.0:$CURRENT_PORT
    echo CORE_PEER_LISTENADDRESS=0.0.0.0:$CURRENT_PORT
    export CORE_PEER_ADDRESS=0.0.0.0:$CURRENT_PORT
    echo CORE_PEER_ADDRESS=0.0.0.0:$CURRENT_PORT
    CURRENT_PORT=$((PORT_NUMBER_BASE+2))
    export CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:$CURRENT_PORT
    echo CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:$CURRENT_PORT
    CURRENT_PORT=$((PORT_NUMBER_BASE+3))
    export CORE_PEER_EVENTS_ADDRESS=0.0.0.0:$CURRENT_PORT
    echo CORE_PEER_EVENTS_ADDRESS=0.0.0.0:$CURRENT_PORT
    # for core.yaml
    export FABRIC_CFG_PATH="$PWD/config/"
    echo FABRIC_CFG_PATH=$FABRIC_CFG_PATH
    # for chaincode
    export GOPATH="$PWD/gopath"
    export NODECHAINCODE="$PWD/chaincode"
    export CURRENT_ORG_NAME=$ORG_NAME
    export CURRENT_IDENTITY=$IDENTITY
}

#----------------------------------------------------------
#                   Kill Them All
#----------------------------------------------------------

# Killing running composer-rest-server
killall node



#----------------------------------------------------------
#                   Installing BNA
#----------------------------------------------------------
#   Installing bna over network via Composer Tool

# Aydem - Install
composer network install -a ./../basic-energy-tracking.bna -c Aydem-peer1PeerAdmin@hlfv1 
sleep 2
# Aydem - Start
composer network start -n basic-energy-tracking -c Aydem-peer1PeerAdmin@hlfv1 -V 1.0.1 -A aydem-admin -S pwd
sleep 1
echo "Renaming aydem-admin@basic-energy-tracking.card ===>> peer1-aydem-admin@basic-energy-tracking.card"
mv aydem-admin@basic-energy-tracking.card peer1-aydem-admin@basic-energy-tracking.card
# Enerjisa - Install
composer network install -a ./../basic-energy-tracking.bna -c Enerjisa-peer1PeerAdmin@hlfv1 
sleep 2
# Enerjisa - Start
composer network start -n basic-energy-tracking -c Enerjisa-peer1PeerAdmin@hlfv1 -V 1.0.1 -A enerjisa-admin -S pwd
sleep 1
mv enerjisa-admin@basic-energy-tracking.card peer1-enerjisa-admin@basic-energy-tracking.card
echo "Renaming enerjisa-admin@basic-energy-tracking.card ===>> peer1-enerjisa-admin@basic-energy-tracking.card"

#----------------------------------------------------------
#                   Installing Cards
#----------------------------------------------------------
#   Installing cards via Composer Tool

composer card import -f ./peer1-aydem-admin@basic-energy-tracking.card
composer card import -f ./peer1-enerjisa-admin@basic-energy-tracking.card

#----------------------------------------------------------
#                   Launching Composer Rest Server
#----------------------------------------------------------
#   Installing Composer Rest Server for testing

composer-rest-server -c enerjisa-admin@basic-energy-tracking -p 3001 &
sleep 10

composer-rest-server -c aydem-admin@basic-energy-tracking -p 3002 &
sleep 10

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.SmartMeter","SmartmeterId": "1000","Model": "BCRG","Version": "1.15", "LastUpdateDate": "2019-05-24T12:30:40.043Z"}' 'http://localhost:3001/api/org.example.basic.SmartMeter'

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.EnergyUsage","energyId": "1000", "owner": "org.example.basic.SmartMeter#1000","TotalMeasure": 0}' 'http://localhost:3001/api/org.example.basic.EnergyUsage'

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.EnergyUsageTransaction","asset": "org.example.basic.EnergyUsage#1000","AddingMeasure": 10}' 'http://localhost:3001/api/org.example.basic.EnergyUsageTransaction'


curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.SmartMeter","SmartmeterId": "2000","Model": "BCRG","Version": "1.15","LastUpdateDate": "2019-05-24T12:30:40.043Z"}' 'http://localhost:3002/api/org.example.basic.SmartMeter'

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.EnergyUsage","energyId": "2000","owner": "org.example.basic.SmartMeter#1000","TotalMeasure": 0}' 'http://localhost:3002/api/org.example.basic.EnergyUsage'

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.EnergyUsageTransaction","asset": "org.example.basic.EnergyUsage#1000","AddingMeasure": 20}' 'http://localhost:3002/api/org.example.basic.EnergyUsageTransaction'
