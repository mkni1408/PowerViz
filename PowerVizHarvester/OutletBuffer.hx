package;

import haxe.remoting.HttpAsyncConnection;


import DateUtil;
import Harvester;
import BufferedData;


/**
The OutletBuffer.
Buffers data for a single outlet.
Each X minutes (read from the Configuration) the buffer sends usage data (LoadHistory) to the server.
**/
class OutletBuffer {

	private static var mSqlite:sys.db.Connection;

	private var mCnx:HttpAsyncConnection;
	private var mInterval:Int;

	private var mHouseId:Int;
	private var mOutletId:Int;

	/*	
	private var mLastUpdate:Date;	
	private var mWattAccum:Float; //Accumulated watts.
	private var mTimeAccum:Int; //Accumulated time (in Date.getTime() format).
	*/
	
	public function new(houseId:Int, outletId:Int, cnx:HttpAsyncConnection, interval:Int) {
		//mWattAccum = 0;
		//mTimeAccum = 0;
		//mLastUpdate = Harvester.instance.getServerTime();
		mHouseId = houseId;
		mOutletId = outletId;
		mCnx = cnx;
		mInterval = interval;
	}
	
	public static function initSQLite() {
		mSqlite = sys.db.Sqlite.open("DataBuffer.db");
		sys.db.Manager.cnx = mSqlite;
		sys.db.Manager.initialize();
		if(!sys.db.TableCreate.exists(BufferedData.manager)) {
			sys.db.TableCreate.create(BufferedData.manager);
		}
	}
	
	//Updates the buffer. Should be called every time data is received from the box.
	public function update(now:Date, load:Float) {
		
		var delta:Float = 0; //= now.getTime() - mLastUpdate.getTime();
		var lastUpdate:Date;
		
		//Get the data from the SQLite database:
		var dbe = BufferedData.manager.select($houseId == mHouseId && $outletId == mOutletId);
		if(dbe != null) {
			lastUpdate = Date.fromString(Std.string(dbe.lastUpdate)); //This is to make sure that the data is correctly handled as a Date.
			delta = now.getTime() - lastUpdate.getTime(); 
			dbe.timeAccum += Std.int(delta); //Add time delta.
			dbe.wattAccum += load * delta; //Accumulate the watts.
			
			if(DateUtil.isInSameInterval(lastUpdate, now, mInterval)==false) { //It is time to send history data.
				sendHistoryData(mCnx, dbe.wattAccum/dbe.timeAccum, DateUtil.intervalStart(now, mInterval));
				dbe.timeAccum = 0;
				dbe.wattAccum = 0;
			}
			
			dbe.lastUpdate = now;
			dbe.update();
		}
		else {
			dbe = new BufferedData();
			dbe.houseId = mHouseId;
			dbe.outletId = mOutletId;
			dbe.timeAccum = 0;
			dbe.wattAccum = 0;
			dbe.lastUpdate = now;
			dbe.insert();
		}
		
	}
	
	
	//Sends the data to the server.
	private function sendHistoryData(cnx:HttpAsyncConnection, load:Float, sendTime:Date) {	
		var f = function(v:Dynamic) {};
		cnx.Api.addOutletHistory.call([mHouseId, mOutletId, sendTime, load], f);
	}

}



