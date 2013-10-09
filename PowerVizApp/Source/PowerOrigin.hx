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
	
	private var mPowerOriginGreen : Sprite;
	private var mPowerOriginCoal: Sprite;
	private var mTimerSetting:Int = 10000;

	public function new(){

		super();

		
		var bitMapOriginGreen = new Bitmap (Assets.getBitmapData ("assets/windmill.png"));
		var bitMapOriginCoal = new Bitmap (Assets.getBitmapData ("assets/coal.png"));

		mPowerOriginGreen = new Sprite();
		mPowerOriginCoal = new Sprite();


		mPowerOriginGreen.addChild (bitMapOriginGreen);
		mPowerOriginCoal.addChild (bitMapOriginCoal);
		

		centerGraphics(mPowerOriginGreen,bitMapOriginGreen);
		centerGraphics(mPowerOriginCoal,bitMapOriginCoal);

		drawFrame();

		this.addChild(mPowerOriginGreen);
		this.addChild(mPowerOriginCoal);

		mPowerOriginGreen.visible = true;
		mPowerOriginCoal.visible = false;

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


		var changenumber = Std.random(2);

		//pull powerorigin and change which sprite is visible

		if(changenumber == 0)
		{

		changeOrigin(true,false);

		}
		else if(changenumber == 1)
		{
		changeOrigin(false,true);

		}
	}

	private function changeOrigin(first:Bool,second:Bool):Void{

		if(first){
		Actuate.tween (mPowerOriginCoal, 2, { alpha: 0 } );
		Actuate.tween (mPowerOriginGreen, 2, { alpha: 1 } );
		}
		else{
		Actuate.tween (mPowerOriginGreen, 2, { alpha: 0 } );
		Actuate.tween (mPowerOriginCoal, 2, { alpha: 1 } );
	}


	}
	//draws the frame around the Sprite
	private function drawFrame():Void{

		graphics.lineStyle(4,0x000000);

		graphics.drawRect(Lib.stage.stageWidth/2, 0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);

	}

}
