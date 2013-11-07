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

	
	private var mEnergySource : Sprite;
	
	public function new(){

		super();
		
		var bitMapEnergySource = new Bitmap (Assets.getBitmapData ("assets/energy_source.png"));
		mEnergySource = new Sprite();
		mEnergySource.addChild (bitMapEnergySource);
		centerGraphics(mEnergySource, bitMapEnergySource);
		
		drawFrame();
		
		this.addChild(mEnergySource);
		
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

	/*
	public function changePowerOrigin():Void{
		
		//var powerOrigin = DataInterface.instance.method();
		
		//pull powerorigin and change which sprite is visible
		//if(powerOrigin == "wind") {
		//	changeOrigin(true,false,false,false);
		//} else if(powerOrigin == "coal") {
		//	changeOrigin(false,true,false,false);
		//} else if(powerOrigin == "solar") {
		//	changeOrigin(false,false,true,false);
		//} else if(powerOrigin == "nuclear") {
		//	changeOrigin(false,false,false,true);
		//}
		
		
		
		var changenumber = Std.random(4);

		//pull powerorigin and change which sprite is visible
		if(changenumber == 0) {
			changeOrigin(true,false,false,false);
		} else if(changenumber == 1) {
			changeOrigin(false,true,false,false);
		} else if(changenumber == 2) {
			changeOrigin(false,false,true,false);
		} else if(changenumber == 3) {
			changeOrigin(false,false,false,true);
		}
	}

	private function changeOrigin(first:Bool,second:Bool,third:Bool,fourth:Bool):Void{

		if(first){
			Actuate.tween (mPowerOriginCoal, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginSolar, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginNuclear, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginWind, 2, { alpha: 1 } );
		} else if(second) {
			Actuate.tween (mPowerOriginWind, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginSolar, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginNuclear, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginCoal, 2, { alpha: 1 } );
		} else if(third) {
			Actuate.tween (mPowerOriginWind, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginCoal, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginNuclear, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginSolar, 2, { alpha: 1 } );
		} else {
			Actuate.tween (mPowerOriginWind, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginCoal, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginSolar, 2, { alpha: 0 } );
			Actuate.tween (mPowerOriginNuclear, 2, { alpha: 1 } );
		}
	}
	*/
	
	//draws the frame around the Sprite
	private function drawFrame():Void{
		graphics.lineStyle(4,0x000000);
		graphics.drawRect(Lib.stage.stageWidth/2, 0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);
	}

}
