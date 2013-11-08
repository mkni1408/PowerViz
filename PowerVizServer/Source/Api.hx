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
	
	//General purpose function to get the current suerver time.
	public function getTime() : Date {
		return DataBaseInterface.getNow();
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
	
	public function setRoomColor(houseId:Int, roomId:Int, color:String) {
		DataBaseInterface.setRoomColor(houseId, roomId, color);
	}
	
	public function setOutletColor(houseId:Int, outletId:Int, color:String) {
		DataBaseInterface.setOutletColor(houseId, outletId, color);
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
	
	public function removeHistoryDataOnwards(houseId:Int, from:Date) {
		DataBaseInterface.removeHistoryDataOnwards(houseId, from);
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
	public function getCurrentLoadAll(houseId:Int) : Map<Int, Float> {
		return DataBaseInterface.getCurrentLoadAll(houseId);
	}
	
	/**
	Returns the current usage on a single outlet in the specified house.
	**/
	public function getCurrentLoad(houseId:Int, outletId:Int) : Float {
		return DataBaseInterface.getCurrentLoad(houseId, outletId);
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
			prevLoad = e.watts;
		}
		return accum;
	}
	
	//Should not be used!
	public function getOutletHistoryAllToday(houseId:Int) : Map<Int, Array<TimeWatts> > {
		return DataBaseInterface.getOutletHistoryAllToday(houseId);
	}
	
	public function getOutletHistoryAllDay(houseId:Int) : Map<Int, Array<TimeWatts> > {
		return DataBaseInterface.getOutletHistoryAllDay(houseId);
	}
	
	public function getOutletHistoryAllHour(houseId:Int) : Map<Int, Array<TimeWatts> > {
		return DataBaseInterface.getOutletHistoryAllHour(houseId);
	}
	
	public function getOutletHistoryAllWeek(houseId:Int) : Map<Int, Array<TimeWatts> > {
		return DataBaseInterface.getOutletHistoryAllWeek(houseId);
	}
	
	public function getOutletHistoryThreeDays(houseId:Int) : Map<Int, Array<TimeWatts> > {
		return DataBaseInterface.getOutletHistoryThreeDays(houseId);
	}
	
	public function getOutletHistoryLastQuarter(houseId:Int) : Map<Int, Float> {
		return DataBaseInterface.getOutletHistoryLastQuarter(houseId);
	}
	
	public function getRelativeMax(houseId:Int) : Float {
		return DataBaseInterface.getRelativeMax(houseId);
	}
	
	public function getCurrentPowerSource() : String {
		return DataBaseInterface.getCurrentPowerSource();
	}
	
	public function getMaxWattsSetting(houseId:Int) : Float {
		return DataBaseInterface.getMaxWattsSetting(houseId);
	}
	
	public function setMaxWattsSetting(houseId:Int, watts:Float) {
		DataBaseInterface.setMaxWattsSetting(houseId, watts);
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


