package;

import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import openfl.Assets;
import motion.Actuate;
import PowerTimer;

/*
Defines the powerorigin interface. In short it just shifts between a few pictures
*/

class PowerOrigin extends Sprite{

	
	private var mFrame : Sprite; //Frame to contain all elements.
	private var mSliderBar : Sprite; 
	private var mEnergySource : Sprite; 
	private var mUsagePointer : Sprite;
	
	private var mGoodImage : Bitmap;
	private var mBadImage : Bitmap;
	
	private static inline var mSliderFromColor:Int = 0x00FF00;
	private static inline var mSliderMiddleColor:Int = 0x004000; //Color on the middle of the PowerSource bar.
	private static inline var mSliderToColor:Int = 0x000000;
	private static inline var mSliderPointerColor:Int = 0x0000FF;
	
	private var mTimer : PowerTimer;
	
	public function new(){

		super();
		
		mFrame = createAndPositionFrame();
		this.addChild(mFrame);
		
		mGoodImage = createImage("assets/energy_good.png");
		mFrame.addChild(mGoodImage);
		mBadImage = createImage("assets/energy_bad.png");
		mFrame.addChild(mBadImage);
		
		drawFrame();
		
		mSliderBar = createSliderBar();
		mFrame.addChild(mSliderBar);
		
		mUsagePointer = createUsagePointer();
		mFrame.addChild(mUsagePointer);
		
		positionElements();
		
		positionPointerOnSlider(0.5);
		
		/*
		mTimer = new PowerTimer(3000);
		mTimer.onTime = onTime;
		mTimer.start();
		*/
		DataInterface.instance.callbackNow.addCallback(onTime);
		
	}
	
	private function positionElements() {
		mSliderBar.width = mFrame.width / 2;
		mSliderBar.height = mFrame.height / 10;
		mSliderBar.x = (mFrame.width-mSliderBar.width)/2;
		mSliderBar.y = (mFrame.height-mSliderBar.height)/2;
		
		mGoodImage.width = mFrame.width / 6;
		mGoodImage.height = mGoodImage.width;
		
		mGoodImage.y = (mFrame.height-mGoodImage.height)/2;
		mGoodImage.x = mGoodImage.width / 2.5;
		
		mBadImage.width = mGoodImage.width;
		mBadImage.height = mGoodImage.height;
		mBadImage.y = mGoodImage.y;
		mBadImage.x = (mFrame.width - mBadImage.width) - mGoodImage.x; 
		
	}

	private function centerGraphics(origin:Sprite, bitmap:Bitmap){
	
		origin.width = Lib.stage.stageWidth/2;
		origin.height = Lib.stage.stageHeight/2;

		var centerBitmapX = origin.width/2;
		var centerBitmapY = origin.height/2;

		var centerSpriteX = (Lib.stage.stageWidth / 4)*3;
		var centerSpriteY = (Lib.stage.stageHeight / 4);

		origin.x = centerSpriteX - centerBitmapX;
		origin.y = centerSpriteY - centerBitmapY;
	}

	
	//draws the frame around the Sprite
	private function drawFrame():Void{
		//graphics.lineStyle(4,0x000000);
		//graphics.drawRect(Lib.stage.stageWidth/2, 0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);
	}
	
	//Returns a triangleular usage pointer.
	private function createUsagePointer() : Sprite {
		var ret = new Sprite();
		var bitmaparrow = new Bitmap (Assets.getBitmapData ("assets/originArrow.png"));
		bitmaparrow.width = 30;
		bitmaparrow.height = 40;
		ret.addChild(bitmaparrow);
		
		return ret;
	}
	
	private function createAndPositionFrame() : Sprite {
		var rv = new Sprite();
		rv.graphics.beginFill(0xFF00FF, 0); 
		rv.graphics.drawRect(0,0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);
		rv.x = Lib.stage.stageWidth / 2;
		rv.y = 0;
		return rv;
	}
	
	private function createSliderBar() : Sprite {
		var rv = new Sprite();
		
		var matrix = new flash.geom.Matrix();
		matrix.createGradientBox(200,20);
		
		rv.graphics.beginGradientFill(flash.display.GradientType.LINEAR, [mSliderFromColor, mSliderMiddleColor, mSliderToColor], [1,1,1], [0, 128, 255], matrix);
		rv.graphics.drawRect(0,0, 200,20);
		rv.graphics.endFill();
		return rv;
	}
	
	private function createImage(filename:String) : Bitmap {	
		var r = new Bitmap(openfl.Assets.getBitmapData(filename));
		r.smoothing = true;
		return r;
	}
	
	//Places the triangle slider thing on the slider bar. 
	//Value should be 0-1.
	private function positionPointerOnSlider(value:Float) {
		var y : Float = (mSliderBar.y + mSliderBar.height);
		var x : Float = mSliderBar.x + (mSliderBar.width*value);
		Actuate.tween(mUsagePointer, 1, {x:x, y:y});
	}
	
	private function onTime() {
		positionPointerOnSlider(DataInterface.instance.powerSourceBadness);
	}

}
