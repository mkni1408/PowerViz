package;

import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import flash.text.TextField;
import openfl.Assets;
import flash.events.MouseEvent;

import SpeedometerArrow;
import DataInterface;
import PowerTimer;
import FontSupply;
import Enums;

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
		
		registerEvents();

		mTimer = new PowerTimer(mTimerSetting);
		mTimer.onTime = function() {
			fetchWattConsumption();
		};
		mTimer.start();

	}
	
	//Registers all events that this class will handle.
	private function registerEvents() {
		mSpeedometer.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
				mSpeedometerSettings.showSettings();
			});
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
		if(wattMeasure>1.0)
			wattMeasure = 1;

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
	private var mMaxEditable:TextField; //Contains the max watt text. Starts at 1000. Increments 100 at a time.
	
	private var mOkButton:Sprite;
	private var mUpButton:Sprite;
	private var mDownButton:Sprite;
	
	public var maxValue:Float;
        
    public function new(w:Int, h:Int) {
		super();
		maxValue = 1000;
		createScreen(w,h);
		this.visible = false;
	}
	
	//Substitute this function to be notified when changing speedometer settings is done!
	dynamic public function onDoneChangingSettings(newMax:Float) {
		DataInterface.instance.setMaxWatts(newMax);
	}
	
	private function createScreen(w:Int, h:Int) {
		
		mBack = new Sprite();
		mBack.graphics.beginFill(0x808080);
		mBack.graphics.drawRect(0,0, w, h);
		mBack.graphics.endFill();
		mBack.alpha = 0.85;
		
		this.addChild(mBack);
		this.mouseEnabled = true;
		this.mouseChildren = true;
		
		mLabel = new TextField();
		mBack.addChild(mLabel);
		mLabel.text = "Husstandens max watt-forbrug:";
		mLabel.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
		mLabel.scaleX = 1.5;
		mLabel.scaleY = 1.5;
		mLabel.x = mBack.width/10;
		
		mMaxEditable = new TextField();
		mBack.addChild(mMaxEditable);
		mMaxEditable.text = Std.string(maxValue) + " watt";
		mMaxEditable.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
		mMaxEditable.scaleX = 1.5;
		mMaxEditable.scaleY = 1.5;
		mMaxEditable.x = mBack.width/3;
		mMaxEditable.y = mBack.height/3;
		
		mOkButton = createButton("assets/okbutton.png");
		mBack.addChild(mOkButton);
		mOkButton.width = mBack.width/10;
		mOkButton.height = mOkButton.width;
		mOkButton.x = (mBack.width - mOkButton.width)-(mOkButton.width/2);
		mOkButton.y = (mBack.height - mOkButton.height)-(mOkButton.height/2);
		mOkButton.addEventListener(flash.events.MouseEvent.MOUSE_UP, onOkButton);
		
		mUpButton = createButton("assets/button_up.png");
		mBack.addChild(mUpButton);
		mUpButton.width = mBack.width/10;
		mUpButton.height = mUpButton.width;
		mUpButton.x = mBack.width*0.5;
		mUpButton.y = mBack.height / 3.8;
		mUpButton.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onUpButton);
		
		mDownButton = createButton("assets/button_down.png");
		mBack.addChild(mDownButton);
		mDownButton.width = mUpButton.width;
		mDownButton.height = mUpButton.height;
		mDownButton.x = mUpButton.x;
		mDownButton.y = mUpButton.y + (mUpButton.height*1.25);
		mDownButton.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onDownButton);
	}
	
	//Show the settings menu thing.
	public function showSettings() {
		trace("Showing Speedometer settings");
		this.visible = true;
		maxValue = DataInterface.instance.relativeMax();
		setWattsTextbox(maxValue);
	}
	
	function onOkButton(event:MouseEvent) {
		this.visible = false;
		onDoneChangingSettings(maxValue);
		DataInterface.instance.logInteraction(LogType.Button, "SpeedometerSettingsChanged", "Set max watts to " + maxValue);
	}
	
	function onUpButton(event:MouseEvent) {
		maxValue += 100;
		setWattsTextbox(maxValue);
	}
	
	function onDownButton(event:MouseEvent) {
		maxValue -= 100;
		if(maxValue<1000)
			maxValue = 1000;
		setWattsTextbox(maxValue);
	}
	
	function createButton(imageFile:String) : Sprite {
		var retval = new Sprite();
		var bitmap = new Bitmap(openfl.Assets.getBitmapData(imageFile));
		retval.addChild(bitmap);
		return retval;
	}
	
	function setWattsTextbox(amount:Float) {
		mMaxEditable.text = Std.string(amount) + " watts";
		mMaxEditable.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
	}
	
}


