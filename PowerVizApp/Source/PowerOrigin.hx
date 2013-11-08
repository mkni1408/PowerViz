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
	
	private static inline var mSliderFromColor:Int = 0x00FF00;
	private static inline var mSliderToColor:Int = 0xFF0000;
	private static inline var mSliderPointerColor:Int = 0x0000FF;
	
	public function new(){

		super();
		
		mFrame = createAndPositionFrame();
		this.addChild(mFrame);
		
		drawFrame();
		
		mSliderBar = createSliderBar();
		mFrame.addChild(mSliderBar);
		
		mUsagePointer = createUsagePointer();
		mFrame.addChild(mUsagePointer);
		
		positionElements();
		
		positionPointerOnSlider(0.5);
		
	}
	
	private function positionElements() {
		mSliderBar.width = mFrame.width / 2;
		mSliderBar.height = mFrame.height / 10;
		mSliderBar.x = (mFrame.width-mSliderBar.width)/2;
		mSliderBar.y = (mFrame.height-mSliderBar.height)/2;
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
		graphics.lineStyle(4,0x000000);
		graphics.drawRect(Lib.stage.stageWidth/2, 0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);
	}
	
	//Returns a triangleular usage pointer.
	private function createUsagePointer() : Sprite {
		var ret = new Sprite();
		ret.graphics.beginFill(mSliderPointerColor);
		ret.graphics.moveTo(0,0);
		ret.graphics.lineTo(20, 20);
		ret.graphics.lineTo(-20,20);
		ret.graphics.lineTo(0,0);
		ret.graphics.endFill();
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
		
		rv.graphics.beginGradientFill(flash.display.GradientType.LINEAR, [mSliderFromColor, mSliderToColor], [1,1], [0,255], matrix);
		rv.graphics.drawRect(0,0, 200,20);
		rv.graphics.endFill();
		return rv;
	}
	
	//Places the triangle slider thing on the slider bar. 
	//Value should be 0-1.
	private function positionPointerOnSlider(value:Float) {
		mUsagePointer.y = (mSliderBar.y + mSliderBar.height) - (mUsagePointer.height/3);
		mUsagePointer.x = mSliderBar.x + (mSliderBar.width*value);
	}

}
