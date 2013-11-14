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
	private var arrow: SpeedometerArrow; //The arrow on the speedometer.
	
	//Labels on the speedometer:
	private var mLabels : Array<TextField>; //Labels round the speedometer.
	
	private var settings:Sprite; //Button to get to settings.
	private var mSpeedometerSettings : SpeedometerSettings; //Settings dialog.

	public function new(){

		super();

		bitMapSpeedometer = new Bitmap (Assets.getBitmapData ("assets/speedometer.png")); 

		var bitMapsettings = new Bitmap (Assets.getBitmapData ("assets/settings.png")); 
		arrow = new SpeedometerArrow();
		settings = new Sprite();

		settings.addChild(bitMapsettings);
		settings.width = 70;
		settings.height = 70;

		settings.x = 10;
		settings.y = -30;

        
		mSpeedometer = new Sprite();
	
		mSpeedometer.addChild (bitMapSpeedometer);
		this.addChild(settings);

		centerGraphics();

		drawFrame();
		//graphics.drawRect(0,0, speedometerArrow.width, speedometerArrow.height);

		this.addChild(mSpeedometer);
		this.addChild(arrow);
		
		createLabels();
		
		mSpeedometerSettings = new SpeedometerSettings(Std.int(Lib.stage.stageWidth), Std.int(Lib.stage.stageHeight));
		mSpeedometerSettings.onDoneChangingSettings = onDoneChangingSettings;
		this.addChild(mSpeedometerSettings);
		
		mSpeedometer.mouseEnabled = true; //This is set to true, to enable settings.
		arrow.mouseEnabled = false;
		
		registerEvents();

		DataInterface.instance.callbackNow.addCallback(function(){fetchWattConsumption();});
		
	}
	
	//Registers all events that this class will handle.
	private function registerEvents() {
		settings.addEventListener(MouseEvent.CLICK, function(event:MouseEvent) {
				mSpeedometerSettings.showSettings();
			});
	}

	private function centerGraphics(){

		//mSpeedometer.width = bitMapSpeedometer.width/4;
		//mSpeedometer.height = bitMapSpeedometer.height/4;	
		
		mSpeedometer.width = Lib.stage.stageWidth/4.5;
		mSpeedometer.height = mSpeedometer.width;

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
		var jitter = false;
		if(wattMeasure>1.0) {
			wattMeasure = 1;
			jitter = true;
		}
		arrow.setValue(wattMeasure, jitter);
	}

	//draws the frame around the Sprite
	private function drawFrame():Void{

		//graphics.lineStyle(4,0x000000);
		//graphics.drawRect(0, 0, Lib.stage.stageWidth/2, Lib.stage.stageHeight/2);

	}
	
	function createLabels() {
		mLabels = new Array<TextField>();
		
		for(i in 0...5) {
			mLabels.push(createSingleLabel(Std.string(i), 0,0));
			this.addChild(mLabels[i]);
		}
		setLabels(Std.int(DataInterface.instance.relativeMax()));
	}
	
	function createSingleLabel(val:String, x:Float, y:Float) : TextField {
		var label = new TextField();
		label = new TextField();
		label.text = val;
		label.setTextFormat(FontSupply.instance.getCoordAxisLabelSMALLFormat());
		label.x = x;
		label.y = y;
		return label;
	}
	
	function setLabels(newMax:Int) {
		var space = newMax / 4;
		var val = 0;
		for(i in 0...5) {
			mLabels[i].text = Std.string(Std.int(val)) + " watt ";
			mLabels[i].setTextFormat(FontSupply.instance.getCoordAxisLabelSMALLFormat());
			val += Std.int(newMax/4);
			if(i == 4)
				val = newMax;
		}
		positionLabels();
	}

	function positionLabels() {
		for(label in mLabels) {
			label.width = label.textWidth;
		}
		
		mLabels[0].x = Lib.stage.stageWidth/7.2 - (mLabels[0].width); 
		mLabels[0].y = Lib.stage.stageHeight/3.1;
		
		mLabels[1].x = (Lib.stage.stageWidth / 6.9) - (mLabels[1].width);
		mLabels[1].y = Lib.stage.stageHeight/8; 
		
		mLabels[2].x = (Lib.stage.stageWidth / 4) - (mLabels[2].width/2);
		mLabels[2].y = 3; 
		
		mLabels[3].x = Lib.stage.stageWidth / 2.85;
		mLabels[3].y = Lib.stage.stageHeight/8; 
		
		mLabels[4].x = Lib.stage.stageWidth/2.8; 
		mLabels[4].y = Lib.stage.stageHeight/3.1;

	}
	
	//Substitute this function to be notified when changing speedometer settings is done!
	public function onDoneChangingSettings(newMax:Float) {
		DataInterface.instance.setMaxWatts(newMax);
		setLabels(Std.int(newMax));
		DataInterface.instance.logInteraction(LogType.Setting, Std.string(newMax), "MaxWatts set to " + Std.string(newMax));
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
		trace("This should be replaced at runtime");
	}
	
	private function createScreen(w:Int, h:Int) {
		
		mBack = new Sprite();
		mBack.graphics.beginFill(0x808080);
		mBack.graphics.drawRect(0,-40, w, h);
		mBack.graphics.endFill();
		mBack.alpha = 0.95;
		
		this.addChild(mBack);
		this.mouseEnabled = true;
		this.mouseChildren = true;
		
		mLabel = new TextField();
		mBack.addChild(mLabel);
		mLabel.text = "Husstandens max watt-forbrug:";
		mLabel.width = mLabel.textWidth+200;
		mLabel.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
		mLabel.x = 25;
		mLabel.y = 25;
		mLabel.scaleX = 1.5;
		mLabel.scaleY = 1.5;
		mLabel.x = mBack.width/10;
		
		mMaxEditable = new TextField();
		mBack.addChild(mMaxEditable);
		mMaxEditable.text = Std.string(maxValue) + " watt";
		mMaxEditable.setTextFormat(FontSupply.instance.getWattLabelFormat());
		mMaxEditable.scaleX = 1.4;
		mMaxEditable.scaleY = 1.4;
		mMaxEditable.width = mLabel.textWidth+150;
		mMaxEditable.height = mLabel.textHeight + 10;
		mMaxEditable.x = mBack.width/3;
		mMaxEditable.y = mBack.height/2;
		
		mOkButton = createButton("assets/okbutton.png");
		mBack.addChild(mOkButton);
		mOkButton.width = 80;
		mOkButton.height = 80;
		mOkButton.x = (mBack.width - mOkButton.width)-(mOkButton.width/2);
		mOkButton.y = (mBack.height - mOkButton.height)-(mOkButton.height/2);
		mOkButton.addEventListener(flash.events.MouseEvent.MOUSE_UP, onOkButton);
		
		mUpButton = createButton("assets/button_up.png");
		mBack.addChild(mUpButton);
		mUpButton.width = mBack.width/10;
		mUpButton.height = mUpButton.width;
		mUpButton.x = mMaxEditable.x+200;
		mUpButton.y = mMaxEditable.y-(mMaxEditable.height/2) - 80;
		mUpButton.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onUpButton);
		
		mDownButton = createButton("assets/button_down.png");
		mBack.addChild(mDownButton);
		mDownButton.width = mUpButton.width;
		mDownButton.height = mUpButton.height;
		mDownButton.x = mUpButton.x;
		mDownButton.y = mMaxEditable.y-(mMaxEditable.height/2)  + 80;
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


