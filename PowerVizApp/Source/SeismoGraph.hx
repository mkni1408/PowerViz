package;

import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import openfl.Assets;
import DataInterface;
import PowerTimer;
import motion.Actuate;
import flash.text.TextField;
import FontSupply;



class SeismoGraph extends Sprite{

	private var mSeismoGraph : Sprite;
	private var mwattMeasurementArray: Array<Int>;
	private var mwhereIsThePowerFromArray: Array<Int>;
	//remember that mMeasurmenthalfFactor should be exactly half of mMeasurmentFactor
	private var mMeasurmentFactor = 26;
	private var mMeasurmenthalfFactor = 13;
	private var mNumofFieldsWidthScreen:Float;
	private var mBadness:Array<Float>;
	
	/*
	private var mTimer:PowerTimer;
	private var mTimerSetting:Int = 6000;
	*/
	private var mCallbackCount:Int; //Counts how many callback are received from DataInterface.
	private var mbarSprite : Sprite;
	private var mLastTween:Float;
	private var tf:TextField;
	private var tfmoney:TextField;
	private var firstrun:Bool;
	
	public function new(){

		super();
		mwattMeasurementArray= new Array<Int>();
		mwhereIsThePowerFromArray= new Array<Int>();
		mBadness = new Array<Float>();	
		mbarSprite = new Sprite();
		mSeismoGraph = new Sprite();
		mLastTween = 0.0;
		tf = new TextField();
		tf.text = "Watt nu:";
		tf.setTextFormat(FontSupply.instance.getSeismographabelFormat());
		firstrun = true;//hack to not get the first value
		tf.width = mMeasurmenthalfFactor*18;


		tfmoney = new TextField();
		tfmoney.text = "Kr. den næste time: ";
		tfmoney.setTextFormat(FontSupply.instance.getSeismographabelFormat());
		
		tfmoney.width = mMeasurmenthalfFactor*18;

		mNumofFieldsWidthScreen = Lib.current.stage.stageWidth/mMeasurmenthalfFactor;

		redrawFrame();

		addChild(mSeismoGraph);
		
		fetchWattConsumption();
		mbarSprite.y = Lib.current.stage.stageHeight;

		this.graphics.lineStyle(2,0x000000);
		this.graphics.moveTo((Lib.current.stage.stageWidth)-((mMeasurmenthalfFactor*18)-10),Lib.current.stage.stageHeight);
		this.graphics.lineTo((Lib.current.stage.stageWidth)-((mMeasurmenthalfFactor*18)-10),(Lib.current.stage.stageHeight/2)+15);
		
		mbarSprite.graphics.beginFill(0x000000,1);
		mbarSprite.graphics.moveTo((Lib.current.stage.stageWidth)-(mMeasurmenthalfFactor*18),Lib.current.stage.stageHeight);
		mbarSprite.graphics.lineTo((Lib.current.stage.stageWidth+10)-(mMeasurmenthalfFactor*18),Lib.current.stage.stageHeight-10);
		mbarSprite.graphics.lineTo((Lib.current.stage.stageWidth+10)-(mMeasurmenthalfFactor*18),Lib.current.stage.stageHeight+10);
		mbarSprite.graphics.lineTo((Lib.current.stage.stageWidth)-(mMeasurmenthalfFactor*18),Lib.current.stage.stageHeight);
		
		mbarSprite.graphics.endFill();

		

		addChild(mbarSprite);
		this.addChild(tf);
		this.addChild(tfmoney);

		tf.x = (Lib.current.stage.stageWidth+15)-(mMeasurmenthalfFactor*18);
		tf.y = Lib.current.stage.stageHeight/2 + 50;

		tfmoney.x = (Lib.current.stage.stageWidth+15)-(mMeasurmenthalfFactor*18);
		tfmoney.y = Lib.current.stage.stageHeight/2 + 100;

		

		//redrawSeismoGraphCurve();
		/*
		mTimer = new PowerTimer(mTimerSetting);
		mTimer.onTime = function() {
			fetchWattConsumption();
		};
		mTimer.start();
		*/
		mCallbackCount = 0;
		DataInterface.instance.callbackNow.addCallback(function() {
				mCallbackCount += 1;
				if(mCallbackCount>1) {
					fetchWattConsumption();
					mCallbackCount = 0;
				}
			});
		
	}


