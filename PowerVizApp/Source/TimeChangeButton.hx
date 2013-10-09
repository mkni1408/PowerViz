
import flash.display.Sprite;

/*
TimeChangeButton - component for displaying buttons that allows change in time layout on a screen.

Usage:
Look at the arguments in the constructor. They enable you to turn different buttons on and off.
To make a button set that displays day, week and month, call it like this:
var myButton = new TimeChangeButton(false, true, true, true, false, false) //day, wek, month.
To listen for an event:
myButton.onChangeWeek = myOnWeekChangeFunction;
*/

class Time {
	
	public static inline var HOUR:Int = 0;
	public static inline var DAY:Int = 1;
	public static inline var WEEK:Int = 2;
	public static inline var MONTH:Int = 3;
	public static inline var QUARTER:Int = 4;
	public static inline var YEAR:Int = 5;
	
	public static var NAMES:Array<String> = ["Time", "Dag", "Uge", "Måned", "Kvartal", "År"];
	public static var COLORS = [0xFF0000, 0x00FF00, 0x0000FF, 0x00FFFF, 0xFFFF00, 0x000000];

}

class TimeChangeButton extends Sprite {

	//Functions to replace by user when listening for change events.
	public dynamic function onChangeHour() {}
	public dynamic function onChangeDay() {}
	public dynamic function onChangeWeek() {}
	public dynamic function onChangeMonth() {}
	public dynamic function onChangeQuarter() {}
	public dynamic function onChangeYear() {}
	
	private var mButtons : Array<Sprite>;

	/*
	Constructor. Takes an array of integers, where each integer represents a time interval as defined in the Time class.
	Example:
	new TimeChangeButton([Time.HOUR, Time.YEAR])	
	*/
	public function new(times:Array<Int>) {
		super();
		
		mButtons = new Array<Sprite>();
		var but:Sprite;
		
		for(t in times) {
			but = createSingleButton(Time.NAMES[t], Time.COLORS[t]);
			mButtons.push(but);
			this.addChild(but);
		}
		
		positionElements();
	}
	
	
	private function positionElements() {
		var x:Float = 0;
		for(b in mButtons) {
			b.x = x;
			x += b.width;
		}
	}
	
	private function createSingleButton(name:String, color:Int) : Sprite {
		var s = new Sprite();
		s.graphics.beginFill(color);
		s.graphics.drawRect(0,0, 50,50);
		s.graphics.endFill();
		return s;
	}

}


