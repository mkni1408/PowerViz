package;

import flash.display.Sprite;

import motion.actuate.*;

import ColorUtils;
import DataSequenceDisplay;


class DataVBarDisplay extends DataSequenceDisplay {

	private var mLabels : Array<String>;
	private var mIcons : Array<Sprite>;
	private var mColorRanges : Array<{min:Int, max:Int}>;

	override public function update(data:Array<Float>) {
		//Replaces the existing data with new data, setting the new height of the bars using actuate.
	}
	
	public function setLabels(labels:Array<String>) {}
	public function setIcons(icons:Array<Sprite>) {}
	public function setColorRanges(ranges:Array<{min:Int, max:Int}>) {}
	public function setBarWidth(w:Float) {}
	public function setBarSpacing(s:Float) {}

}


