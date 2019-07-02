#!/bin/bash
setenv(){
    # Variables
    ORG_NAME=$1
    IDENTITY=$2
    PORT_NUMBER_BASE=$3

    # Paths
    PATH_ORG="$(tr '[:upper:]' '[:lower:]' <<< $ORG_NAME)"
    export CORE_PEER_MSPCONFIGPATH="/hlf-enerji/fabric-ca/client/$PATH_ORG/$IDENTITY/msp"
    echo CORE_PEER_MSPCONFIGPATH="/hlf-enerji/fabric-ca/client/$PATH_ORG/$IDENTITY/msp"
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
    export FABRIC_CFG_PATH="/hlf-enerji/config/"
    echo FABRIC_CFG_PATH=$FABRIC_CFG_PATH
    # for chaincode
    export GOPATH="/hlf-enerji/gopath"
    export NODECHAINCODE="/hlf-enerji/chaincode"
    export CURRENT_ORG_NAME=$ORG_NAME
    export CURRENT_IDENTITY=$IDENTITY
}

launchPeer()
{
    ORG=$1
    PEERNAME=$2
    PORT=$3

    setenv $ORG $PEERNAME $PORT

    export CORE_PEER_FILESYSTEMPATH="/hlf-enerji/blockchain/peers/$PEERNAME/ledger"
    mkdir -p $CORE_PEER_FILESYSTEMPATH

    export CORE_PEER_ID=$PEERNAME

    PEER_LOGS="/hlf-enerji/blockchain/peers/$PEERNAME.log"
    peer node start 2> $PEER_LOGS &

    echo "LOG : "$PEER_LOGS
    echo $PEERNAME is STARTED!!
}

joinChannel(){
    ORDERER="10.5.10.10:7050"
    CHANNEL=$1
    GENESIS="energy-genesis.block"
    
    peer channel fetch config $GENESIS -o $ORDERER -c $CHANNEL
    echo Fetching OK
    
    peer channel join -o $ORDERER -b $GENESIS
    echo Joining OK
    rm $GENESIS 2> /dev/null

    peer channel list
}