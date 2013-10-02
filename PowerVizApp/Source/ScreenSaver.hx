import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import openfl.Assets;

import flash.events.MouseEvent;

/*
A screensaver:
Usage: we create a screemsaver that lies on top of the swipemill
*/


class ScreenSaver extends Sprite
{

	public function new() {
		super();

		var bitmap = new Bitmap (Assets.getBitmapData ("assets/bulb.png"));
		bitmap.width = HWUtils.screenWidth;
		bitmap.height = HWUtils.screenHeight;
		this.addChild (bitmap);
		//registerEvents();

	}
	//supposed to show the Sprite from dimmed state
	public function brighten(){

	}


	//supposed to dim the Sprite from brightened state
	public function dim(){

	}
	
	/*
	private function registerEvents() {
	
	
		#if desktop
			this.addEventListener(MouseEvent.MOUSE_DOWN, someMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_UP, someMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_MOVE, someMouseEvent);
			this.addEventListener(MouseEvent.MOUSE_OUT, someMouseEvent);
		#end
	
	}
	
	private function someMouseEvent(event:MouseEvent) {
		trace("event: " + event);
	}
	*/


}
