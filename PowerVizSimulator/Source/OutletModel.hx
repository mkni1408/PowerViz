
import DateUtil;

/**
Outlet model. Keeps track of the power usage, including
the history data.
**/
class OutletModel {

	public var outletId(default,null):Int;
	public var load(default,default):Int;
	
	public var name(default,null):String; //As obtained from the zense system
	public var room(default,null):String;
	public var floor(default,null):String;
	
	//History data:
	public var accumWatts(default,null):Float; //Number of watts used, accumulated in the current interval.
	public var accumTime(default,null):Float; //Time accumulated.
	public var lastHistorySend(default,null):Date; //Last time history data was sent to the server.
	private var lastUpdateTimestamp:Float; //Last time update() was called.

	public function new(_id:Int, _name:String, _room:String, _floor:String) {
		outletId = _id;
		name = _name;
		room = _room;
		floor = _floor;
		load = 0;
		accumWatts = 0;
		accumTime = 0;
		lastUpdateTimestamp=0;
	}
	
	//Updates the outlet. Should be called once each second.
	//The sendFunction(outletId:Int, time:Date, watts:Int) : Void should be called when
	//it is time to send history data to the server.
	public function update(now:Date, sendFunction:Int->Date->Int->Void, historyInterval) {
	
		if(lastHistorySend==null)
			lastHistorySend = now;
	
		var curTime = now.getTime();
		var delta = lastUpdateTimestamp==0 ? 0 : curTime - lastUpdateTimestamp;
		lastUpdateTimestamp = curTime;
		
		accumWatts += (load*delta);
		accumTime += delta;
		
		if(DateUtil.isInSameInterval(lastHistorySend, now, historyInterval)==false) {
			
			sendFunction(outletId, DateUtil.intervalEnd(lastHistorySend, historyInterval), Std.int(accumWatts/ accumTime ));
			lastHistorySend = now;
			
			accumWatts = 0;
			accumTime = 0;
		}
	
	}
	


}
