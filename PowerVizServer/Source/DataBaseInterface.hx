
import sys.db.Types;

import SPODS;

//Common objects:
import LayoutData; 
import HouseDescriptor; 



/**
Interface the the database.
This class supplies data reading/writing functions to the rest of theadmin server.

To make things simpler/prettier in code, DataBaseInterface uses the magnificent SPOD macros!!!

**/

class DataBaseInterface {

	private static var mConnection : sys.db.Connection; //The MySQL database connection.
	
	//Connects to the database. Should be run once at server script start.
	public static function connect() : Bool {
	
		sys.db.Manager.initialize(); //Initialize all the SPOD stuff.
		
		mConnection = sys.db.Mysql.connect({ //Connect to the MySQL database.
			host : "localhost",
			port : null,
			user : SensitiveData.instance.dbUser, //Get the connection info from another file...
			pass : SensitiveData.instance.dbPass,
			database : SensitiveData.instance.dataBase,
			socket : null //Use default socket.
		});
		
		if(mConnection == null) //If connection failed.
			return false;
		
		sys.db.Manager.cnx = mConnection; //Set the SPOD manager to use the MySQL database.
		
		return true;
	}

	
	/**
	Sets the current load on an outlet. The optional time argument should only
	be used by the simulator.
	**/
	public static function setCurrentLoad(houseId:Int, outletId:Int, load:Float, ?_time:Date) {

		var now = _time==null ? Date.now() : _time;
		
		//Write the current load to the CurrentLoad table (in mem):
		
		var cl = CurrentLoad.manager.select($houseId == houseId && $outletId == outletId);
		if(cl!=null) {
			cl.time = now;
			cl.load = load;
			cl.update();
		}
		else {
			cl = new CurrentLoad();
			cl.houseId = houseId;
			cl.outletId = outletId;
			cl.time = now;
			cl.load = load;
			cl.insert();
		}
	
	}
	
	/**
	Adds history data to the database.
	**/
	public static function addHistoryData(houseId:Int, outletId:Int, time:Date, watts:Float) {
		var data = new LoadHistory();
		data.houseId = houseId;
		data.outletId = outletId;
		data.time = time;
		data.load = watts;
		data.insert();
	}
	
	
	/**Sets the power source on a specific point in time.**/
	public static function setPowerSource(source:String, time:Date) {
	
		var ps = new PowerSource();
		ps.time = time;
		ps.source = source; //Use a text string, but in DB this is an enum.
		ps.insert();
	}
	
	//Returns all outlet IDs in the house.
	public static function getAllOutletIds(houseId:Int) : Array<Int> {
		var r = new Array<Int>();
		for(ho in HouseOutlets.manager.search($houseId == houseId)) {
			r.push(ho.outletId);
		}
		return r;
	}
	
	
	/**Returns a specific outlet name, based on the outlet Id.**/
	public static function getOutletIdName(houseId:Int, outletId:Int) : String {
		for(obj in HouseOutlets.manager.search($houseId==houseId && $outletId==outletId)) {
			return obj.outletName;
		}
		return "Unknown";
	}
	
	
	/**Returns a map of <outletId, outletName> data for the specified house.**/
	public static function getOutletIdNameMap(houseId:Int) : Map<Int, String> {
		var r = new Map<Int, String>();
		for(obj in HouseOutlets.manager.search($houseId==houseId)) {
			r.set(obj.outletId, obj.outletName);
		}
		return r;
	}
	
	
	/**Returns a map <roomId, Array<outletId>> **/
	public static function getRoomOutletsMap(houseId:Int) : Map<Int, Array<Int> > {
	
		var r = new Map<Int, Array<Int> >();
		var a : Array<Int>;
		for(room in HouseRooms.manager.search($houseId==houseId)) {
		
			a = new Array<Int>();
						
			for(outlet in HouseOutlets.manager.search($houseId==houseId && $roomId==room.roomId)) {
				a.push(outlet.outletId);
			}
			r.set(room.roomId, a);
		}
		return r;
	}
	
