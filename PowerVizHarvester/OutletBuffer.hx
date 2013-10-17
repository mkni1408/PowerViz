
import haxe.remoting.HttpAsyncConnection;

/**
The OutletBuffer.
Buffers data for a single outlet.
Each X minutes (read from the Configuration) the buffer sends usage data (LoadHistory) to the server.
**/
class OutletBuffer {

	private var mCnx:HttpAsyncConnection;
	private var mInterval:Int;

	private var mHouseId:Int;
	private var mOutletId:Int;
	
	private var mLastUpdate:Date;	
	private var mWattAccum:Float; //Accumulated watts.
	private var mTimeAccum:Int; //Accumulated time (in Date.getTime() format).
	
	public function new(houseId:Int, outletId:Int, cnx:HttpAsyncConnection, interval:Int) {
		mWattAccum = 0;
		mTimeAccum = 0;
		mLastUpdate = Date.now();
		mHouseId = houseId;
		mOutletId = outletId;
		mCnx = cnx;
		mInterval = interval;
	}
	
	//Updates the buffer. Should be called every time data is received from the box.
	public function update(now:Date, load:Float) {
		
		var delta:Float = now.getTime() - mLastUpdate.getTime();
		mTimeAccum += Std.int(delta); //Add time delta.
		mWattAccum += load * delta;
		
		if(isInSameInterval(mLastUpdate, now, mInterval)==false) { //Time to send history data:
			sendHistoryData(mCnx, mWattAccum/mTimeAccum, intervalStart(now, mInterval));
			mTimeAccum = 0;
			mWattAccum = 0;
		}
		
		mLastUpdate = now;
	}
	
	//Returns true if the two time objects are in the same time interval.
	private function isInSameInterval(one:Date, two:Date, intervalMinutes:Int) {
		var from:Date = intervalStart(one, intervalMinutes);
		var to:Date =  Date.fromTime(from.getTime() + (intervalMinutes*60*1000));
		if(two.getTime()>= from.getTime() && two.getTime() < to.getTime())
			return true;
		return false;
	}
	
	//Returns the start of the interval that 'time' is in.
	private function intervalStart(time:Date, interval:Int) : Date {
		return new Date(time.getFullYear(), time.getMonth(), time.getDate(), time.getHours(), 
										Math.floor(time.getMinutes()/interval)*interval, 0);
	}
	
	//Sends the data to the server.
	private function sendHistoryData(cnx:HttpAsyncConnection, load:Float, sendTime:Date) {	
		var f = function(v:Dynamic) {};
		cnx.Api.addOutletHistory.call([mHouseId, mOutletId, sendTime, load], f);
	}

}
