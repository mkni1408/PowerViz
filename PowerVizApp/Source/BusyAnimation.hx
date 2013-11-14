package;

import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;

import FontSupply;

class BusyAnimation extends Sprite {

	public static var instance(get,null) : BusyAnimation = null;
	static function get_instance() : BusyAnimation {
		if(instance==null)
			instance = new BusyAnimation();
		return instance;
	}
	
	private var mTextField : TextField;
	
	private function new() {
		super();
		draw();
		setText();
	}
	
	private function draw() {
		this.graphics.beginFill(0xFF00FF, 0);
		this.graphics.drawRect(0,0, 100,100);
		this.graphics.endFill();
		this.x = (Lib.current.stage.stageWidth-this.width) / 2;
		this.y = (Lib.current.stage.stageHeight-this.height) / 2;
	}
	
	private function setText() {
		mTextField = new TextField();
		mTextField.defaultTextFormat = FontSupply.instance.getTitleFormat();
		mTextField.text = "Indlæser...  ";
		mTextField.width = mTextField.textWidth;
		this.addChild(mTextField);
	}
	
	//Call this when an operation that takes time will start.
	public function busy() {
		this.visible = true;
	}
	
	//Call this when a long operation ends.
	public function done() {
		this.visible = false;
	}

}
