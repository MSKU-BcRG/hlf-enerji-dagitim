#!/bin/bash
sleep 20
source ./hlf-enerji/docker-util.sh
setenv enerjisa admin 10.5.10.30 7050
sleep 2
peer channel create -o 10.5.10.10:7050 -c enerjisachannel -f /hlf-enerji/artifacts/enerjisa-channel.tx --outputBlock /hlf-enerji/artifacts/enerjisachannel-genesis.block
launchPeer enerjisa enerjisa-peer1 10.5.10.30 7050
setenv enerjisa admin 10.5.10.30 7050
joinChannel enerjisachannel
read