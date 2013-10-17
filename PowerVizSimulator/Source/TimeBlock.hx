
/**
The TimeBlock class.

A central part of the simulator is the TimeBlock.
The simulation script is divided into timeblocks that each contains a set of load instructions.

A TimeBlock can be run either once or repeatedly.

See the supplied simulation.xml file for a practical example of a simulation file.
**/
class TimeBlock {
	
	private var mRuns:Int = 0; //how many time it should be repeated. 0 = infinite, >0 limited times.
	private var mEvery:Float = -1; //When it should be repeated/invoked.
	private var mOffset:Float = 0; //The offset, how long time the first invokation should wait.
	private var mUntil:Float = -1;
	private var mRepeatTimer:Float = 0;
	
	private var mInstructions : Array<Instruction>;
	
	private var mMultiply:Float = 1.0;
	private var mCount:Int; //Counts number of times the timeblock was invoked.
	
	private var mDone:Bool;
	
	public function new(every:Float=1, runs:Int=1, offset:Float=0.0, until:Float=-1) {
		mRuns = runs; 
		mEvery = every; 
		mOffset = offset;
		mUntil = until;
		mInstructions = new Array<Instruction>();
		mCount = 0;
		TimeBlock.mTimeBlocks.push(this);
	}
	
	public function addInstruction(inst:Instruction) {
		mInstructions.push(inst);
	}
	
	private function doInstructions(?time:Date) {
		for(i in mInstructions) {
			i.execute(time);
		}
	}
	
	private function start() {
		mRepeatTimer = 0 - mOffset;
		mCount=0;
		mDone = false;
	}
	
	private function update(tick:Float, delta:Float, startTime:Date) {
		
		if(mUntil!=-1 && tick>=mUntil) {
			mDone = true;
			return;
		}
		
		if(mRuns>0 && mCount>=mRuns) {
			mDone = true;
			return;
		}
			
		//Repeats:
		mRepeatTimer += delta;
		if(mRepeatTimer>=mEvery) {
			mRepeatTimer -= mEvery;
			doInstructions(Date.fromTime(startTime.getTime() + (tick*1000)));
			mCount += 1;
		}
		
	}
	
	//-----------------------
	
	private static var mTimeBlocks:Array<TimeBlock> = new Array<TimeBlock>();
	
	private static var mLastRealTick:Float; //Real tick.
	private static var mTick:Float; //Multiplied tick.
	private static var mDelta:Float; //Multiplied delta;
	
	public static function startTimer() {
		mLastRealTick = Sys.time();
		mTick = 0;
		mDelta = 0;
		for(t in mTimeBlocks)
			t.start();
	}
	
	public static function updateTimer(multiply:Float=1.0, startTime:Date) {
		var curTick:Float = Sys.time();
		mDelta = (curTick - mLastRealTick) * multiply;
		mTick += mDelta;
		mLastRealTick = curTick;
		
		for(t in mTimeBlocks) {
			t.update(mTick, mDelta, startTime);
		}
	}
	
	public static function isDone() {	
		var done = true;
		for(t in mTimeBlocks) {
			if(t.mDone==false)
				done = false;
		}
		return done;
	}
	
	public static function parse(houseId:Int, data:Xml) : Bool {
		//Create a new timeblock, setting the values:
		
		var at = data.get("at");
		var every = data.get("every");
		var repeat = data.get("repeat");
		var offset = data.get("offset");
		var until = data.get("until");
		
		var _at:Float = (at==null ? -1 : Date.fromString(at).getTime()/1000);
		var _every:Float = (every==null ? -1 : Date.fromString(every).getTime()/1000);
		var _repeat:Int = (repeat==null ? 0 : Std.parseInt(repeat));
		var _offset:Float = (offset==null ? 0 : Date.fromString(offset).getTime()/1000);
		var _until:Float = (until==null ? -1 : Date.fromString(until).getTime()/1000);
		
		var block:TimeBlock;
		if(_at>-1) {
			block = new TimeBlock(_at, 1);
		} 
		else {
			block = new TimeBlock(_every, _repeat, _offset, _until);
		}
		
		var i:Instruction = null;
		var recognized:Bool = false;
		for(l in data) { //Go through each load in the timeblock.
			recognized = false;
			if(l.nodeType == Xml.Element && l.nodeName == "load") {
				i = LoadInstruction.parse(houseId, l); 
				recognized = true;
			}
			else if(l.nodeType == Xml.Element && l.nodeName == "supply") {
				i = SupplyInstruction.parse(houseId, l);
				recognized = true;
			}
			if(recognized==true && i==null)
				return false;
			if(recognized==true) {
				block.addInstruction(i);
				}
		}
		return true;
	}
	
}



