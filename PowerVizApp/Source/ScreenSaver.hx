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
		bitmap.width = HWUtils.screenWidth;
		bitmap.height = HWUtils.screenHeight;
		addChild (bitmap);



	}
	//supposed to show the Sprite from dimmed state
	public function brighten(){

	}


	//supposed to dim the Sprite from brightened state
	public function dim(){

	}


}