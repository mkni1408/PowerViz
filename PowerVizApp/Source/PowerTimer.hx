import flash.utils.Timer;
import flash.events.TimerEvent;


class PowerTimer {

	private var mTimer:Timer;

	public function new(millisecs:Int) {
		mTimer = new Timer(millisecs, 0);
		mTimer.addEventListener(TimerEvent.TIMER, onTimerEvent);
	}
	
	public function start() {
		mTimer.start();
	}
	
	public function stop() {
		mTimer.stop();
	}
	
	dynamic public function onTime() : Void {
		trace("onTime not implemented. DO THAT!");
	}
	
	private function onTimerEvent(event:TimerEvent) {
		onTime();
	}

}
