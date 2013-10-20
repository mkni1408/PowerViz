
import BoxModel;

interface Instruction {

	public function execute(time:Date) : Void;

}


class LoadInstruction implements Instruction {

	public var outletId(default, null):Int;
	public var set(default,null):Int; //If set is defined, set will be used. Otherwise add is used.
	public var add(default,null):Int;
	public var comment(default, null):String;

	public function new(_outletId:Int, ?_add:Int, ?_set:Int, ?_comment:String) {
		outletId = _outletId;
		set = _set==null ? -1 : _set;
		add = _add==null ? 0 : _add;
		comment = _comment==null ? "" : _comment;
	}
	
	public function execute(time:Date) {
	
		var outlet = BoxModel.instance.getOutlet(outletId);
		if(outlet==null)
			return;
	
		if(set>=0) {
			outlet.load = set;
			Sys.println(Std.string(time) + ": Setting outlet " + outlet.outletId + " to " + set + " watts.");
		}
		else {
			outlet.load += add;
			Sys.println(Std.string(time) + ": On outlet " + outlet.outletId + (add<0 ? " subtracting " + Std.string(-add) : " adding " + add) + " watts. Total: " + outlet.load);
		}
	}
	
}

class SupplyInstruction implements Instruction{

	public function new() {
		trace("Not yet implemented");
	}
	
	public function execute(time:Date){}

}


