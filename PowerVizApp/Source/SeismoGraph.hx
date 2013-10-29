import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import openfl.Assets;
import DataInterface;


class SeismoGraph extends Sprite{

	private var mSeismoGraph : Sprite;
	private var mwattMeasurementArray: Array<Int>;
	private var mwhereIsThePowerFromArray: Array<Int>;
	//remember that mMeasurmenthalfFactor should be exactly half of mMeasurmentFactor
	private var mMeasurmentFactor = 10;
	private var mMeasurmenthalfFactor = 5;
	private var mNumofFieldsWidthScreen:Float;
	private var mTimerSetting:Int = 6000;
	
	public function new(){

		super();
		mwattMeasurementArray= new Array<Int>();
		mwhereIsThePowerFromArray= new Array<Int>();

		mSeismoGraph = new Sprite();

		mNumofFieldsWidthScreen = Lib.stage.stageWidth/mMeasurmentFactor;

		

		redrawFrame();

		addChild(mSeismoGraph);
		
		fetchWattConsumption();

		graphics.lineStyle(2,0x000000);
		graphics.moveTo(0,(Lib.stage.stageHeight/4)*3);
		graphics.lineTo(Lib.stage.stageWidth,(Lib.stage.stageHeight/4)*3);


		redrawSeismoGraphCurve();

		var yourSeismoGraphTimer:haxe.Timer = new haxe.Timer(mTimerSetting);

			yourSeismoGraphTimer.run = function():Void{
   			//trace("PowerOrigin timer running!!");
   				

   				fetchWattConsumption();
			};

	}


	public function initSprite():Void{

		graphics.lineStyle(4,0x000000);

		graphics.drawRect(0, Lib.stage.stageHeight/2, Lib.stage.stageWidth, (Lib.stage.stageHeight/2)-4);

		addChild(mSeismoGraph);

	}


	public function fetchWattConsumption():Void{

		

		//trace(mNumofFieldsWidthScreen);

		//first we see if the array length is larger than the amount of slots on the screen
		//if so we remove the first element of the array to make room for another
		if(mwattMeasurementArray.length >= mNumofFieldsWidthScreen){
			mwattMeasurementArray.reverse();
			mwhereIsThePowerFromArray.reverse();
			

			mwattMeasurementArray.pop();
			mwhereIsThePowerFromArray.pop();

			//trace("Dequeing");
			mwattMeasurementArray.reverse();
			mwhereIsThePowerFromArray.reverse();
		}	

		var wattMeasure:Float = testDataInterfaceWatt();
		var origin:Int = testDataInterfaceOrigin();

        mwattMeasurementArray.push(calculatePeakHeight(wattMeasure));
        mwhereIsThePowerFromArray.push(origin);
    	//trace("Pushing measure:",wattMeasure);
    	//trace("Pushing origin:",origin);

    	//redraw the curve
    	redrawSeismoGraphCurve();

	}

	//redraws the entire seismograph curve and frame
	public function redrawSeismoGraphCurve(){

		//clear graphics to redraw seismograph
		graphics.clear();

		redrawFrame();

		//draw horizontal line
		graphics.lineStyle(2,0x000000);
		graphics.moveTo(0,(Lib.stage.stageHeight/4)*3);
		graphics.lineTo(Lib.stage.stageWidth,(Lib.stage.stageHeight/4)*3);

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

		}

	}

	public function testDataInterfaceWatt():Float{


		return Math.random();
	}
	public function testDataInterfaceOrigin():Int{


		return Std.random(2);
	}
	//function that returns a peakheight 
	//takes a float between 0-1 and calculates the peakheight
	private function calculatePeakHeight(f:Float):Int{

		var numPixels = (Lib.stage.stageHeight/4) - 10;

		return Math.floor(numPixels * f);


	}

	//draws the frame around the Sprite
	private function redrawFrame():Void{

		graphics.lineStyle(4,0x000000);

		//redraw frame
		graphics.drawRect(0, Lib.stage.stageHeight/2, Lib.stage.stageWidth, (Lib.stage.stageHeight/2)-2);

	}


}