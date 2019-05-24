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

createId(){
    ORG=$1
	USERNAME=$2
	PASSWORD="pwd"
	PORT="7054"
	HOST="localhost"
    export FABRIC_CA_CLIENT_HOME=$PWD/fabric-ca/client/$ORG/admin
	echo "Peer Register Starting..."
	fabric-ca-client register --id.type peer --id.name $USERNAME --id.secret $PASSWORD --id.affiliation $ORG
	echo "Peer Register Completed with "$USERNAME
	export FABRIC_CA_CLIENT_HOME=$PWD/fabric-ca/client/$ORG/$USERNAME
	echo http://$USERNAME:$PASSWORD@$HOST:$PORT
	echo $FABRIC_CA_CLIENT_HOME
	fabric-ca-client enroll -u http://$USERNAME:$PASSWORD@$HOST:$PORT
	echo "Peer Enrolled on "$HOST:$PORT
	mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
	cp $PWD/fabric-ca/client//$ORG/admin/msp/signcerts/* $FABRIC_CA_CLIENT_HOME/msp/admincerts
}

launchPeer()
{
    ORG=$1
    PEERNAME=$2
    PORT=$3

    setenv $ORG $PEERNAME $PORT

    export CORE_PEER_FILESYSTEMPATH="$PWD/blockchain/peers/$PEERNAME/ledger"
    mkdir -p $CORE_PEER_FILESYSTEMPATH

    export CORE_PEER_ID=$PEERNAME

    PEER_LOGS="./blockchain/peers/$PEERNAME.log"
    ./peer node start 2> $PEER_LOGS &

    echo "LOG : "$PEER_LOGS
    echo $PEERNAME is STARTED!!



}

joinChannel(){
    ORDERER="localhost:7050"
    CHANNEL=$1
    GENESIS="energy-genesis.block"
    
    ./peer channel fetch config $GENESIS -o $ORDERER -c $CHANNEL
    echo Fetching OK
    
    ./peer channel join -o $ORDERER -b $GENESIS
    echo Joining OK
    rm $GENESIS 2> /dev/null

    ./peer channel list
}

#----------------------------------------------------------
#                   Kill Them All
#----------------------------------------------------------

# Stop running peer
killall peer
# Stop running orderer
killall orderer  2> /dev/null
# Remove exist artifacts
rm -rf ./artifacts
# Remove exist blockchains
rm -rf ./blockchain

#----------------------------------------------------------
#                   Network Artifacts
#----------------------------------------------------------
#   Creating Artifacts of network from configtx.yaml
export FABRIC_CFG_PATH=$PWD/config
mkdir -p artifacts
mkdir -p blockchain
# Genesis Block
./configtxgen -profile EnergyOrdererGenesis -outputBlock ./artifacts/energy-genesis.block -channelID energychannel
# Enerjisa Channel
./configtxgen -profile EnerjisaChannel -outputCreateChannelTx ./artifacts/enerjisa-channel.tx -channelID enerjisachannel
# Aydem Channel
./configtxgen -profile AydemChannel -outputCreateChannelTx ./artifacts/aydem-channel.tx -channelID aydemchannel

#----------------------------------------------------------
#                   Orderer Peer
#----------------------------------------------------------
#   Launching Orderer
export FABRIC_CFG_PATH=$PWD/config
export ORDERER_FILELEDGER_LOCATION=$PWD/blockchain/.
echo "Orderer is running"
./orderer 2> orderer.log &
sleep 3
#----------------------------------------------------------
#                   Channel Creations
#----------------------------------------------------------
#   Creating channels

# EnerjisaChannel
setenv enerjisa admin 7050
./peer channel create -o localhost:7050 -c enerjisachannel -f ./artifacts/enerjisa-channel.tx --outputBlock ./artifacts/enerjisachannel-genesis.block

# AydemChannel
setenv aydem admin 9050   
./peer channel create -o localhost:7050 -c aydemchannel -f ./artifacts/aydem-channel.tx --outputBlock ./artifacts/aydemchannel-genesis.block

echo "*******************   Channel List   *******************"
./peer channel list

#----------------------------------------------------------
#                   Peer Identification
#----------------------------------------------------------
#   Generating Identitites for Peers

# Adding a peer into each organization
createId enerjisa enerjisa-peer1 
createId aydem aydem-peer1 
createId kamukurumu kamukurumu-peer1 

#----------------------------------------------------------
#                   Peer Identification
#----------------------------------------------------------
#   Launching the Peers

launchPeer enerjisa enerjisa-peer1 7050
launchPeer aydem aydem-peer1 9050
launchPeer kamukurumu kamukurumu-peer1 6050

echo "Fabric Processes"
echo "================"
ps -eal | grep peer
ps -eal | grep orderer
ps -eal | grep fabric-ca   

#----------------------------------------------------------
#                   Joining Channels
#----------------------------------------------------------
#   Joininig creating channels


setenv aydem admin 9050
joinChannel aydemchannel

setenv enerjisa admin 7050
joinChannel enerjisachannel

setenv kamukurumu admin 6050
joinChannel aydemchannel
joinChannel enerjisachannel

