
import Instruction;
import DataInterface;

/**
LoadInstruction - instructs the server to set the load of a specific outlet.
**/
class LoadInstruction implements Instruction{

	private var mHouseId:Int;
	private var mOutletId:Int;
	
	private var mAdd:Float; //Add this many watts to the outlet load.
	private var mSet:Float; //Set the outlet to this many watts.
	
	private var mComment:String;

	/**Constructor for the instructction.
	HouseId is the ID of the house, as in the database.
	OutletId us the ID of the outlet in the specified house.
	add - the amount to add.
	set - the amount to set.
	If both add and set is not 0, then set will be used instead of add.**/
	public function new(houseId:Int, outletId:Int, add:Float, set:Float=0) {
		mHouseId = houseId;
		mOutletId = outletId;
		mAdd = add;
		mSet = set;
	}
	
	/**
	Executes the instruction on the server (yet not implemented).
	If the time argument is supplied, the server will register that time as the time of action,
	and the console will print the time.
	**/
	public function execute(?time:Date) {
	
		var timeString = (time!=null ? time.toString() : "??:??:??");
		//var timeString = (time!=null ? Date.fromTime(time*1000).toString() : "");

		if(mSet>0) {
			Sys.println("Setting outlet " + mOutletId + " to " + mSet + " (" + mComment + ")" + " at " + timeString);
			DataInterface.setLoad(mHouseId, mOutletId, mSet, time);
		}
		else{
			Sys.println("Adding " + mAdd + " to outlet " + mOutletId + " (" + mComment + ")" + " at " + timeString);
			DataInterface.addLoad(mHouseId, mOutletId, mAdd, time);
		}
	}
	
	public static function parse(houseId:Int, xml:Xml) : LoadInstruction {
		var outlet = xml.get("outlet");
		var add = xml.get("add");
		var sub = xml.get("sub");
		var set = xml.get("set");
		var comment = xml.get("comment");
		
		
		if(outlet==null) {
			Sys.println("Error in " + xml + " :: outlet not specified");
			return null;
		}
		
		var _outlet:Int = Std.parseInt(outlet);
		var _add:Float = (add==null ? 0 : Std.parseFloat(add));
		var _sub:Float = (sub==null ? 0 : Std.parseFloat(sub));
		var _set:Float = (set==null ? 0 : Std.parseFloat(set));
		
		var inst:LoadInstruction;
		if(set!=null) {
			inst = new LoadInstruction(houseId, _outlet, 0, _set);
		}
		else{
			if(add!=null){
				inst = new LoadInstruction(houseId, _outlet, _add, 0);
			}
			else {
				inst = new LoadInstruction(houseId, _outlet, -_sub, 0);
			}
		}
		inst.mComment = (comment==null ? "" : comment);
		return inst;
	}

}
