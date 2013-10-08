import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import openfl.Assets;
import Std;

class PowerOrigin extends Sprite{
	
	private var mPowerOriginNuclear : Sprite;
	private var mPowerOriginGreen : Sprite;
	private var mPowerOriginCoal: Sprite;
	private var mTimerSetting:Int = 10000;

	public function new(){

		super();

		var bitMapOrigin = new Bitmap (Assets.getBitmapData ("assets/nuclear.png"));
		var bitMapOriginGreen = new Bitmap (Assets.getBitmapData ("assets/green.png"));
		var bitMapOriginCoal = new Bitmap (Assets.getBitmapData ("assets/coal.png"));

		mPowerOriginNuclear = new Sprite();
		mPowerOriginGreen = new Sprite();
		mPowerOriginCoal = new Sprite();


		mPowerOriginNuclear.addChild (bitMapOrigin);
		mPowerOriginGreen.addChild (bitMapOriginGreen);
		mPowerOriginCoal.addChild (bitMapOriginCoal);

		

		centerGraphics(mPowerOriginNuclear,bitMapOrigin);
		centerGraphics(mPowerOriginGreen,bitMapOriginGreen);
		centerGraphics(mPowerOriginCoal,bitMapOriginCoal);

		graphics.lineStyle(4,0x000000);

		graphics.drawRect(Lib.stage.stageWidth/2, 0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);

		this.addChild(mPowerOriginNuclear);
		this.addChild(mPowerOriginGreen);
		this.addChild(mPowerOriginCoal);

		mPowerOriginNuclear.visible = true;
		mPowerOriginGreen.visible = false;
		mPowerOriginCoal.visible = false;

		var yourPowerOrigin:haxe.Timer = new haxe.Timer(mTimerSetting);

			yourPowerOrigin.run = function():Void{
   			trace("PowerOrigin timer running!!");
   				

   				

   				changePowerOrigin();
			};
		
	}


	private function centerGraphics(origin:Sprite, bitmap:Bitmap){


		origin.width = bitmap.width/2;
		origin.height = bitmap.height/2;

			var centerBitmapX = origin.width/2;
			var centerBitmapY = origin.height/2;

			var centerSpriteX = (Lib.stage.stageWidth / 4)*3;
			var centerSpriteY = (Lib.stage.stageHeight / 4);


			origin.x = centerSpriteX - centerBitmapX;
			origin.y = centerSpriteY - centerBitmapY;
			

	}

	public function changePowerOrigin():Void{


		var changenumber = Std.random(3);
		trace(changenumber);

		//pull powerorigin and change which sprite is visible

		if(changenumber == 0)
		{

		mPowerOriginGreen.visible = true;
		mPowerOriginNuclear.visible = false;
		mPowerOriginCoal.visible = false;
		}
		else if(changenumber == 1)
		{
		mPowerOriginGreen.visible = false;
		mPowerOriginNuclear.visible = true;
		mPowerOriginCoal.visible = false;

		}
		else if(changenumber == 2)
		{
		mPowerOriginGreen.visible = false;
		mPowerOriginNuclear.visible = false;
		mPowerOriginCoal.visible = true;

		}
	}

}