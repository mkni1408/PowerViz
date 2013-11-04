package;

import flash.display.Sprite;

//Base class for all classes that displays a sequence of data.
class DataSequenceDisplay {

	public function setMin(i:Float) {}
	public function setMax(i:Float) {}	
	
	public function setRange(min:Float, max:Float) {}
	
	public function update(array:Array<Float>) {} //Updates the display with new data.

}
