

/**
Custom made simulation timer. Runs without threads, so it should be safe.
**/
class SimTimer {

	private static var mTimers:Array<SimTimer> = new Array<SimTimer>();
	
	public static var startDate(default, default) : Date; //Use this to set the start date.

	private static var mLastTick:Float = -1;
	private static var mSpeed:Float = 1.0; //Multiply. 
	
	private static var mCurTime:Float = 0; //Currently "measured" time. Has been multiplied with mSpeed.
	private static var mPrevTime:Float = 0; //Previous "measured" time on update.
	
	//Updates all timers.
	public static function update(?_speed:Float) {
	
		mSpeed = _speed!=null ? _speed : mSpeed;
		
		if(mLastTick<0)
			mLastTick = Sys.time();
	
		var curTick = Sys.time();
		var delta = (curTick - mLastTick)*mSpeed;
		mLastTick = curTick;
		mPrevTime = mCurTime;
		mCurTime += delta;
		
		for(t in mTimers) {
			t._update(delta, mCurTime, mPrevTime, startDate);
		}
	}
	
	private static function addTimer(t:SimTimer) {
		mTimers.push(t);
	}	
	
	//-------------------------------------------------
	
	private var mTime:Float; //Time between repeats.
	private var mOffset:Float; //Offset before the first repeat/invokation.
	private var mRepeats:Int; //Max invokations. 0 is infinite.
	private var mRepeatTimer:Float; //Counts time between repeats.
	private var mUntil:Float; //If >0, this timer will stop when mUntil is reached.
	
	private var mCount:Int; //Number of invokations.
	
	public var done(default,null):Bool; //True when the timer has stopped.
	
	private var mCallback:Int->Date->Void=null; //Callback. Takes the repeat. 0 for the first invokation.
	
	public function new(_time:Float, _offset:Float, _repeats:Int, _callback:Int->Date->Void, ?_until:Float) {
		
		mTime = _time;
		mOffset = _offset;
		mRepeats = _repeats;
		mRepeatTimer = 0 - mOffset;
		mUntil = _until==null ? -1 : _until;
		mCount=0;
		mCallback = _callback;
		done = false;
		SimTimer.addTimer(this);
	}
	
	//Update the instance.
	private function _update(delta:Float, curTime:Float, prevTime:Float, startDate:Date) {	
	
		if(mUntil>0 && mUntil<=curTime) {
			done = true;
		}
		
		mRepeatTimer += delta;
		while(mRepeatTimer >= mTime && done==false) {
			mRepeatTimer -= mTime;
			invoke(Date.fromTime(startDate.getTime() + (curTime*1000)));
			mCount += 1;
		}
		if(mCount>=mRepeats && mRepeats>0)
			done = true;
	}
	
	
	private function invoke(date:Date) {
		if(mCallback!=null)
			mCallback(mCount, date);
	}
	
	

}
