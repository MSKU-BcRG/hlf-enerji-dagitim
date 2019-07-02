#!/bin/bash


killall fabric-ca-server  2> /dev/null
killall peer
rm -rf ./fabric-ca/*
rm -rf ./blockchain/*
rm -rf ./artifacts/*
rm -rf ./businessnetworkapp/cards/*
rm -rf ./businessnetworkapp/util/*.card
echo "All Clear"