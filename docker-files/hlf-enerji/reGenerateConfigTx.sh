#!/bin/bash
sleep 10
# Genesis Block
export FABRIC_CFG_PATH=/hlf-enerji/config
mkdir -p /hlf-enerji/artifacts/
configtxgen -profile EnergyOrdererGenesis -outputBlock /hlf-enerji/artifacts/energy-genesis.block -channelID energychannel
# Enerjisa Channel
configtxgen -profile EnerjisaChannel -outputCreateChannelTx /hlf-enerji/artifacts/enerjisa-channel.tx -channelID enerjisachannel
# Aydem Channel
configtxgen -profile AydemChannel -outputCreateChannelTx /hlf-enerji/artifacts/aydem-channel.tx -channelID aydemchannel