	public static function getRoomNameMap(houseId:Int) : Map<Int, String> {
	
		var r = new Map<Int, String>();
		for(room in HouseRooms.manager.search($houseId == houseId)) {
			r.set(room.roomId, room.roomName);
		}
		return r;
	}
	
	
	/**
	Sets the layout data as obtained from the zense PC-boks.
	**/
	public static function setZenseLayout(houseId:Int, data:Array<LayoutData>) {
		var id:Null<Int>;
		var update:Bool=false; //true if we should update.
		var elm:HouseOutlets=null;
		for(d in data) {
			id = Std.parseInt(d.outletId);
			
			if(id!=null) { //If the ID could be parsed as an int, continue.
			
				elm = HouseOutlets.manager.select($houseId==houseId && $outletId==id); //Start by finding out if we have the data already.
				
				update=true;
				if(elm==null) { //If the entry does not exist, create a new one.
					update=false;
					elm = new HouseOutlets();
				}
				
				//Enter the data into the object:
				elm.houseId = houseId;
				elm.outletId = id;
				elm.outletZenseName = d.name;
				elm.outletZenseRoom = d.room;
				elm.outletZenseFloor = d.floor;
				(update ? elm.update() : elm.insert()); //If we should update, update. Otherwise: insert.
			}
			
		}
	}
	
	
	public static function getHouseDescriptor(houseId:Int) : HouseDescriptor {
	
		var house = new HouseDescriptor();
		house.houseId = houseId;
		
		var allRooms = HouseRooms.manager.search($houseId == houseId);
		var allOutlets = HouseOutlets.manager.search($houseId == houseId);
		
		for(room in allRooms) {
			house.addRoom(new RoomDescriptor(houseId, room.roomId, room.roomName, room.roomColor));
		}
		
		for(outlet in allOutlets) {

			house.getRoom(outlet.roomId).addOutlet(new OutletDescriptor(outlet.outletId, outlet.outletId, outlet.outletName,
																		outlet.outletZenseName, outlet.outletZenseRoom,
																		outlet.outletZenseFloor, outlet.color)); 
		}
		
		return house;
	
	}
	
	
	
	//*************************************************************************************
	
	
	//Returns the current load on all outlets in the house.
	public static function getCurrentLoadAll(houseId:Int) : Array<{outletId:Int, load:Float}> {
		
		var r = new Array<{outletId:Int, load:Float}>();
		for(cl in LoadHistory.manager.search($houseId == houseId)) {
			r.push({outletId:cl.outletId, load:cl.load});
		}
		return r;
	}
	
	//Returns the current load on a specific outlet in the house.
	public static function getCurrentLoad(houseId:Int, outletId:Int) : Float {
	
		var cl = CurrentLoad.manager.select($houseId==houseId && $outletId==outletId);
		if(cl!=null)
			return cl.load;
		return -1;		
	}
	
	//Returns the load data that was recorded in the specified timespan for the specified outlet.
	//Returned as an array of anonymous structures.
	public static function getOutletHistory(houseId:Int, outletId:Int, from:Date, to:Date) : Array<{time:Date, load:Float}> {
		
		var r = new Array<{time:Date, load:Float}>();
		for(lh in LoadHistory.manager.search($houseId==houseId && $outletId==outletId && $time>=from && $time <= to, {orderBy : time})) {
				r.push({time:lh.time, load:lh.load});
		}
		return r;
	}
	
	
	public static function getOutletHistoryAll(houseId:Int, from:Date, to:Date) : Map<Int, Array<{time:Date, load:Float}> > {
		return null;
	}
	
	
	public static function getBoxConfig(houseId:Int) : {boxIP:String, boxID:String, boxPort:Int, sleepTime:Int, historyTime:Int} {
		var cfg = BoxConfig.manager.select($houseId==houseId);
		if(cfg!=null) {
			return {boxIP:cfg.boxIP, boxID:cfg.boxID, boxPort:cfg.boxPort, sleepTime:cfg.sleepTime, historyTime:cfg.historyTime};
		} 
		return null;
	}
	
	public static function enterBoxLogEntry(houseId:Int, time:Date, msg:String) {
		var d = new BoxLog();
		d.houseId = houseId;
		d.time = time;
		d.msg = msg;
		d.insert();
	}

}



