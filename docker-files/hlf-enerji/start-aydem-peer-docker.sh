#!/bin/bash
sleep 30
source ./hlf-enerji/docker-util.sh
setenv aydem admin 10.5.10.60 7050
sleep 2
peer channel create -o 10.5.10.10:7050 -c aydemchannel -f /hlf-enerji/artifacts/aydem-channel.tx --outputBlock /hlf-enerji/artifacts/aydemchannel-genesis.block
launchPeer aydem aydem-peer1 10.5.10.60 7050
setenv aydem admin 10.5.10.60 7050
joinChannel aydemchannel
read