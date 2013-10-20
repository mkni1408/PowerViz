
/** 
Structure for containing outlet layout data.
The format used when sending data from the zense PC-box to the PowerVizServer.
**/
class LayoutData {
	public var outletId:String;
	public var name:String;
	public var room:String;
	public var floor:String;
	
	public function new(?_id:String, ?_name:String, ?_room:String, ?_floor:String) {
		outletId = _id==null ? "0" : _id;
		name = _name==null ? "" : _name;
		room = _room==null ? "" : _room;
		floor = _floor==null ? "" : _floor;
	}
	
	public function toString() : String {
		return "outletId: " + outletId + " - name: " + name + " - room: " + room + " - floor: " + floor;
	}
}
