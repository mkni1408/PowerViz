	import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import openfl.Assets;
import motion.Actuate;
import Std;
/*
Defines the powerorigin interface. In short it just shifts between a few pictures
*/

class PowerOrigin extends Sprite{
	
	private var mPowerOriginWind : Sprite;
	private var mPowerOriginCoal : Sprite;
	private var mPowerOriginSolar : Sprite;
	private var mPowerOriginNuclear : Sprite;
	private var mTimerSetting:Int = 10000;

	public function new(){

		super();
		
		var bitMapOriginWind = new Bitmap (Assets.getBitmapData ("assets/windmill.png"));
		var bitMapOriginCoal = new Bitmap (Assets.getBitmapData ("assets/coal.png"));
		var bitMapOriginSolar = new Bitmap (Assets.getBitmapData ("assets/solar.png"));
		var bitMapOriginNuclear = new Bitmap (Assets.getBitmapData ("assets/nuclear.png"));

		mPowerOriginWind = new Sprite();
		mPowerOriginCoal = new Sprite();
		mPowerOriginSolar = new Sprite();
		mPowerOriginNuclear = new Sprite();

		mPowerOriginWind.addChild (bitMapOriginWind);
		mPowerOriginCoal.addChild (bitMapOriginCoal);
		mPowerOriginSolar.addChild (bitMapOriginSolar);
		mPowerOriginNuclear.addChild (bitMapOriginNuclear);
		
		centerGraphics(mPowerOriginWind,bitMapOriginWind);
		centerGraphics(mPowerOriginCoal,bitMapOriginCoal);
		centerGraphics(mPowerOriginSolar, bitMapOriginSolar);
		centerGraphics(mPowerOriginNuclear, bitMapOriginNuclear);

		drawFrame();

		this.addChild(mPowerOriginWind);
		this.addChild(mPowerOriginCoal);
		this.addChild(mPowerOriginSolar);
		this.addChild(mPowerOriginNuclear);

		mPowerOriginWind.visible = true;
		mPowerOriginCoal.visible = false;
		mPowerOriginSolar.visible = false;
		mPowerOriginNuclear.visible = false;
		
		var yourPowerOrigin:haxe.Timer = new haxe.Timer(mTimerSetting);

		yourPowerOrigin.run = function():Void{
			trace("PowerOrigin timer running!!");
			changePowerOrigin();
		};	
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

	public function changePowerOrigin():Void{
		/*
		var powerOrigin = DataInterface.instance.method();
		
		//pull powerorigin and change which sprite is visible
		if(powerOrigin == "wind") {
			changeOrigin(true,false,false,false);
		} else if(powerOrigin == "coal") {
			changeOrigin(false,true,false,false);
		} else if(powerOrigin == "solar") {
			changeOrigin(false,false,true,false);
		} else if(powerOrigin == "nuclear") {
			changeOrigin(false,false,false,true);
		}
		*/
		
		
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
	
	//draws the frame around the Sprite
	private function drawFrame():Void{
		graphics.lineStyle(4,0x000000);
		graphics.drawRect(Lib.stage.stageWidth/2, 0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);
	}

}
