
/** 
Structure for containing outlet layout data.
The format used when sending data from the zense PC-box to the PowerVizServer.
**/
class LayoutData {
	public var outletId:String;
	public var name:String;
	public var room:String;
	public var floor:String;
	
	public function new() {}
	
	public function toString() : String {
		return "outletId: " + outletId + " - name: " + name + " - room: " + room + " - floor: " + floor;
	}
}
