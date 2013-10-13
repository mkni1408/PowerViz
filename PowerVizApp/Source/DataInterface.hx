
import haxe.remoting.HttpAsyncConnection;

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

class DataInterface {

	static private var __instance : DataInterface = null;
	public static var instance(get, never) : DataInterface;
	static function get_instance() : DataInterface {
		if(__instance == null)
			__instance = new DataInterface();
		return __instance;
	}
	
	private var mCnx : HttpAsyncConnection; //Remoting connection used for communicating with the server. 
	
	public function new() {
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
	
	//Returns the servers current timestamp.
	public function fetchTimestamp(callback:Float->Void) {
		var f = function(v:Dynamic) {callback(v);};
		mCnx.Api.getTimestamp.call([], f);
	}
	
	//Returns the current time as a Date. Usefull for running stuff in server time.
	public function fetchCurrentTime(callback:Date->Void) {
		var f = function(v:Dynamic) {
			callback(Date.fromTime(v));
		};
		mCnx.Api.getTimestamp.call([], f);
	}
	
	/** Fetches all outlet names. 
	Result is returned to the supplied callback function, which must be of the form function (Map<Int, String>) : Void {} **/
	public function fetchOutletNames(houseId:Int, callback:Map<Int, String>->Void) {
		var func = function (v:Dynamic) {callback(v);};
		mCnx.Api.getOutletNameMap.call([houseId], func);
	}
	
	/**
	Fetches the total use on a specified outlet in the last 'timeSpan' milliseconds.
	Callback is of the form function (Float) : Void {}
	**/
	public function fetchOutletTotal(houseId:Int, outletId:Int, timeSpan:Float, callback:Float->Void) {
		var f = function(v:Dynamic) {
			callback(v);
		};
		mCnx.Api.getOutletTotal.call([houseId, outletId, timeSpan], f);
	}
	
	
	/*Gets all data. Should only be called on app startup.
	Basically forces the server to send all data on the specified house.*/
	public function fetchAll(houseId:Int) {
	}
	
	/*Returns true if the data has changed, otherwise false.
	If an outlet ids array is passed, then there is only checked for changes on the specified outlets.
	To check on a single outlet, just do DataInterface.instance.dataChange(myHouseId, [myOutlet]); 
	If just a single outlet has changed, it will return true.
	*/
	public function dataChanged(houseId:Int, ?outletIds:Array<Int>) : Bool {
		return true;
	}

	
	/*Returns the current total load in watts.*/
	public function getTotalCurrentLoad(houseId:Int) : Float {
		return Math.random(); //A random number.
	}
	
	/*Returns the current load in watts on a specific switch.*/
	public function getCurrentLoadOutlet(houseId:Int, outletId:Int) {
	
		var values = [122, 89, 56, 245, 189,111, 78, 411, 211];
		return values[outletId];
	}
	
	/*Returns an array of all switch in the house.*/
	public function getAllOutlets(houseId:Int) : Array<Int> {
		return [0,1,2,3,4,5,6,7,8];
	}
	
	/*Returns all names for all outlets.*/
	public function getAllOutletNames(houseId:Int) : Array<String> {
		return ["TV1", "TV2", "PS3", "XBox", "Kogekande", "Fryser", "MedieCenter Stuen", "Massagestol", "Løbebånd"];
	}
		
	/*Returns a specific outlet name, based on the outlet ID.*/
	public function getOutletName(houseId:Int, outletId:Int) : String{
		return getAllOutletNames(houseId)[outletId];
	}
	
	/*
	Returns an array of 96 floats, representing the useage data from the last 24 hours,
	based on HouseID and outletId.
	*/
	public function getOutletLastDayUsage(houseId:Int, outletId:Int) : Array<Float> {
		
		
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
	
	/*
	//Removed by popular demand.
	public function getOutletLastDayTotal(houseId:Int, outletId:Int) : Float {
	
		var total:Float=0;
		var values = getOutletLastDayUsage(houseId, outletId);
		for(v in values) {
			total += v;
		}
		total *= (24/values.length);
		return total;
	}
	*/
	
	public function getOutletColor(houseId:Int, outletId:Int) : Int {
		var colors = [0x005B96, 0x6497B1, 0xB1DAFB, 0x741d0d, 0xc72a00, 0xff7f24, 0x669900, 0x7acf00, 0xc5e26d];
		return colors[outletId];
	}
	
	public function getOutletLastDayTotal(houseId:Int, outletId:Int) : Float {
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


