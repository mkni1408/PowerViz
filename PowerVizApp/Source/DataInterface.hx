
import haxe.remoting.HttpAsyncConnection;
import Outlet;
import OnOffData;
import Config;


/*
Class that handles all data comming from the server.
This class works mainly as a dummy during the development.

Later on, when the server side is getting there, this dummy class wil start spitting out REAL DATA.
So, beware, be nice to the interface.

At the moment, the DataInterface is in a transistive state.
The server is getting ready for supplying data generated by the simulator, 
but the app is not yet ready to handle the data. 
This is why the DataInterface should be developed further.
*/

/*
The DataInterface class consists of two major parts:

 1. The functions that get data from the server, and
 2. The functions that the screens call to get the data.
 
 The functions getting the data from the server are run automatically by a timer.
 The function getting the current outlet states should be called frequently (once a second), 
 while the function getting history data should only run once a minute or similar.
 
 Each screen must implement its own updating mechanism to call the DataInterface for getting data.
 Screens using current data should obtain once a second max.
 
*/

class DataInterface {

	public static var instance(get, null) : DataInterface;
	static function get_instance() : DataInterface {
		if(instance == null)
			instance = new DataInterface();
		return instance;
	}
	
	private var mCnx : HttpAsyncConnection; //Remoting connection used for communicating with the server. 
	
	public var houseDescriptor(default,null) : HouseDescriptor; //All data describing the house and its outlets.
	
	public function new() {
		#if production
			this.connect("http://78.47.92.222/pvs/"); //Connect to production version.
		#else
			this.connect("http://78.47.92.222/pvsdev/"); //Connect to development version.
		#end 
		houseDescriptor = getHouseDescriptor();
	}
	
	//Connects to the server, setting up the remoting system.
	public function connect(url:String) {
		mCnx = HttpAsyncConnection.urlConnect(url);
		mCnx.setErrorHandler(onError);
	}
	
	//Called when a connection or server error occurs.
	private function onError(e:String) {
		trace("Connection error: " + e);
	}
	

	
	/*Returns the current total load in watts.*/
	public function getTotalCurrentLoad() : Float {
		return Math.random(); //A random number.
	}
	
	/*Returns the current load in watts on a specific switch.*/
	public function getCurrentLoadOutlet(outletId:Int) {
		
		var values = [122, 89, 56, 245, 189,111, 78, 411, 211];
		return values[outletId];
	}
	
	
	//Returns the outlet to the callback, which should have the form function(outletId, watts) : Void.
	public function requestCurrentOutletLoad(outletId:Int, callback:Int->Float->Void) {
		var load:Float;
		mCnx.Api.getCurrentLoad.call([Config.instance.houseId, outletId], function(d:Dynamic) {
			load = d;
			callback(outletId, load);
		});
	}
	
	
	//Returns all outlet data through a Map<outletId, watts>.
	public function requestCurrentOutletLoadAll(callback:Map<Int, Float> -> Void) {
		var r:Map<Int, Float>;
		mCnx.Api.getCurrentLoadAll.call([Config.instance.houseId], function(d:Dynamic) {
			r = d;
			callback(r);
		}); 
	}
	
	
	/*Returns an array of all outlet ids in the house.*/
	public function getAllOutlets() : Array<Int> {
		var r = new Array<Int>();
		for(od in houseDescriptor.getAllOutlets()) {
			r.push(od.outletId);
		}
		return r;
	}
	
	/*Returns all names for all outlets.*/
	public function getAllOutletNames() : Array<String> {
		var r = new Array<String>();
		for(od in houseDescriptor.getAllOutlets()) {
			r.push(od.name);
		}
		return r;
	}
	
	/*Returns all names for all rooms*/
	public function getAllRoomNames () : Array<String> {
		var r = new Array<String>();
		for(rd in houseDescriptor.getRoomArray() ) {
			r.push(rd.roomName);
		}
		return r;
	}
		
	/*Returns a specific outlet name, based on the outlet ID.*/
	public function getOutletName(outletId:Int) : String{
		var outlet = houseDescriptor.getOutlet(outletId);
		return outlet!=null ? outlet.name : "null";
	}
	
	public function getOutletColor(outletId:Int) : Int {
		var outlet = houseDescriptor.getOutlet(outletId);
		return outlet!=null ? outlet.outletColor : 0xFF00FF;
	}
	
