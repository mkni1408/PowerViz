

import sys.db.Connection;
import sys.db.Types;
import sys.db.Object;

@:id(houseId)
class BoxConfig extends sys.db.Object {
	public var houseId : SInt;
	public var boxIP : SString<32>;
	public var boxID : SString<8>;
	public var boxPort : SInt;
	public var sleepTime : SInt;
	public var historyTime : SInt;
	public var maxWatts : SInt; //Maximum watts set inside the PowerViz app.
	public var bulbWatts : SInt; //Number of watts that a single bulb represents.
}

@:id(houseId, time, msg)
class BoxLog extends sys.db.Object {
	public var houseId : SInt;
	public var time : SDateTime;
	public var msg : SString<1024>;
}

@:id(houseId, outletId)
class CurrentLoad extends sys.db.Object {
	public var houseId : SInt;
	public var outletId : SInt;
	public var time : SDateTime;
	public var load : SFloat;
}


@:id(houseId, outletId, time)
class LoadHistory extends sys.db.Object {
	public var houseId : SInt;
	public var outletId : SInt;
	public var time : SDateTime;
	public var load : SFloat;
	
	override public function toString() {
		var str = "LoadHistory: {\n";
		str += "houseId: " + houseId + "\n";
		str += "outletId: " + outletId + "\n";
		str += "time: " + time + "\n";
		str += "load: " + load + "\n }";
		return str;
	}
}


@:id(houseId)
class DisplayLog extends sys.db.Object {
	public var houseId : SInt;
	public var time : SDateTime;
	public var tag : SString<256>;
	public var type : SString<32>;
	public var comments : SString<256>;
}

@:id(houseId, outletId)
class HouseOutlets extends sys.db.Object {
	public var houseId : SInt;
	public var outletId : SInt; //We use the zense outlet Id to avoid conversion between ids.
	public var outletName : SString<128>; 
	public var outletZenseName : SString<16>; //The name obtained from the PC-box.
	public var outletZenseRoom : SString<16>;
	public var outletZenseFloor : SString<16>;
	public var roomId : SInt;
	public var color : SString<8>;
}


@:id(houseId, roomId)
class HouseRooms extends sys.db.Object {
	public var houseId : SInt;
	public var roomId : SInt;
	public var roomName : SString<128>;
	public var roomColor : SString<8>;
}


@:id(time)
class PowerSource extends sys.db.Object {
	public var time : SDateTime; //Time of powersource change.
	//Following variables describe the amount of different power sources. Used for calculating a weight between "good" and "bad":
	public var wind : SFloat;
	public var water : SFloat;
	public var coal : SFloat;
	public var nuclear : SFloat;
	public var sun : SFloat;
}



