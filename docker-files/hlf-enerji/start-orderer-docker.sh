#!/bin/bash
sleep 10
mkdir -p /hlf-enerji/blockchain/peers
export FABRIC_CFG_PATH=/hlf-enerji/config
export ORDERER_FILELEDGER_LOCATION=/hlf-enerji/blockchain/
echo "Orderer is running"
orderer 2> /hlf-enerji/blockchain/peers/orderer.log &
read