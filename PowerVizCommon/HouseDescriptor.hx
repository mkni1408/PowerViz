package;

/**
Simple descriptor class that contains all room and outlet descriptions of a house.
**/
class OutletDescriptor {

	public var houseId(default,default):Int; //Identifying the house that this outlet is installed in.
	public var outletId(default,default):Int; //The ID of the outlet.
	public var name(get,set):String; //Name of the outlet, as displayed on the screen.
	var _name:String;
	public var zenseName(get,set):String; //Name from the zense box.
	var _zenseName:String;
	public var zenseRoom(get,set):String; //Room name from the zense box.
	var _zenseRoom:String;
	public var zenseFloor(get, set):String; //Floor name from the zense box.
	var _zenseFloor:String;
	public var outletColor(default,default):Int; //Color, translated to OpenFL color format.
	
	public function new(?_houseId:Int, ?_outletId:Int, ?_name:String, ?_zenseName:String, ?_zenseRoom:String, ?_zenseFloor:String, ?_color:String) {
		houseId = _houseId!=null ? _houseId : -1;
		outletId = _outletId!=null ? _outletId : -1;
		name = _name!=null ? _name : "";
		zenseName = _zenseName!=null ? _zenseName : "";
		zenseRoom = _zenseRoom!=null ? _zenseRoom : "";
		zenseFloor = _zenseFloor!=null ? _zenseFloor : "";
		var colorString = _color!=null ? _color : "0x000000";
		outletColor = Std.parseInt(colorString);
	}
	
	public function toString():String {
		var str = "houseId: " + houseId + "\n";
		str += "outletId: " + outletId + "\n";
		str += "outletName: " + name + "\n";
		str += "zenseName: " + zenseName + "\n";
		str += "zenseRoom: " + zenseRoom + "\n";
		str += "zenseFloor: " + zenseFloor + "\n";
		return str;
	}

	function get_zenseName() : String { return _zenseName;}
	function set_zenseName(n:String) : String { _zenseName = haxe.Utf8.encode(n); return _zenseName;}
	
	function get_zenseRoom() : String { return _zenseRoom;}
	function set_zenseRoom(n:String) : String { _zenseRoom = haxe.Utf8.encode(n); return _zenseRoom;}
	
	function get_zenseFloor() : String { return _zenseFloor;}
	function set_zenseFloor(n:String) : String { _zenseFloor = haxe.Utf8.encode(n); return _zenseFloor;}
	
	function get_name() : String { return _name; }
	function set_name(s:String) : String { _name = haxe.Utf8.encode(s); return _name;}

}


class RoomDescriptor {

	public var houseId(default,default):Int; //Identifying the house.
	public var roomId(default,default):Int; //ID of the room, which should match the outlets.
	public var roomName(get,set):String;
	var _roomName:String;
	
	public var roomColor(default,default):Int; //Color of the room.
	
	private var mOutlets:Map<Int, OutletDescriptor>;
	
	public function new(?_houseId:Int, ?_roomId:Int, ?_name:String, ?_color:String) {
		houseId = _houseId!=null ? _houseId : -1;
		roomId = _roomId!=null ? _roomId : -1;
		roomName = _name!=null ? _name : "Default";
		var colorString = _color!=null ? _color : "0xFFFFFF";
		roomColor =  Std.parseInt(colorString);
		mOutlets = new Map<Int, OutletDescriptor>();
	}
	
	function get_roomName() : String { return _roomName; }
	function set_roomName(s:String) : String { _roomName = haxe.Utf8.encode(s); return _roomName; }
	
	public function addOutlet(outlet:OutletDescriptor) {
		mOutlets.set(outlet.outletId, outlet);
	}
	
	public function getOutlet(id:Int) : OutletDescriptor {
		return mOutlets.get(id);
	}
	
	public function getOutletsArray() : Array<OutletDescriptor> {	
		return Lambda.array(mOutlets);
	}
	
	public function toString():String {
		var str="{ " + toShortString();
		str += "outlets: {\n";
		for(outlet in getOutletsArray()) {
			str += Std.string(outlet) + "\n";
		}
		str += "}";
		return str;
		
	}
	
	public function toShortString() : String {
		var str="houseId: " + houseId + "\n";
		str += "roomId: " + roomId + "\n";
		str += "roomName: " + roomName + "\n";
		str += "roomColor: " + roomColor + " (0x" + StringTools.hex(roomColor, 6) + ") \n";
		return str;
	}
	
}


class HouseDescriptor {

	public var houseId(default,default):Int;
	
	private var mRooms:Map<Int, RoomDescriptor>;
	
	public function new() {
		mRooms = new Map<Int, RoomDescriptor>();
	}
	
	public function addRoom(room:RoomDescriptor) {
		mRooms.set(room.roomId, room);
	}
	
	public function getRoom(id:Int) : RoomDescriptor {
		var r = mRooms.get(id);
		if(r==null)
			mRooms.set(id, new RoomDescriptor());
		return mRooms.get(id);
	}
	
	public function getRoomArray() : Array<RoomDescriptor> {
		return Lambda.array(mRooms);
	}
	
	public function getAllOutlets() : Array<OutletDescriptor> {
		var result = new Array<OutletDescriptor>();
		for(r in mRooms) {
			result = result.concat(r.getOutletsArray());
		}
		return result;
	}
	
	public function getOutlet(id:Int) : OutletDescriptor {
		var outlet:OutletDescriptor;
		for(r in mRooms) {
			outlet = r.getOutlet(id);
			if(outlet!=null)
				return outlet;
		}
		return null;
	}
	
	public function toString():String {
		var str = "houseId = " + houseId + "\n";
		str += "rooms: { \n";
		for(room in getRoomArray()){
			str += Std.string(room) + "\n";
		}
		str += "}";
		return str;
	}

}
