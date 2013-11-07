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
	
	private var mTimer:PowerTimer;
	private var mTimerSetting:Int = 6000;
	private var mbarSprite : Sprite;
	private var mLastTween:Float;
	private var tf:TextField;
	private var firstrun:Bool;
	
	public function new(){

		super();
		mwattMeasurementArray= new Array<Int>();
		mwhereIsThePowerFromArray= new Array<Int>();	
		mbarSprite = new Sprite();
		mSeismoGraph = new Sprite();
		mLastTween = 0.0;
		tf = new TextField();
		tf.text = "Watt nu:";
		tf.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
		firstrun = true;//hack to not get the first value

		mNumofFieldsWidthScreen = Lib.stage.stageWidth/mMeasurmenthalfFactor;

		redrawFrame();

		addChild(mSeismoGraph);
		
		fetchWattConsumption();
		mbarSprite.y = Lib.stage.stageHeight;

		mbarSprite.graphics.lineStyle(2,0x000000);
		mbarSprite.graphics.moveTo(0,Lib.stage.stageHeight);
		mbarSprite.graphics.lineTo(Lib.stage.stageWidth,Lib.stage.stageHeight);

		
		addChild(mbarSprite);
		mbarSprite.addChild(tf);

		tf.x = ((mMeasurmenthalfFactor*15)/2)-(tf.textWidth/2);
		tf.y = Lib.stage.stageHeight-30;

		

		//redrawSeismoGraphCurve();

		mTimer = new PowerTimer(mTimerSetting);
		mTimer.onTime = function() {
			fetchWattConsumption();
		};
		mTimer.start();
		
	}


	public function initSprite():Void{

		mSeismoGraph.graphics.lineStyle(4,0x000000);

		mSeismoGraph.graphics.drawRect(0, Lib.stage.stageHeight/2, Lib.stage.stageWidth, (Lib.stage.stageHeight/2)-4);

		addChild(mSeismoGraph);

	}


	public function fetchWattConsumption():Void{

		

		//trace(mNumofFieldsWidthScreen);

		//first we see if the array length is larger than the amount of slots on the screen
		//if so we remove the first element of the array to make room for another
		if(mwattMeasurementArray.length >= mNumofFieldsWidthScreen-15){
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
			var origin:Int = testDataInterfaceOrigin(); //TODO!!!

        	mwattMeasurementArray.push(calculatePeakHeight(wattMeasure));
        	mwhereIsThePowerFromArray.push(origin);
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
		

		var xPosition = Lib.stage.stageWidth - (mwattMeasurementArray.length * mMeasurmentFactor);
		var yPosition = (Lib.stage.stageHeight/4)*3;

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

		var commands = new Array<Int>();
		var coords = new Array<Float>();
		var origin = new Array<Int>();
		var commandCommands = new Array<Array<Int>>();
		var cordcordArray = new Array<Array<Float>>();

		//draw horizontal line
		//graphics.lineStyle(2,0x000000);
		//graphics.moveTo(0,(Lib.stage.stageHeight/4)*3);
		//graphics.lineTo(Lib.stage.stageWidth,(Lib.stage.stageHeight/4)*3);

		var xPosition = (Lib.stage.stageWidth-2) - (((mwattMeasurementArray.length-1) * mMeasurmenthalfFactor));
		var yPosition = (Lib.stage.stageHeight/4)*3;

		var prevMeasure = 0;

		for(wattmeasure in mwattMeasurementArray){

			commands.push(1);
			coords.push(xPosition);
			coords.push(Lib.stage.stageHeight-4);

			xPosition = xPosition-mMeasurmenthalfFactor;
			
			commands.push(2);
			coords.push(xPosition);
			coords.push(Lib.stage.stageHeight-4);

			commands.push(2);
			coords.push(xPosition);
			coords.push(Lib.stage.stageHeight-prevMeasure);
			
			xPosition = xPosition+mMeasurmenthalfFactor;

			commands.push(2);
			coords.push(xPosition);
			coords.push(Lib.stage.stageHeight-wattmeasure);
			trace("wattmeasure",wattmeasure);

			prevMeasure = wattmeasure;

			commands.push(2);
			coords.push(xPosition);
			coords.push(Lib.stage.stageHeight-4);

			xPosition = xPosition+mMeasurmenthalfFactor;

			commandCommands.push(commands);
			cordcordArray.push(coords);
			

			commands = new Array<Int>();
			coords = new Array<Float>();

			

		}
		trace(cordcordArray);
		for(i in 0...commandCommands.length){

			mSeismoGraph.graphics.beginFill(mwhereIsThePowerFromArray[i]);//set the color 
			mSeismoGraph.graphics.lineStyle(0,mwhereIsThePowerFromArray[i]);
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

		var numPixels = (Lib.stage.stageHeight/2)-10;

		return Math.floor(numPixels * f);


	}

	private function setBar(height:Float):Void{
		trace(height);
		trace(Lib.stage.stageHeight - height);
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
		tf.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
		//Actuate.tween (mbarSprite, 1, { alpha: 1 } );
	}

	 function finished() {
        trace ( "tween finished" );
    }

	//draws the frame around the Sprite
	private function redrawFrame():Void{

		mSeismoGraph.graphics.lineStyle(4,0x000000);

		//redraw frame
		mSeismoGraph.graphics.drawRect(0, Lib.stage.stageHeight/2, Lib.stage.stageWidth, (Lib.stage.stageHeight/2)-2);
		mSeismoGraph.graphics.drawRect(0, Lib.stage.stageHeight/2, mMeasurmenthalfFactor*15, (Lib.stage.stageHeight/2)-2);
		

	}


}
