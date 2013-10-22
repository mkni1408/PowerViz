package;

import DataBaseInterface;

//Common source:
import LayoutData; 
import HouseDescriptor; 

import SPODS;


/**
THE server api.
All functionality that the server offers are offered through this class.
**/

class Api {

	
	public function new() { //Constructor.
		DataBaseInterface.connect();		
	}
	
	//General purpose function to get the current timestamp on the server.
	public function getTimestamp() : Float {
		return Date.now().getTime();
	}
	
	////////////////////////////////////////////////////////
	//Functions for getting and setting the layout of the outlets:
	////////////////////////////////////////////////////////
	
	/*Returns an array of all outlets in the specified house.
	Uses caching to speed things up.*/
	public function getAllOutletIds(houseId:Int) : Array<Int>{
		return DataBaseInterface.getAllOutletIds(houseId);
	}
	
	public function getOutletNameMap(houseId:Int) : Map<Int, String> {
		return DataBaseInterface.getOutletIdNameMap(houseId);
	}
	
	public function getRoomNameMap(houseId:Int) : Map<Int, String> {
		return DataBaseInterface.getRoomNameMap(houseId);
	}
	
	/**Returns a map of all rooms and the outlets in each room Map<RoomId, Array<OutletId> >**/
	public function getAllRoomOutlets(houseId:Int) : Map<Int, Array<Int> > {
		return DataBaseInterface.getRoomOutletsMap(houseId);
	}

	/**Sets the layout of a specified house.**/
	public function setZenseLayout(houseId:Int, data:Array<LayoutData>) : Void {
		DataBaseInterface.setZenseLayout(houseId, data);
	}
	
	/**Returns a HouseDescriptor object. See the OutletDescriptor.hx file.**/
	public function getHouseDescriptor(houseId:Int) : HouseDescriptor {
			return DataBaseInterface.getHouseDescriptor(houseId);
	}
		
	///////////////////////////////////////////////////////
	//Functions for setting the current data state.
	///////////////////////////////////////////////////////
	
	/**
	Sets the current load on a specific outlet.
	**/
	public function setOutletLoad(houseId:Int, outletId:Int, load:Float) {
		DataBaseInterface.setCurrentLoad(houseId, outletId, load);
	}
	
	
	public function addOutletHistory(houseId:Int, outletId:Int, time:Date, watts:Float) {
		DataBaseInterface.addHistoryData(houseId, outletId, time, watts);
	}
	
	public function setPowerSource(source:String, time:Date) {
		DataBaseInterface.setPowerSource(source, time);
	}
	
	//////////////////////////////////////////////////////
	// Functions for retrieving data from the database
	//////////////////////////////////////////////////////
	
	/**Returns the current usage on all outlets for the specified house.
	Returns an array of anonymous structures, with loads of all outlets.
	**/
	public function getCurrentLoad(houseId:Int) : Array<{outletId:Int, load:Float}> {
		return DataBaseInterface.getCurrentLoadAll(houseId);
	}
	
	/**
	Returns the total use on the specified outlet measured in watts/hour.
	**/
	public function getOutletTotalTimespan(houseId:Int, outletId:Int, from:Date, to:Date) : Float {
		var ar = DataBaseInterface.getOutletHistory(houseId, outletId, from, to); //Array<{time:Date, load:Float}> //Should be sorted.
		var hour : Float = 3600*1000; //1 hour is 3600 seconds.
		var accum:Float=0;
		var prevTime:Float=from.getTime();
		var prevLoad:Float=0; 
		var h:Float=0; //Difference between two points, measured in hours.
		for(e in ar) {
			h = (e.time.getTime() - prevTime) / hour; //Find the difference in secons, then make that into hours.
			accum += prevLoad*h;
			prevTime = e.time.getTime();
			prevLoad = e.load;
		}
		return accum;
	}
	

	
	
	//*********************************************
	//Functions for the simulator:
	//**********************************************
	
	/*
	public function simulator_addToCurrentLoad(houseId:Int, outletId:Int, add:Float, time:Date) {
		var load:Float = DataBaseInterface.getCurrentLoad(houseId, outletId);
		load += add;
		DataBaseInterface.setCurrentLoad(houseId, outletId, load, time);
	}
	
	public function simulator_setCurrentLoad(houseId:Int, outletId:Int, load:Float, time:Date) {
		DataBaseInterface.setCurrentLoad(houseId, outletId, load, time);
	}
	

	public function simulator_setPowerSource(time:Date, source:String) {
		DataBaseInterface.setPowerSource(source, time);
	}
	*/
	
	
	
	//CONFIGURATION FUNCTIONS FOR THE BOX ::::::::::::::::::::::::::::::::::::
	
	public function getBoxConfig(houseId:Int) : {boxIP:String, boxID:String, boxPort:Int, sleepTime:Int, historyTime:Int} {
		return DataBaseInterface.getBoxConfig(houseId);
	}
	
	public function logBox(houseId:Int, time:Date, msg:String) {
		var d = new BoxLog();
		d.houseId = houseId;
		d.time = time;
		d.msg = msg;
		d.insert();
	} 

}