	public function initSprite():Void{

		mSeismoGraph.graphics.lineStyle(4,0x000000);

		mSeismoGraph.graphics.drawRect(0, Lib.current.stage.stageHeight/2, Lib.current.stage.stageWidth, (Lib.current.stage.stageHeight/2)-4);

		addChild(mSeismoGraph);

	}


	public function fetchWattConsumption():Void{

		

		//trace(mNumofFieldsWidthScreen);

		//first we see if the array length is larger than the amount of slots on the screen
		//if so we remove the first element of the array to make room for another
		if(mwattMeasurementArray.length >= mNumofFieldsWidthScreen-12){
			mwattMeasurementArray.reverse();
			mwhereIsThePowerFromArray.reverse();
			

			mwattMeasurementArray.pop();
			mwhereIsThePowerFromArray.pop();

			//trace("Dequeing");
			mwattMeasurementArray.reverse();
			mwhereIsThePowerFromArray.reverse();
		}	

		if(!firstrun){
			var wattMeasure:Float = DataInterface.instance.relativeUsage(); 
			var badness:Float = DataInterface.instance.powerSourceBadness;
			var origin:Int = testDataInterfaceOrigin(); //TODO!!!

        	mwattMeasurementArray.push(calculatePeakHeight(wattMeasure));
        	mwhereIsThePowerFromArray.push(origin);
        	mBadness.push(badness);
    		//trace("Pushing measure:",wattMeasure);
    		//trace("Pushing origin:",origin);

    		//redraw the curve
    		redrawSeismoGraphCurve();
    	}
    	else{
    		firstrun = false;
    	}

	}

	//redraws the entire seismograph curve and frame
	public function redrawSeismoGraphCurve(){

		//clear graphics to redraw seismograph
		/*
		graphics.clear();

		redrawFrame();

		
		//draw horizontal line
		

		var xPosition = Lib.current.stage.stageWidth - (mwattMeasurementArray.length * mMeasurmentFactor);
		var yPosition = (Lib.current.stage.stageHeight/4)*3;

		//graphics.lineStyle(2,0x000000);
		graphics.moveTo(xPosition,yPosition);

		for(i in 0...mwattMeasurementArray.length){

			//trace("Wattmeasure is:",mwhereIsThePowerFromArray[i]);

			if(mwhereIsThePowerFromArray[i] == 1)
			{
				//change color to green
				graphics.lineStyle(2,0x000000);
			}
			else if(mwhereIsThePowerFromArray[i] == 0)
			{
				//change color to black
				graphics.lineStyle(2,0x00FF00);
			}
			xPosition=xPosition+mMeasurmenthalfFactor;
			yPosition=yPosition+mwattMeasurementArray[i];
			//trace(xPosition);
			//trace(yPosition);
			//draw the line up
			graphics.lineTo(xPosition,yPosition);


			//move curser to
		graphics.moveTo(xPosition,yPosition);

		xPosition = xPosition+mMeasurmenthalfFactor;
		yPosition = yPosition-(mwattMeasurementArray[i]*2);
		//trace(xPosition);
			//trace(yPosition);
			//draw line down
		graphics.lineTo(xPosition,yPosition);


		graphics.moveTo(xPosition,yPosition);
		yPosition = yPosition+mwattMeasurementArray[i];

		}*/
		//trace(".......");
		redrawCurve();

	}

