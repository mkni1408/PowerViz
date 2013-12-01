
import time
import subprocess

#Run the harvester forever!
while True:
	subprocess.call("./Harvester-debug", shell=True)
	time.sleep(5); #Wait 5 secs before trying again.
	
	
