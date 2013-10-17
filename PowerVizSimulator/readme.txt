

Playback tool for simulating the use of electricity over time, as recorded by an intelligent home.

The tool runs a simulation specified in an XML file.

The simulation is divided into time blocks, so all data is located in timeblocks.
There can be several timeblocks that have the same timestamp.
Timeblocks can be set to repeat, by using the <time every="" from=""> format.
A timeblock that should only repeat a number of times can use the repeat="" argument, where 0 means infinite repititions.


<simulation house="42" defaultLoad="0">


	<!-- one time event.-->
	<time at="00:00:01"> 
		<load outlet="0" set="500" />
		<load outlet="1" add="100" />
		<load outlet="4" sub="50" />
	</time>
	
	<!-- Simulating a freezer on outlet 1: 
		Every 16.30, turn it on, 
		then turn it off 5 minutes later.
	-->
	<time every="00:16:30" from="00:00:00" repeat="0">
		<load outlet="1" add="300" />
	</time>	
	<time every="00:16:30" from="00:05:00" repeat="0">
		<load outlet="1" sub="300" />
	</time>

</simulation>


The simulator contains a set of timeblocks. 
When the simulation time advances, all timeblocks are examined to see if any on them should be activated.
At each simulation step a delta is calculated. If a timeblock is within that delta, the loads inside the timeblocks should be set.


-------------

The playback tool is simple to start and operate. It is a standard terminal tool.
./PowerVizPlayback fileName speedMultiply


