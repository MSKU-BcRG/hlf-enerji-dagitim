#!/bin/bash

IP=$1
PORT=$2

while :
do
    curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.example.basic.EnergyUsageTransaction","asset": "org.example.basic.EnergyUsage#1000","AddingMeasure": '$(( ( RANDOM % 20 )  + 1 ))'}'  'http://'$IP':'$PORT'/api/org.example.basic.EnergyUsageTransaction'
    
    echo "Press [CTRL+C] to stop.."
	sleep 15
done
