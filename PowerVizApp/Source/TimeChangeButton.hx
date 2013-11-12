package;

import flash.display.Sprite;
import flash.text.TextField;
import Button;


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
	
	private var mButtons : Array<Button>;
	private var currentButton :Int;


	/*
	Constructor. Takes an array of integers, where each integer represents a time interval as defined in the Time class.
	Example:
	new TimeChangeButton([Time.HOUR, Time.YEAR])	
	*/
	public function new(times:Array<Int>,currentButtonId:Int, f:Int->Void) {
		super();
		//so we know which button is currently active
		currentButton = currentButtonId;

		mButtons = new Array<Button>();
		var but:Button;

		
		for(t in times) {
			but = createSingleButton(Time.NAMES[t], Time.COLORS[t],t, f);
			mButtons.push(but);
			this.addChild(but);
		}
		//set the current button as transparent
		changeButtonState(currentButtonId);
		
		positionElements();
	}
	
	
	private function positionElements() {
		var x:Float = 0;
		for(b in mButtons) {
			b.x = x;
			x += b.width+10;
		}
	}
	
	private function createSingleButton(name:String, color:Int, time:Int ,f:Int->Void) : Button {
		
		//trace(time);
		 var mButton = new Button(name,color,time,f);

		return mButton;
	}
	//control if the button is visible - should be grayed out
	public function changeButtonState(newButtonID:Int){

		for(button in mButtons){

			if(button.mButtonID == newButtonID){
				button.chageState(true);
			}
			else{
				button.chageState(false);
			}
		}



	}

}



