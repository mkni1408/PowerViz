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
	
	public function new(){

		super();
		
		mFrame = createAndPositionFrame();
		this.addChild(mFrame);
		
		drawFrame();
		
		var bitMapEnergySource = new Bitmap (Assets.getBitmapData ("assets/energy_source.png"));
		mEnergySource = new Sprite();
		mEnergySource.addChild (bitMapEnergySource);
		//centerGraphics(mEnergySource, bitMapEnergySource);
		
		
		mFrame.addChild(mEnergySource);
		
		mSliderBar = createSliderBar();
		mFrame.addChild(mSliderBar);
		
		mUsagePointer = createUsagePointer();
		mFrame.addChild(mUsagePointer);
		
		mEnergySource.visible = true;
		
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
		ret.graphics.beginFill(0x0000FF);
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
		rv.graphics.beginGradientFill(flash.display.GradientType.LINEAR, [0x00FF00, 0xFF0000], [0,1], [0,100]);
		rv.graphics.drawRect(0,0, 200,20);
		rv.graphics.endFill();
		return rv;
	}

}
