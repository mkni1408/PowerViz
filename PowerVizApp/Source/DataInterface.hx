package;

import haxe.remoting.HttpAsyncConnection;
import motion.Actuate;

import Outlet;
import OnOffData;
import Config;

import PowerTimer;

//The mutex stuff:
#if neko
	import neko.vm.Mutex;
#elseif cpp
	import cpp.vm.Mutex;
#end

typedef TimeWatts = {time:Date, watts:Float}
typedef ArealDataStruct = {outletIds:Array<Int>, watts:Map<Int, Array<Float>>, colors:Map<Int,Int>}

enum PowerSource {
        Coal;
        Wind;
        Water;
        Sun;
        Nuclear;
}

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
        private var mUrl : String;
        
        private var mConnectionMutex:Mutex;
        
        //Timers:
        private var mTimerNow : PowerTimer; //Timer used to get the "now" usage data. 
        private var mTimerQuarter : PowerTimer; //Timer used to get data every 15 minutes.
        private var mTimerHour : PowerTimer; //Timer to get data every hour.
        private var mTimerDay : PowerTimer; //Timer to get data once a day.
        private var mTimerWeek : PowerTimer;
        
        //Layout data:
        public var houseDescriptor(default,null) : HouseDescriptor; //All data describing the house and its outlets.
        public var currentPowerSource(default,null):PowerSource; //The current power source. See the enum above.
        
        //Usage data now:
        private var mOutletDataNow : Map<Int, Float>; //Usage now for each outlet, measured in watts.
        private var mOutletDataNowTotal : Float = 0; //Total usage data now for all outlets, measured in watts.
        private var mRelativeUsageNow : Float = 0; //Relative usage. From 0.0 to 1.0.
        private var mRelativeMax : Float = 0; //Max usage value, used for calculating the relative value. Set using the speedometer.
        
        //Usage data quarter:
        private var mOutletDataQuarter : Map<Int, Float>; //Usage data for the last 15 minutes, for each outlet, measured in watts/15min.
        private var mOutletDataQuarterTotal : Float = 0; //Total usage for last outlets in the last 15 minutes.
        
        //Usage data hour:
        private var mOutletDataHour : Map<Int, Float>; //Total usage for each outlet in the last hour.
        private var mOutletDataHourTotal : Float = 0; //Total usage for all outlets in the last hour.
        private var mOutletDataHourTimed : Map<Int, Array<TimeWatts> >; //Usage for the last hour, timed in 15 minute intervals.
        
        //Usage data day:
        private var mOutletDataDay : Map<Int, Float>; //Total usage for each outlet this day.
        private var mOutletDataDayTotal : Float = 0; //Total usage for all outlets this day.
        private var mOutletDataDayTimed : Map<Int, Array<TimeWatts> >; //Usage for today, timed in 15 minute intervals.
        
        //Usage data week:
        private var mOutletDataWeek : Map<Int, Float>; //Total usage for each outlet this week.
        private var mOutletDataWeekTotal : Float = 0; //Total usage for all outlets this week.
        private var mOutletDataWeekTimed : Map<Int, Array<TimeWatts> >; //Usage for this week, timed in 15 minute intervals.


		//Operation timer: Used for doing operations that have failed once, but should be attempted again:
		
        
        private function new() {
        
            #if production
                    mUrl = "http://78.47.92.222/pvs/"; //Connect to production version.
            #else
                    mUrl = "http://78.47.92.222/pvsdev/"; //Connect to development version.
            #end 
            connect();
            constructUsageDataContainers();
            getDataOnCreation();
            initTimers();
        }
        
        
        private function constructUsageDataContainers() {

            mOutletDataNow = new Map<Int, Float>(); //Usage now for each outlet, measured in watts.

            //Usage data quarter= new 
            mOutletDataQuarter = new  Map<Int, Float>(); //Usage data for the last 15 minutes, for each outlet, measured in watts/15min.

            //Usage data hour= new 
            mOutletDataHour = new  Map<Int, Float>(); //Total usage for each outlet in the last hour.
            mOutletDataHourTimed = new  Map<Int, Array<TimeWatts> >(); //Usage for the last hour, timed in 15 minute intervals.

            //Usage data day= new 
            mOutletDataDay = new  Map<Int, Float>(); //Total usage for each outlet this day.
            mOutletDataDayTimed = new  Map<Int, Array<TimeWatts> >(); //Usage for today, timed in 15 minute intervals.

            //Usage data week= new 
            mOutletDataWeek = new  Map<Int, Float>(); //Total usage for each outlet this week.
            mOutletDataWeekTimed = new  Map<Int, Array<TimeWatts> >(); //Usage for this week, timed in 15 minute intervals.
             
        }
        
        
        //Connects to the server, setting up the remoting system.
        public function connect()  {
            mCnx = HttpAsyncConnection.urlConnect(mUrl);
            mCnx.setErrorHandler(onError);
            mConnectionMutex = new Mutex();
        }
        
        //Called when a connection or server error occurs.
        private function onError(e:String) {
            Sys.println("Connection error: " + e);
        }
       
        
        //**************************************************
        // Functions for fetching the data from the server:
        //**************************************************
        
        //Initialize the timers that will get data from the server.
        private function initTimers() {

            var nowInterval = 3*1000;
            var quarterInterval = 15*60*1000;
            #if demo
                trace("RUNNING TIMERS IN DEMOMODE!");
                quarterInterval = 60*1000;
            #end
            var hourInterval = quarterInterval*4;
            var dayInterval = hourInterval * 24;
            var weekInterval = dayInterval * 7;

            mTimerNow = new PowerTimer(nowInterval); //Every 3 secs.
            mTimerNow.onTime = onTimerNow;
            mTimerNow.start();

            mTimerQuarter = new PowerTimer(quarterInterval); //Every 15 minutes.
            mTimerQuarter.onTime = onTimerQuarter;
            mTimerQuarter.start();

            mTimerHour = new PowerTimer(quarterInterval); //Every hour.
            mTimerHour.onTime = onTimerHour;
            mTimerHour.start();

            mTimerDay = new PowerTimer(quarterInterval); //Once a day.
            mTimerDay.onTime = onTimerDay;
            mTimerDay.start();

            mTimerWeek = new PowerTimer(quarterInterval); //Once a week.
            mTimerWeek.onTime = onTimerWeek;
            mTimerWeek.start();
        }
        
        //Get data to start with.
        private function getDataOnCreation() {

            houseDescriptor = getHouseDescriptor(); //Get the house layout.

            //Call the timers to get data to start with:
            onTimerNow();
            onTimerQuarter();
            onTimerHour();
            onTimerDay();
            onTimerWeek();
        }
        
        
        private function onTimerNow() : Void {  
        	mConnectionMutex.acquire();
        	mCnx.Api.getCurrentLoadAll.call([Config.instance.houseId], onGetCurrentLoadAll);
        }
        
        
        private function onTimerQuarter() : Void {
            
            	mConnectionMutex.acquire();
                mCnx.Api.getOutletHistoryLastQuarter.call([Config.instance.houseId], onGetOutletHistoryLastQuarter);
                //mCnx.Api.getRelativeMax.call([Config.instance.houseId], onGetRelativeMax);
                mConnectionMutex.acquire();
                mCnx.Api.getMaxWattsSetting.call([Config.instance.houseId], onGetMaxWatts);
        }
        
        private function onTimerHour() : Void {
                
                mConnectionMutex.acquire();
                mCnx.Api.getOutletHistoryAllHour.call([Config.instance.houseId], onGetOutletHistoryAllHour);
        }
        
        private function onTimerDay() : Void {
        		
        		mConnectionMutex.acquire();
                mCnx.Api.getOutletHistoryAllToday.call([Config.instance.houseId], onGetOutletHistoryAllDay);
        }
        
        private function onTimerWeek() : Void {
        
				mConnectionMutex.acquire();
                mCnx.Api.getOutletHistoryThreeDays.call([Config.instance.houseId], onGetOutletHistoryAllWeek);
        }
        
        
        //****************************************************
        // Functions that gets the data, then stores it inside this class. Private functions only.
        //****************************************************
        
        private function onGetCurrentLoadAll(data:Dynamic) : Void {
                
                mOutletDataNow = data;
                mOutletDataNowTotal = 0;
                for(w in mOutletDataNow)
                        mOutletDataNowTotal += w;
                        
                mRelativeUsageNow = mOutletDataNowTotal / mRelativeMax;
                if(mRelativeUsageNow>1) {
                        mRelativeUsageNow=1;
                }
                else if(mRelativeUsageNow<0) {
                        mRelativeUsageNow = 0;
                }
                mConnectionMutex.release();
        }
        
        private function onGetOutletHistoryLastQuarter(data:Dynamic) : Void {
            
                mOutletDataQuarter = data;

                mOutletDataQuarterTotal = 0;
                for(w in mOutletDataQuarter)
                        mOutletDataQuarterTotal += w;
                    
                mConnectionMutex.release();
        }
        
        private function onGetOutletHistoryAllHour(data:Dynamic) : Void {

                onGetOutletHistory(data, "hour");
                mConnectionMutex.release();
        }
        
        private function onGetOutletHistoryAllDay(data:Dynamic) : Void {
                
                onGetOutletHistory(data, "day");
                mConnectionMutex.release();
        }
        
        private function onGetOutletHistoryAllWeek(data:Dynamic) : Void {
                onGetOutletHistory(data, "week");
                mConnectionMutex.release();
        }
        
        private function onGetOutletHistory(data:Dynamic, timespan:String) {
        
        		//trace("onGetOutletHistoryData (" + Std.string(Date.now())+"): " + timespan);
                
                var dest:Map<Int, Array<TimeWatts>> = data;
                var accumOutlet:Map<Int, Float>;
                var accum:Float=0;
                
                var count=0; //Counts number of measurements on the outlet.
                var watts:Float=0;
                accumOutlet = new Map<Int, Float>();
                for(key in dest.keys()) {
                        accumOutlet.set(key,0);
                        count = 0;
                        watts = 0;
                        for(tw in dest.get(key)) {
                                watts += tw.watts;
                                count += 1;
                        }
                        
                        watts /= 4; //From watt quarter to watt hour.
                        accumOutlet.set(key, watts);
                }
                
                if(timespan == "hour")
                	//trace("Data: " + dest);
                
                accum = 0;
                for(w in accumOutlet)
                        accum += w;
                        
                switch(timespan) {
                        case "hour":
                                mOutletDataHourTimed = dest;
                                mOutletDataHour = accumOutlet;
                                mOutletDataHourTotal = accum;
                        case "day":
                                mOutletDataDayTimed = dest;
                                mOutletDataDay = accumOutlet;
                                mOutletDataDayTotal = accum;
                        case "week":
                                mOutletDataWeekTimed = dest;
                                mOutletDataWeek = accumOutlet;
                                mOutletDataWeekTotal = accum;
                        default: 
                                return;
                }

        }
        
        private function onGetRelativeMax(data:Dynamic) : Void {
                mRelativeMax = data;
                mConnectionMutex.release();
        }
        
        private function onGetMaxWatts(data:Dynamic) : Void {
        	mRelativeMax = data;
        	mConnectionMutex.release();
        }
        
        //Function for filling in missing dates in a specified dataset:
        public function fillInMissingData(_from:Date, _to:Date, dataSet:Map<Int, Array<TimeWatts> >) {
        	var from:Date = _from;
        	var timeIndex:Date = _from;
        	var arrayIndex:Int=0;
        	for(key in dataSet.keys()) {
        		arrayIndex = 0;
        		timeIndex = from;
        		for(tw in dataSet.get(key)) {
        		
        			if(timeIndex.getTime() >= _to.getTime()) //Out of time range.
        				break; //Break this loop, going to next key.
        				
        			if(timeIndex.getTime() == tw.time.getTime()) { //Data on time as expected.
        				//Do nothing. Data is OK.
        			}
        			else if(timeIndex.getTime() < tw.time.getTime()) { //Data ahead of expected time.
                        while(timeIndex.getTime() < tw.time.getTime()) {
                            dataSet.get(key).insert(arrayIndex, {time:timeIndex, watts:0});
                            arrayIndex += 1;
                        }
        			}   
                    
                    timeIndex = DateTools.delta(timeIndex, DateTools.minutes(15)); //Advance 15 minutes.
                    arrayIndex += 1;     			
        		}
        	}
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
        
        //Returns ON/OFF data for today.
        public function getOnOffData():Array<Outlet> {
        
                var houseId=Config.instance.houseId;
                
                //var usageToday:Map<Int, Array<{time:Date, watts:Float}> > = getUsageToday();
                var usageToday = new Map<Int, Array<TimeWatts> >();

                usageToday = mOutletDataDayTimed;
                
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
                        else { //Watts<=0
                            if(start!=null && stop!=null) {
                                onOffMap.get(key).push(new OnOffData(start, stop));
                                start = null;
                                stop = null;
                                /*
                                    if(stop.getDate()!=start.getDate())
                                            stop = new Date(start.getFullYear(), start.getMonth(), start.getDate(), 23, 45, 0);
                                    if(stop.getTime() == start.getTime())
                                            stop = DateTools.delta(start, DateTools.minutes(15));
                                    onOffMap.get(key).push(new OnOffData(start, stop));
                                    start = null;
                                    stop = null;
                                */
                            }
                        }
                                                        
	                }
                        
                    if(start!=null && stop!=null) { //End of data, so close the block if open.
                            //if(stop.getDate()!=start.getDate())
                            //        stop = new Date(start.getFullYear(), start.getMonth(), start.getDate(), 23, 45, 0);
                            onOffMap.get(key).push(new OnOffData(start, stop));
                    }

                }        
                        

                var result = new Array<Outlet>();
                for(room in houseDescriptor.getRoomArray()) {
                    for(outlet in room.getOutletsArray()) {
                        result.push(new Outlet(0, Std.string(outlet.outletId), outlet.name, 
		                                            onOffMap.get(outlet.outletId), room.roomName, 0,
		                                            room.roomColor, outlet.outletColor));
                    }
                }
                //trace("Usage today:",result);
                return result;
        }
        
        /*
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
        */

        //Returns the daily usage data for the ArealScreen diagram.
        public function getArealUsageToday() : ArealDataStruct {
                return getArealUsage("day");
        }
        
        public function getArealUsageHour() : ArealDataStruct {
                
                return getArealUsage("hour");
        }
        
        public function getArealUsageWeek() : ArealDataStruct {
                return getArealUsage("week");
        }
        
        private function getArealUsage(timespan:String) : ArealDataStruct {
        
                var r:ArealDataStruct = {outletIds:new Array<Int>(), watts:new Map<Int, Array<Float>>(), colors:new Map<Int,Int>()};
                
                var rvIds = new Array<Int>();
                var rvUsage = new Map<Int, Array<Float>>();
                var rvColors = new Map<Int, Int>();
                var readingArray = new Array<TimeWatts>();
                var numberofDates = 96;
                
                var usage = new Array<Float>();
                
                var source:Map<Int, Array<TimeWatts>>;
                switch(timespan) {
                        case "hour":
                                source = mOutletDataHourTimed;
                                numberofDates = 4;
                        case "day":
                                source = mOutletDataDayTimed;
                                numberofDates = 96;

                        case "week":
                                source = mOutletDataWeekTimed;
                                numberofDates = 288;
                        default:
                                return null;
                }


                trace(source);
                var dateArray = createTimeArray(numberofDates);

                for(key in source.keys()) {        

                        rvIds.push(key);


                        for(date in dateArray){

                            var found = false;
                            source.get(key).reverse();

                            for(reading in source.get(key)) {
                                //trace("comparing ",reading.time,"and",date);
                                if(Std.string(reading.time) == Std.string(date)){ //date was found
                                usage.push(reading.watts);
                            
                                found = true;
                                }
                                        
                            }

                            if(!found){//we did not find anything
                            
                            usage.push(0.0);
                            }
                    


                        }

                                
                                rvUsage.set(key, usage);
                                usage = new Array<Float>();
                                rvColors.set(key, houseDescriptor.getOutlet(key).outletColor);
                }

                

                
                return {outletIds:rvIds, watts:rvUsage, colors:rvColors};
                
        }


        //returns the total wh from a device in the last hour
        public function getOutletLastHourTotal(outletId:Int) : Float {
                var u = mOutletDataHour.get(outletId);
                return u==null ? 0 : u;
        }
        
        //returns the total wh from a device in the last day
        public function getOutletLastDayTotal(outletId:Int) : Float {
                var u = mOutletDataDay.get(outletId);
                return u==null ? 0 : u;
        }
        
        //returns the total wh from a device in the last week
        public function getOutletLastWeekTotal(outletId:Int) : Float {
                var u = mOutletDataWeek.get(outletId);
                return u==null ? 0 : u;
        }
        
        //Returns the current powersource.
        private function powerSourceStringToEnum(str:String) : PowerSource {
        
            switch(str.toLowerCase()) {
                case "coal":
                        return PowerSource.Coal;
                case "wind":
                        return PowerSource.Wind;
                case "water":
                        return PowerSource.Water;
                case "sun":
                        return PowerSource.Sun;
                case "nuclear":
                        return PowerSource.Nuclear;
                default:
                        return PowerSource.Coal;
            }
        }
        
        public function relativeUsage() : Float {
                return mRelativeUsageNow; 
        }
        
        public function setMaxWatts(max:Float) {
        	this.mCnx.Api.setMaxWattsSetting.call([Config.instance.houseId, Std.int(max)], function(r:Dynamic){});
        	mRelativeMax = max;
        }
        
        public function relativeMax() : Float {
        	trace(mRelativeMax);
        	return mRelativeMax;
        }

        public function createTimeArray(numberoffields:Int):Array<Date>{

            var dateNow = Date.now();
            var hour = dateNow.getHours();
            var minute = dateNow.getMinutes();
            var year = dateNow.getFullYear();
            var month = dateNow.getMonth();
            var date = dateNow.getDate();
            var tempArray = new Array<Date>();


            if(minute >= 0 && minute < 15){
                  minute = 0;      
                                                    
            }
            else if(minute >= 15 && minute < 30){
                            minute = 15; 
                                                    
            }
            else if(minute >= 30 && minute < 45){
                         minute = 30;    
            }
            else if(minute >= 45 && minute < 59){
                        minute = 45; 
            }

            var newDate = new Date(year,month,date,hour,minute,00);//initial date

            


            for(i in 0...numberoffields)//create an array of dates back in time
            {
                tempArray.push(newDate);
                newDate = DateTools.delta(newDate,-DateTools.minutes(15));

            }

            tempArray.reverse();

            trace(tempArray);
            return tempArray;

        }

}
