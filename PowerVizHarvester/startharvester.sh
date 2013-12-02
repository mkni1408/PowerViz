#!/bin/bash
echo "Starting PowerVizHarvester!"
cd /home/pi/
#nohup java -jar Harvester.jar
nohup python RunHarvester.py & 


