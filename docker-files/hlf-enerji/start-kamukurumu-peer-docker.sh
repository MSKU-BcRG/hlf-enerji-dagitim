#!/bin/bash
sleep 40
source ./hlf-enerji/docker-util.sh
setenv kamukurumu admin 10.5.10.90 7050
sleep 2
launchPeer kamukurumu kamukurumu-peer1  10.5.10.90 7050
setenv kamukurumu admin 10.5.10.90 7050
joinChannel aydemchannel
joinChannel enerjisachannel
read