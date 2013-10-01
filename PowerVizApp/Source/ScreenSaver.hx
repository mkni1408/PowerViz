import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import openfl.Assets;
/*
A screensaver:
Usage: we create a screemsaver that lies on top of the swipemill
*/


class ScreenSaver extends Sprite
{

	public function new() {
		super();

		var bitmap = new Bitmap (Assets.getBitmapData ("assets/bulb.png"));
		addChild (bitmap);
		
		bitmap.x = (stage.stageWidth - bitmap.width) / 2;
		bitmap.y = (stage.stageHeight - bitmap.height) / 2;


	}
	//supposed to show the Sprite from dimmed state
	public function brighten(){

	}


	//supposed to dim the Sprite from brightened state
	public function dim(){

	}


}