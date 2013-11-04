package;

import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import openfl.Assets;
import SpeedometerArrow;
import DataInterface;
import PowerTimer;

class Speedometer extends Sprite{
	
	private var mSpeedometer : Sprite;
	private var bitMapSpeedometer : Bitmap;
	private var arrow: SpeedometerArrow;
	private var speedometerArrow: Sprite;
	
	private var mTimer:PowerTimer;
	private var mTimerSetting:Int = 3000;

	public function new(){

		super();

		bitMapSpeedometer = new Bitmap (Assets.getBitmapData ("assets/speedometer.png"));
		arrow = new SpeedometerArrow();
		speedometerArrow = new Sprite();
		mSpeedometer = new Sprite();
	

		mSpeedometer.addChild (bitMapSpeedometer);


		//speedometerArrow.addChild(arrow);


		centerGraphics();

		drawFrame();
		//graphics.drawRect(0,0, speedometerArrow.width, speedometerArrow.height);

		this.addChild(mSpeedometer);
		this.addChild(arrow);
		
		mSpeedometer.mouseEnabled = false;
		arrow.mouseEnabled = false;

		mTimer = new PowerTimer(mTimerSetting);
		mTimer.onTime = function() {
			fetchWattConsumption();
		};
		mTimer.start();


	}

	private function centerGraphics(){


		mSpeedometer.width = bitMapSpeedometer.width/4;
		mSpeedometer.height = bitMapSpeedometer.height/4;	

			var centerBitmapX = mSpeedometer.width/2;
			var centerBitmapY = mSpeedometer.height/2;

			var centerSpriteX = Lib.stage.stageWidth / 4;
			var centerSpriteY = Lib.stage.stageHeight / 4;


			mSpeedometer.x = centerSpriteX - centerBitmapX;
			mSpeedometer.y = centerSpriteY - centerBitmapY;

			arrow.x = centerSpriteX;
			arrow.y = centerSpriteY;

			arrow.setValue(0.5);

			//arrow.x = speedometerArrow.x-arrow.width;
			//arrow.y = speedometerArrow.y-arrow.height;
			
			

	}
	//calculates and returns the amount of degrees the speedometorarrow should turn
	private function calculateArrowPosition(wattUsage:Float):Int{

			return 1;
	}

	private function fetchWattConsumption():Void{

		var wattMeasure:Float = DataInterface.instance.relativeUsage();
		arrow.setValue(wattMeasure);


	}

	//draws the frame around the Sprite
	private function drawFrame():Void{

		graphics.lineStyle(4,0x000000);

		graphics.drawRect(0, 0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);

	}

}
