
import OutletModel;
import LayoutData;

class BoxModel {

	public static var instance(get,null):BoxModel;
	static function get_instance() : BoxModel {
		if(instance==null)
			instance = new BoxModel();
		return instance;
	}
	
	public var houseId(default, default):Int;
	private var mOutlets:Map<Int, OutletModel>;
	private var mOutletIds:Array<Int>;
	private var mCurOutletIndex:Int; //Index of the outlet from wich data is currently being requested.
	
	public function new() {
		mOutlets = new Map<Int, OutletModel>();
		mOutletIds = new Array<Int>();
		mCurOutletIndex=0;
	}
	
	
	public function addOutlet(outlet:OutletModel) {
		mOutlets.set(outlet.outletId, outlet);
		mOutletIds.push(outlet.outletId);
	}
	
	public function getOutlet(id:Int) : OutletModel {
		return mOutlets.get(id);
	}
	
	public function update(now:Date, sendLoadFunc:Int->Int->Void, sendHistFunc:Int->Date->Int->Void, historyInterval) {
	
		for(outlet in mOutlets) { //Call update() on all outlets, sending along the function for sending history data.
			outlet.update(now, sendHistFunc, historyInterval);
		}
	
		if(mOutletIds.length==0) //If no ids registered.
			return;
			
		if(mCurOutletIndex>=mOutletIds.length) { //If the index is out of range.
			mCurOutletIndex=0;
		}
	
		var curId = mOutletIds[mCurOutletIndex];
		sendLoadFunc(curId, mOutlets.get(curId).load); //Send the load function.
		
		mCurOutletIndex += 1; //Increment the index.
	
	}
	
	//Sends the layout data contained in this through the supplied sendFunc function.
	public function sendOutletLayout(sendFunc:Int->Array<LayoutData>->Void) {
		//Form the data into LayoutData format, then send it to the function:
		var layouts = new Array<LayoutData>();
		for(outlet in mOutlets) {
			layouts.push(new LayoutData(Std.string(outlet.outletId), outlet.name, outlet.room, outlet.floor));
		}	
		sendFunc(houseId, layouts);
	}

}


