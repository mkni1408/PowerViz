
import haxe.remoting.HttpAsyncConnection;

import flash.utils.Timer;
import flash.events.TimerEvent;

import Outlet;
import OnOffData;
import Config;

typedef TimeWatts = {time:Date, watts:Float}


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
	
	//Timers:
	private var mTimerNow : Timer; //Timer used to get the "now" usage data. 
	private var mTimerQuarter : Timer; //Timer used to get data every 15 minutes.
	private var mTimerHour : Timer; //Timer to get data every hour.
	private var mTimerDay : Timer; //Timer to get data once a day.
	
	//Layout data:
	public var houseDescriptor(default,null) : HouseDescriptor; //All data describing the house and its outlets.
	
	//Usage data now:
	private var mOutletDataNow : Map<Int, Float>; //Usage now for each outlet, measured in watts.
	private var mOutletDataNowTotal : Float; //Total usage data now for all outlets, measured in watts.
	private var mRelativeUsageNow : Float; //Relative usage. From 0.0 to 1.0.
	
	//Usage data quarter:
	private var mOutletDataQuarter : Map<Int, Float>; //Usage data for the last 15 minutes, for each outlet, measured in watts/15min.
	private var mOutletDataQuarterTotal : Float; //Total usage for last outlets in the last 15 minutes.
	
	//Usage data hour:
	private var mOutletDataHour : Map<Int, Float>; //Total usage for each outlet in the last hour.
	private var mOutletDataHourTotal : Float; //Total usage for all outlets in the last hour.
	private var mOutletDataHourTimed : Map<Int, Array<TimeWatts> >; //Usage for the last hour, timed in 15 minute intervals.
	
	//Usage data day:
	private var mOutletDataDay : Map<Int, Float>; //Total usage for each outlet this day.
	private var mOutletDataDayTotal : Float; //Total usage for all outlets this day.
	private var mOutletDataDayTimed : Map<Int, Array<TimeWatts> >; //Usage for today, timed in 15 minute intervals.
	
	//Usage data week:
	private var mOutletDataWeek : Map<Int, Float>; //Total usage for each outlet this week.
	private var mOutletDataWeekTotal : Float; //Total usage for all outlets this week.
	private var mOutletDataWeekTimed : Map<Int, Array<TimeWatts> >; //Usage for this week, timed in 15 minute intervals.


	
	public function new() {
		#if production
			this.connect("http://78.47.92.222/pvs/"); //Connect to production version.
		#else
			this.connect("http://78.47.92.222/pvsdev/"); //Connect to development version.
		#end 
		getDataOnCreation();
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
	
	//**************************************************
	// Functions for fetching the data from the server:
	//**************************************************
	
	//Initialize the timers that will get data from the server.
	private function initTimers() {
	
		mTimerNow = new Timer(3*1000); //Every 3 secs.
		mTimerNow.addEventListener(TimerEvent.TIMER, onTimerNow);
		mTimerNow.start();
	
		mTimerQuarter = new Timer(15*60*1000); //Every 15 minutes.
		mTimerQuarter.addEventListener(TimerEvent.TIMER, onTimerQuarter);
		mTimerQuarter.start();
		
		mTimerHour = new Timer(60*60*1000); //Every hour.
		mTimerHour.addEventListener(TimerEvent.TIMER, onTimerHour);
		mTimerHour.start();
		
		mTimerDay = new Timer(24*60*60*1000); //Once a day.
		mTimerDay.addEventListener(TimerEvent.TIMER, onTimerDay);
		mTimerDay.start();
	}
	
	//Get data to start with.
	private function getDataOnCreation() {
		houseDescriptor = getHouseDescriptor(); //Get the house layout.
	}
	
	
	private function onTimerNow(event:Dynamic) : Void {	
		//TODO: Get total relative consumption right now.
		
		mCnx.Api.getCurrentLoadAll.call([Config.instance.houseId], onGetCurrentLoadAll);
	}
	
	
	private function onTimerQuarter(event:Dynamic) : Void {
		mCnx.Api.getOutletHistoryLastQuarter.call([Config.instance.houseId], onGetOutletHistoryLastQuarter);
	}
	
	private function onTimerHour(event:Dynamic) : Void {
		mCnx.Api.getOutletHistoryAllHour.call([Config.instance.houseId], onGetOutletHistoryAllHour);
	}
	
	private function onTimerDay(event:Dynamic) : Void {
	}
	
	
	//****************************************************
	// Functions that gets the data, then stores it inside this class. Private functions only.
	//****************************************************
	
	private function onGetCurrentLoadAll(data:Dynamic) : Void {
		mOutletDataNow = data;
		mOutletDataNowTotal = 0;
		for(w in mOutletDataNow)
			mOutletDataNowTotal += w;
	}
	
	private function onGetOutletHistoryLastQuarter(data:Dynamic) : Void {
		mOutletDataQuarter = data;
		mOutletDataQuarterTotal = 0;
		for(w in mOutletDataQuarter)
			mOutletDataQuarterTotal += w;
	}
	
	private function onGetOutletHistoryAllHour(data:Dynamic) : Void {
		mOutletDataHourTimed = data;
		
		var count=0; //Counts number of measurements on the outlet.
		var watts:Float=0;
		mOutletDataHour = new Map<Int, Float>();
		for(key in mOutletDataHourTimed.keys()) {
			mOutletDataHour.set(key,0);
			count = 0;
			watts = 0;
			for(tw in mOutletDataHourTimed.get(key)) {
				watts += tw.watts;
				count += 1;
			}
			watts /= count;
			mOutletDataHour.set(key, watts);
		}
		
		mOutletDataHourTotal = 0;
		for(w in mOutletDataHour)
			mOutletDataHourTotal += w;
	}
	
	private function onGetOutletHistoryAllDay(data:Dynamic) : Void {
		mOutletDataDayTimed = data;
		
		var count=0; //Counts number of measurements on the outlet.
		var watts:Float=0;
		mOutletDataDay = new Map<Int, Float>();
		for(key in mOutletDataDayTimed.keys()) {
			mOutletDataDay.set(key,0);
			count = 0;
			watts = 0;
			for(tw in mOutletDataDayTimed.get(key)) {
				watts += tw.watts;
				count += 1;
			}
			watts /= count;
			mOutletDataDay.set(key, watts);
		}
		
		mOutletDataDayTotal = 0;
		for(w in mOutletDataDay)
			mOutletDataDayTotal += w;
	}
	
	//************************************************
	// Functions for delivering the supplied data: (These are the functions that the screens should use).
	//************************************************

	
	/**Returns the current total load in watts.**/
	public function getTotalCurrentLoad() : Float {
		return mOutletDataNowTotal;
	}
	
	/**Returns the current load in watts on a specific switch.**/
	public function getCurrentLoadOutlet(outletId:Int) {
		var w:Null<Float> = mOutletDataNow.get(outletId);
		return w == null ? 0 : w;
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
		var houseId=Config.instance.houseId;;
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
			trace(usageToday);
			for(key in usageToday.keys()) {

				onOffMap.set(key, new Array<OnOffData>());
				start = null;
				stop = null;
			
				for(u in usageToday.get(key)) {
				
					if(u.watts>0) {
						if(start==null) {
							start = u.time; //Date.fromTime(u.time.getTime() - (15*60*1000));
						}
						stop = u.time;
					}
					else {	
						if(start!=null && stop!=null) {
							if(stop.getDate()!=start.getDate())
								stop = new Date(start.getFullYear(), start.getMonth(), start.getDate(), 23, 45, 0);
							if(stop.getTime() == start.getTime())
								stop = DateTools.delta(start, DateTools.minutes(15));
							onOffMap.get(key).push(new OnOffData(start, stop));
							start = null;
							stop = null;
						}
					}
								
				}
			
				if(start!=null && stop!=null) { //End of data, so close the block if open.
					if(stop.getDate()!=start.getDate())
						stop = new Date(start.getFullYear(), start.getMonth(), start.getDate(), 23, 45, 0);
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
			
			trace(result);
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


	//returns the total wh from a device in the last hour
	public function getOutletLastHourTotal(outletId:Int) : Float {
		
		
		
		return 1000.0;
	}
	//returns the total wh from a device in the last day
	public function getOutletLastDayTotal(outletId:Int) : Float {
	
		
		
			
		return 1000.0;
	}
	//returns the total wh from a device in the last week
	public function getOutletLastWeekTotal(outletId:Int) : Float {
		
		
		
		return 1000.0;
	}

}


