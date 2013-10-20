
import haxe.remoting.HttpAsyncConnection;

import DateUtil;

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
		
		if(DateUtil.isInSameInterval(mLastUpdate, now, mInterval)==false) { //Time to send history data:
			sendHistoryData(mCnx, mWattAccum/mTimeAccum, DateUtil.intervalStart(now, mInterval));
			mTimeAccum = 0;
			mWattAccum = 0;
		}
		
		mLastUpdate = now;
	}
	
	
	//Sends the data to the server.
	private function sendHistoryData(cnx:HttpAsyncConnection, load:Float, sendTime:Date) {	
		var f = function(v:Dynamic) {};
		cnx.Api.addOutletHistory.call([mHouseId, mOutletId, sendTime, load], f);
	}

}
