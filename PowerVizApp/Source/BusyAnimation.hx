import flash.display.Sprite;
import flash.Lib;

class BusyAnimation extends Sprite {

	public static var instance(get,null) : BusyAnimation = null;
	static function get_instance() : BusyAnimation {
		if(instance==null)
			instance = new BusyAnimation();
		return instance;
	}
	
	private function new() {
		super();
		draw();
	}
	
	private function draw() {
		this.graphics.beginFill(0xFF00FF);
		this.graphics.drawRect(0,0, 100,100);
		this.graphics.endFill();
		this.x = (Lib.stage.stageWidth-this.width) / 2;
		this.y = (Lib.stage.stageHeight-this.height) / 2;
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