	public function redrawCurve(){

		//clear graphics to redraw seismograph
		mSeismoGraph.graphics.clear();

		redrawFrame();

		var commands = new flash.Vector<Int>();
		var coords = new flash.Vector<Float>();
		var origin = new Array<Int>();
		var commandCommands = new Array<flash.Vector<Int>>();
		var cordcordArray = new Array<flash.Vector<Float>>();

		//draw horizontal line
		//graphics.lineStyle(2,0x000000);
		//graphics.moveTo(0,(Lib.current.stage.stageHeight/4)*3);
		//graphics.lineTo(Lib.current.stage.stageWidth,(Lib.current.stage.stageHeight/4)*3);

		var xPosition = (Lib.current.stage.stageWidth-(mMeasurmenthalfFactor*18)) - (((mwattMeasurementArray.length-1) * mMeasurmenthalfFactor));
		var yPosition = (Lib.current.stage.stageHeight/4)*3;

		var prevMeasure = 2;

		for(wattmeasure in mwattMeasurementArray){

			commands.push(1);
			coords.push(xPosition);
			coords.push(Lib.current.stage.stageHeight-2);

			xPosition = xPosition-mMeasurmenthalfFactor;
			
			commands.push(2);
			coords.push(xPosition);
			coords.push(Lib.current.stage.stageHeight-2);

			commands.push(2);
			coords.push(xPosition);
			coords.push(Lib.current.stage.stageHeight-prevMeasure);
			
			xPosition = xPosition+mMeasurmenthalfFactor;

			commands.push(2);
			coords.push(xPosition);
			coords.push(Lib.current.stage.stageHeight-wattmeasure);
			
			prevMeasure = wattmeasure;

			commands.push(2);
			coords.push(xPosition);
			coords.push(Lib.current.stage.stageHeight-2);

			xPosition = xPosition+mMeasurmenthalfFactor;

			commandCommands.push(commands);
			cordcordArray.push(coords);
			

			commands = new flash.Vector<Int>();
			coords = new flash.Vector<Float>();

			

		}
		for(i in 0...commandCommands.length){

			mSeismoGraph.graphics.beginFill(getPowerSourceColor(mBadness[i]));//set the color 
			mSeismoGraph.graphics.lineStyle(0,getPowerSourceColor(mBadness[i]));
    		mSeismoGraph.graphics.drawPath(commandCommands[i], cordcordArray[i]); 
		}

		setBar(mwattMeasurementArray[mwattMeasurementArray.length-1]);

		
		

	}

	public function testDataInterfaceWatt():Float{


		return Math.random();
	}
	public function testDataInterfaceOrigin():Int{

			var tmp = Std.random(2);

			if(tmp == 1)
			{
				//change color to green
				return 0x000000;
			}
			else 
			{
				//change color to black
				return 0x00FF00;
			}

		
	}
	//function that returns a peakheight 
	//takes a float between 0-1 and calculates the peakheight
	private function calculatePeakHeight(f:Float):Int{

		if(f>1.0){
			f = 1.0;
		}

		var numPixels = (Lib.current.stage.stageHeight/2)-40;

		return Math.floor(numPixels * f);


	}

	private function setBar(height:Float):Void{
		var tmpHeight = 0.0;

		if(mLastTween > height){
			tmpHeight = mLastTween - height;

		}
		else if(mLastTween < height){
			tmpHeight =  mLastTween - height;
		}
		else{


		}

		Actuate.tween(mbarSprite, 1, {y:-height});
		//Actuate.tween(tf, 1, {y:tmpHeight});

		mLastTween = height;

		tf.text = "Watt nu: " + DataInterface.instance.getTotalCurrentLoad();
		tf.width = mMeasurmenthalfFactor*18;
		tf.setTextFormat(FontSupply.instance.getSeismographabelFormat());


		tfmoney.text = "Kr. den næste time: " + DataInterface.instance.getTotalCurrentLoad();
		tfmoney.width = mMeasurmenthalfFactor*18;
		tfmoney.setTextFormat(FontSupply.instance.getSeismographabelFormat());
		//Actuate.tween (mbarSprite, 1, { alpha: 1 } );
	}

	 function finished() {
        trace ( "tween finished" );
    }

	//draws the frame around the Sprite
	private function redrawFrame():Void{

		//mSeismoGraph.graphics.lineStyle(4,0x000000);

		//redraw frame
		//mSeismoGraph.graphics.drawRect(0, Lib.current.stage.stageHeight/2, Lib.current.stage.stageWidth, (Lib.current.stage.stageHeight/2)-2);
		//mSeismoGraph.graphics.drawRect(0, Lib.current.stage.stageHeight/2, mMeasurmenthalfFactor*15, (Lib.current.stage.stageHeight/2)-2);
		

	}

	private function getPowerSourceColor(badness:Float):Int{

		if(badness<0.2){
			return 0x05fa00;
		}
		else if(badness >= 0.2 && badness < 0.4){
			return 0x00ab00;

		}
		else if(badness >= 0.4 && badness < 0.6){
			return 0x003f00;
		}
		else if(badness >= 0.6 && badness < 0.8){
			return 0x002100;
		}
		else if(badness >= 0.8 && badness < 1.0){
			return 0x003000;
		}
		else{
			return 0x05fa00;
		}
	}


}
