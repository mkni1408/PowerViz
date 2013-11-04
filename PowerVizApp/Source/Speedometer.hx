package;

import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import flash.text.TextField;
import openfl.Assets;

import SpeedometerArrow;
import DataInterface;
import PowerTimer;
import FontSupply;

class Speedometer extends Sprite{
	
	private var mSpeedometer : Sprite;
	private var bitMapSpeedometer : Bitmap;
	private var arrow: SpeedometerArrow;
	
	private var mTimer:PowerTimer;
	private var mTimerSetting:Int = 3000; //Interval between fetching data.
	
	private var mSpeedometerSettings : SpeedometerSettings;

	public function new(){

		super();

		bitMapSpeedometer = new Bitmap (Assets.getBitmapData ("assets/speedometer.png")); 
		arrow = new SpeedometerArrow();
        
		mSpeedometer = new Sprite();
	
		mSpeedometer.addChild (bitMapSpeedometer);

		centerGraphics();

		drawFrame();
		//graphics.drawRect(0,0, speedometerArrow.width, speedometerArrow.height);

		this.addChild(mSpeedometer);
		this.addChild(arrow);
		
		mSpeedometerSettings = new SpeedometerSettings(Std.int(Lib.stage.stageWidth/2), Std.int(Lib.stage.stageHeight/2));
		this.addChild(mSpeedometerSettings);
		
		mSpeedometer.mouseEnabled = true; //This is set to true, to enable settings.
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


class SpeedometerSettings extends Sprite {
	
	private var mBack:Sprite;
	private var mLabel:TextField;
	private var mMaxEditable:TextField;
	private var mOkButton:Bitmap;
        
    public function new(w:Int, h:Int) {
		super();
		createScreen(w,h);
		this.visible = false;
	}
	
	//Substitute this function to be notified when changing speedometer settings is done!
	dynamic public function onDoneChangingSettings() {}
	
	private function createScreen(w:Int, h:Int) {
		
		mBack = new Sprite();
		mBack.graphics.beginFill(0x1111FF);
		mBack.graphics.drawRect(0,0, w, h);
		mBack.graphics.endFill();
		
		this.addChild(mBack);
		
		mLabel = new TextField();
		mBack.addChild(mLabel);
		mLabel.text = "Max watts";
		mLabel.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
		mLabel.scaleX = 2;
		mLabel.scaleY = 2;
		mLabel.x = 50;
		
		mMaxEditable = new TextField();
		mBack.addChild(mMaxEditable);
		mMaxEditable.text = "2000";
		mMaxEditable.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
		mMaxEditable.scaleX = 2;
		mMaxEditable.scaleY = 2;
		mMaxEditable.x = 50;
		mMaxEditable.y = 100;
	}
	
	//Show the settings menu thing.
	public function showSettings() {
		this.visible = true;
	}
	
}