	/*
	Returns an array of 96 floats, representing the useage data from the last 24 hours,
	based on HouseID and outletId.
	*/
	public function getOutletLastDayUsage(outletId:Int) : Array<Float> {
		
		
		var values = new Array<Float>();
		var cycles:Int = Std.random(12) + 1;
		var section:Int = Std.int(96 / cycles);
		
		while(cycles < 1 || cycles * section < 96)
			cycles += 1;
			
		
		var i:Int = 0;
		var j:Int = 0;
		var s:Int = 0;
		var a:Int = 0;
		while(i < cycles) {
			j = 0;
			s = Std.random(4) + 1;
			a = Std.random(30);
			while(j < section) {
				values.push((Math.random()*s)+a);
				j += 1;
			}
			i += 1;
		}
		
		
		var returns = new Array<Float>();
		var r:Int=0;
		while(r < 96) {
			returns.push(values[r]);
			r += 1;
		}
		
		
		return returns;
	}

	
	public function getOnOffData_OLD():Array<Outlet>{
		var outletData = new Array<Outlet>();
		var intData = [0,1,2,3,4,5,6,7,8,9,10];
		var idData = ["1","2","3","4","5","6","7","8","9","10"];
		var catData = ["tv","opvask","lampe","ovn","frys","køl","vaskemaskine","komfur","funky","elpisker","Tues funky"];
		var wattData = [10.4,10.4,2.4,5.3,10.4,10.4,2.4,5.3,5.2,8.2,1.1];
		var roomData=["Stue","Køkken","Toilet","Køkken","Bad","Gang","Gang","Køkken","Køkken","sm-rum","pool rum"];

		var onOffData = new OnOffData(Date.fromString("2013-10-21 10:15:00"),Date.fromString("2013-10-21 10:45:00"));
		var onOffData2 = new OnOffData(Date.fromString("2013-10-21 12:15:00"),Date.fromString("2013-10-21 16:46:00"));
		
		var OnOffDataArray = [onOffData,onOffData2];

		var data = [OnOffDataArray,OnOffDataArray,OnOffDataArray,OnOffDataArray,OnOffDataArray,OnOffDataArray,OnOffDataArray,OnOffDataArray,OnOffDataArray,OnOffDataArray,OnOffDataArray];

		for(i in 0...intData.length){

			outletData.push(new Outlet(i,idData[i],catData[i],OnOffDataArray,roomData[i],wattData[i]));
			
		}		

		return outletData;

	}
	
	//Request todays usage, passing a callback to receive the data.
	public function requestUsageToday(f:Map<Int, Array<{time:Date, watts:Float}> > -> Void) {
		var houseId = Config.instance.houseId;
		var usageToday:Map<Int, Array<{time:Date, watts:Float}> > = null;
		mCnx.Api.getOutletHistoryAllToday.call([houseId, Date.now()], function(x:Dynamic){
			usageToday = x;
			f(usageToday);
		});
	}
	
	
	//This is only called once on app startup, so it is in sync.
	private function getHouseDescriptor() : HouseDescriptor {
	
		var houseId = Config.instance.houseId;
		var hD:HouseDescriptor = null;
	
		var done=false;
		mCnx.Api.getHouseDescriptor.call([houseId], 
			function(v:Dynamic) {
				hD = v;
				done=true;
		});
		while(done==false)
			Sys.sleep(0.1);
			
		return hD;
	}
	
	
	public function getOnOffData():Array<Outlet> {
	
		/*
		var houseId=42;
		var hD:HouseDescriptor = houseDescriptor;
		
		var usageToday:Map<Int, Array<{time:Date, watts:Float}> > = getUsageToday();
		
		var onOffMap = new Map<Int, Array<OnOffData> >();
		var start:Date=null;
		var stop:Date=null;
		for(key in usageToday.keys()) {

			onOffMap.set(key, new Array<OnOffData>());
			start = null;
			stop = null;
			
			for(u in usageToday.get(key)) {
				
				if(u.watts>0) {
					if(start==null)
						start = Date.fromTime(u.time.getTime() - (15*60*1000));
					stop = u.time;
				}
				else {	
					if(start!=null && stop!=null) {
						onOffMap.get(key).push(new OnOffData(start, stop));
						start = null;
						stop = null;
					}
				}
								
			}
			
			if(start!=null && stop!=null) { //End of data, so close the block if open.
				onOffMap.get(key).push(new OnOffData(start, stop));
			}

		}	
			

		var result = new Array<Outlet>();
		for(room in hD.getRoomArray()) {
			for(outlet in room.getOutletsArray()) {
				result.push(new Outlet(0, Std.string(outlet.outletId), outlet.name, 

							onOffMap.get(outlet.outletId), room.roomName, 0,room.roomColor,
							outlet.outletColor));

			}
		}
		
	
		return result;
		*/
		return getOnOffData_OLD();
	
	}
	
	
	public function requestOnOffData(callback:Array<Outlet>->Void) {
		var houseId=Config.instance.houseId;
		var hD:HouseDescriptor = houseDescriptor; //Get the stored house data.
		
		var usageToday:Map<Int, Array<{time:Date, watts:Float}> >;
		requestUsageToday(function(ut:Map<Int, Array<{time:Date, watts:Float}>>) { //Request usage, then proceed when data is received.
			usageToday = ut;
			var onOffMap = new Map<Int, Array<OnOffData> >();
			var start:Date=null;
			var stop:Date=null;
			for(key in usageToday.keys()) {

				onOffMap.set(key, new Array<OnOffData>());
				start = null;
				stop = null;
			
				for(u in usageToday.get(key)) {
				
					if(u.watts>0) {
						if(start==null)
							start = Date.fromTime(u.time.getTime() - (15*60*1000));
						stop = u.time;
					}
					else {	
						if(start!=null && stop!=null) {
							onOffMap.get(key).push(new OnOffData(start, stop));
							start = null;
							stop = null;
						}
					}
								
				}
			
				if(start!=null && stop!=null) { //End of data, so close the block if open.
					onOffMap.get(key).push(new OnOffData(start, stop));
				}

			}	
			

			var result = new Array<Outlet>();
			for(room in hD.getRoomArray()) {
				for(outlet in room.getOutletsArray()) {
					result.push(new Outlet(0, Std.string(outlet.outletId), outlet.name, 
									onOffMap.get(outlet.outletId), room.roomName, 0,
									room.roomColor, outlet.outletColor));
				}
			}
			
		
			callback(result); //Return the result in the callback.
		});
		
	}
	
