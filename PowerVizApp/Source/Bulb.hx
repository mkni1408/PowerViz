package;

/*

Bulb object, that defines a bulb

*/

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import openfl.Assets;

class Bulb extends Sprite
{

	private var displayObjects:Array<DisplayObject>;

	private var mBulbOn : Sprite;
	private var mBulbOff : Sprite;

	private var mOn : Bool;

	public function new()
	{

		super ();
		

		displayObjects = new Array<DisplayObject>();

		//Container = new DisplayObjectContainer ();
		var bitMapBulboff = new Bitmap (Assets.getBitmapData ("assets/bulboff.png"));
		var bitMapBulbon = new Bitmap (Assets.getBitmapData ("assets/bulbon.png"));

		mBulbOn = new Sprite();
		mBulbOff = new Sprite();

		

		mBulbOn.addChild (bitMapBulbon);

		mBulbOff.addChild (bitMapBulboff);

		//sets the size of the bulbs
		mBulbOn.width /= 3;
		mBulbOn.height /= 3;
		mBulbOff.width /= 3;
		mBulbOff.height /= 3;

		displayObjects.push(mBulbOn);

		displayObjects.push(mBulbOff);

		
		bulb_drawline();

		this.addChild(mBulbOn);
		this.addChild(mBulbOff);

		mOn = false;
		


		//this.addEventListener (MouseEvent.MOUSE_DOWN, bulb_onMouseDown);
		
	}

	private function bulb_drawline()
	{

		graphics.lineStyle(4,0x000000);

		graphics.moveTo(mBulbOn.width/2,0);
		graphics.lineTo(mBulbOn.width/2,-500);
	}



	//Testfunction: when we click the bulb it should either turn on or off
	private function bulb_onMouseDown (event:MouseEvent):Void {

		mOn = !mOn;
		trace(mOn);
		if(mOn){
 			
 			mBulbOn.visible = true;
 			mBulbOff.visible = false;


		}
		else
		{
			mBulbOn.visible = false;
 			mBulbOff.visible = true;
		}
		

		trace("Mouseeven has been registered!!");

	}
	//the bulb should turn on=true or off=false, we just set the sprite to visible or invisible
	public function bulb_changeState(onoff:Bool):Void{
		
 			if(onoff)
 			{
 			mBulbOn.visible = true;
 			mBulbOff.visible = false;
			}
			else
			{
			mBulbOn.visible = false;
 			mBulbOff.visible = true;

			}

	}
	
}