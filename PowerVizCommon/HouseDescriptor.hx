

/**
Simple descriptor class that contains all room and outlet descriptions of a house.
**/
class OutletDescriptor {

	public var houseId(default,default):Int; //Identifying the house that this outlet is installed in.
	public var outletId(default,default):Int; //The ID of the outlet.
	public var name(default,default):String; //Name of the outlet, as displayed on the screen.
	public var zenseName(default,default):Int; //Name from the zense box.
	public var zenseRoom(default,default):String; //Room name from the zense box.
	public var zenseFloor(default, default):String; //Floor name from the zense box.
	public var outletColor(default,default):Int; //Color, translated to OpenFL color format.

}


class RoomDescriptor {

	public var houseId(default,default):Int; //Identifying the house.
	public var roomId(default,default):Int; //ID of the room, which should match the outlets.
	public var color(default,default):Int; //Color of the room.
	
	private var mOutlets:Map<Int, OutletDescriptor>;
	
	public function new(?_houseId:Int, ?_roomId:Int) {
		houseId = _houseId!=null ? _houseId : -1;
		roomId = _roomId!=null ? _roomId : -1;
		mOutlets = new Map<Int, OutletDescriptor>();
	}
	
	public function addOutlet(outlet:OutletDescriptor) {
		mOutlets.set(outlet.outletId, outlet);
	}
	
	public function getOutlet(id:Int) : OutletDescriptor {
		return mOutlets.get(id);
	}
	
	public function getAllOutlets() : Array<OutletDescriptor> {	
		return Lambda.array(mOutlets);
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
			result.concat(r.getAllOutlets());
		}
		return result;
	}

}