	//Returns data for the ArealScreen for todays usage.
	//The callback: function(outletIds:Array<Int>, usage:Map<outletId, Array<Float>>, color:Map<outletId, Int>) : Void
	public function requestArealDataToday(callback:Array<Int> -> Map<Int, Array<Float>> -> Map<Int, Int> -> Void) {
		
		var rvIds = new Array<Int>();
		var rvUsage = new Map<Int, Array<Float>>();
		var rvColors = new Map<Int, Int>();
		
		var usage = new Array<Float>();
		
		var histData : Map<Int, Array<{time:Date, watts:Float}> >;
		mCnx.Api.getOutletHistoryAllToday.call([Config.instance.houseId, Date.now()], function(d:Dynamic){ 
			histData = d;
			for(key in histData.keys()) {
				rvIds.push(key);
				for(u in histData.get(key)) {
					usage.push(u.watts);
				}
				rvUsage.set(key, usage);
				usage = new Array<Float>(); //Clear.
				rvColors.set(key, houseDescriptor.getOutlet(key).outletColor);
			}
			callback(rvIds, rvUsage, rvColors);
		});		
		
	}


	
	public function getOutletLastDayTotal(outletId:Int) : Float {
		/*
			var value:Float = 0;
			value = Std.random(201);
			return value;
		*/
		
		var value:Float = 0;
		var s:Float = 0;
		value = Std.random(50) + 1;
		s = Std.random(1);
		
		if(s > 0 && s < 0.25) {
			value *= 1;
		} else if(s >= 0.25 && s < 0.50) {
			value *= 2;
		} else if(s >= 0.50 && s < 0.75) {
			value *= 3;
		} else {
			value *= 4;
		}
			
		return value;
	}
	
	public function getOutletLastWeekTotal(outletId:Int) : Float {
		/*
			var value:Float = 0;
			value = Std.random(201);
			return value;
		*/
		
		var value:Float = 0;
		var s:Float = 0;
		value = Std.random(50) + 1;
		s = Std.random(1);
		
		if(s > 0 && s < 0.25) {
			value *= 1;
		} else if(s >= 0.25 && s < 0.50) {
			value *= 2;
		} else if(s >= 0.50 && s < 0.75) {
			value *= 3;
		} else {
			value *= 4;
		}
			
		return value;
	}

	public function getOutletLastMonthTotal(outletId:Int) : Float {
		/*
			var value:Float = 0;
			value = Std.random(201);
			return value;
		*/
		
		var value:Float = 0;
		var s:Float = 0;
		value = Std.random(50) + 1;
		s = Std.random(1);
		
		if(s > 0 && s < 0.25) {
			value *= 1;
		} else if(s >= 0.25 && s < 0.50) {
			value *= 2;
		} else if(s >= 0.50 && s < 0.75) {
			value *= 3;
		} else {
			value *= 4;
		}
			
		return value;
	}

}


