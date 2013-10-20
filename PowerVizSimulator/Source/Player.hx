
import SimTimer;
import Instruction;

class Player {

	public static var instance(get,null):Player;
	static function get_instance() : Player {	
		if(instance==null)
			instance = new Player();
		return instance;
	}
	
	private var mBlocks:Array<Timeblock>;
	
	public function new() {
		mBlocks = new Array<Timeblock>();
	}
	
	
	public function addTimeblock(block:Timeblock) {
		mBlocks.push(block);
	}
	
	public function run(startTime:Date, speed:Float) {
	}

}


class Timeblock {

	private var mTimer:SimTimer;
	
	private var mInstructions:Array<Instruction>;
	
	private var mComment:String;

	public function new(_time:Float, _offset:Float, _repeats:Int, _until:Float, ?_comment:String) {
		mTimer = new SimTimer(_time, _offset, _repeats, onTimer, _until);
		mInstructions = new Array<Instruction>();
		mComment = _comment!=null ? _comment : "";
	}
	
	public function addInstruction(inst:Instruction) {
		mInstructions.push(inst);
	}
	
	//Invoked on timer.
	private function onTimer(count:Int, time:Date) : Void {
		Sys.println(mComment);
		for(inst in mInstructions) {
			inst.execute(time);
		}
	}

}
