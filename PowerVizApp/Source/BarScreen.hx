package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.Lib;

import DataInterface;
import BarGraph;
import FontSupply;
import TimeChangeButton;
import CoordSystem;
import PowerTimer;
import Enums;


class BarScreen extends Sprite {

	private static inline var VIEWMODE_DAY:Int = 0;
	private static inline var VIEWMODE_WEEK:Int = 1;
	private static inline var VIEWMODE_MONTH:Int = 2;

	private var mBack : Sprite;
	private var mBarGraph : BarGraph;
	private var mTitle : TextField;
	private var mTimeButton : TimeChangeButton;
	private var mCoordSys : CoordSystem;
	private var mNewIDArray : Array<String>;
	private var mKwhArray : Array<String>;
	private var mRoomArray : Array<String>;
	private var mColorArray : Array <Int>;
	private var mWattMax: Float = 0;
	private var musageAA: Array<Float>;
	private var mBarScale: Int;

	//is used to determine which coordinate system type it is e.g week, day, month
	private var mViewMode:Int;
	private var mViewModes:Array<Int>;

	private var mTimer:PowerTimer;
        #if demo
            private var mTimerInterval:Int = 60*1000; //Once a minute in demo mode.
        #else
            private var mTimerInterval:Int = 5*60*1000; //Every 5 minutes in normal mode.
        #end

	public function new() {
		super();

		mViewMode = VIEWMODE_DAY;

		mNewIDArray = new Array<String>();
		mKwhArray = new Array<String>();
		mRoomArray = new Array<String>();
		mColorArray = new Array<Int>();
		musageAA = new Array<Float>();
		mBarScale = 0;
		mViewModes = [VIEWMODE_DAY,VIEWMODE_WEEK,VIEWMODE_MONTH];
		
		mNewIDArray = DataInterface.instance.getAllOutletNames();
		mKwhArray = ["100Wt", "200Wt", "300wt","400Wt","500Wt", "600Wt","700Wt", "800Wt","900Wt","1000Wt"];
		mBack = new Sprite();
		mBack.graphics.beginFill(0xFFFFFF, 0);
		mBack.graphics.drawRect(0,0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		mBack.graphics.endFill();
		this.addChild(mBack);
		
		mBarGraph = new BarGraph();
		mBarGraph.mouseEnabled=false;
		//mBack.addChild(mBarGraph);
				
		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		mTitle.text = "Forbrug denne time";
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
		mTitle.selectable = false;
		mBack.addChild(mTitle);
		var testSprite = new Sprite();	
		
		mCoordSys = new CoordSystem();
		testSprite.addChild(mCoordSys);
		mBack.addChild(testSprite);
		
		mTimeButton = new TimeChangeButton(mViewModes,mViewMode,onButtonPush); //Day, week, month.
		mBack.addChild(mTimeButton);
		
		redrawEverything();

		this.addChild(mBack);

		/*
		mTimer = new PowerTimer(mTimerInterval); 
		mTimer.onTime = onTime;
		mTimer.start();
		*/
		DataInterface.instance.callbackQuarter.addCallback(onTime);
	}

	private function onTime() {
        //trace("Bar timer running");
        redrawEverything();
	}
	
	private function layout() {
	
			
		mBarGraph.y = Lib.current.stage.stageHeight - ((Lib.current.stage.stageHeight - mBarGraph.height)/2);	
		
		mTimeButton.x = Lib.current.stage.stageWidth - mTimeButton.width;

		mTimeButton.y = 0;
		
		mCoordSys.generate(mBack.width/1.20, mBack.height/1.30, "X", "Y", (mBack.width/1.20)/mNewIDArray.length, (mBack.height/1.30)/mKwhArray.length, mNewIDArray, mKwhArray, true, false,true);
		mCoordSys.x = 100;
		mCoordSys.y = (Lib.current.stage.stageHeight/1.30)+50;

		mTitle.width = mTitle.textWidth+5;	
		mTitle.x = (Lib.current.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 0;

		//trace("Coordinate",(mCoordSys.y - mCoordSys.height));


		//mCoordSys.createLegend(mNewIDArray.length, mNewIDArray, [0x005B96, 0x6497B1, 0xB1DAFB, 0x741d0d, 0xc72a00, 0xff7f24, 0x669900, 0x7acf00, 0xc5e26d]);
	}
	
	private function fillWithData() {
        
        var outlets = DataInterface.instance.getAllOutlets();
        var colors = new Array<Int>();
        musageAA = new Array<Float>();
        mWattMax = 0;
        mNewIDArray = DataInterface.instance.getAllOutletNames();

        switch(mViewMode) {
            case 0:
            	for(t in outlets) {
            	    musageAA.push(DataInterface.instance.getOutletLastHourTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
        		}
            case 1:
            	for(t in outlets) {
            	    musageAA.push(DataInterface.instance.getOutletLastDayTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
        		}
            case 2:
            	for(t in outlets) {
            	    musageAA.push(DataInterface.instance.getOutletLastWeekTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
       			 }
            default:
				for(t in outlets) {
                	musageAA.push(DataInterface.instance.getOutletLastHourTotal(t));
                	colors.push(DataInterface.instance.getOutletColor(t));
        		}
  	  	
			}

			for(wattMeasure in musageAA){
						if(wattMeasure > mWattMax){
            	    		mWattMax = wattMeasure;
            	    	}
           	}

			
			mColorArray = colors;

			
	}
		


	private function sortArray(watts:Array<Float>,ids:Array<String>,colors:Array<Int>):Void{


		var wattArray = watts;
		var idArray = ids;
		var colorArray = colors;

		var newWattArray = new Array<Float>();
		var newIdArray = new Array<String>();
		var newColorArray = new Array<Int>();

		var index = 0;
		var max = 0.0;

		for(i in 0...musageAA.length){ //find largest number
			if(musageAA[i] > max){
				max = musageAA[i];
			}

		}
		newWattArray.push(max);


		
		


   		for(i in 0...musageAA.length)
   		{
   			var min = i;

   			for(j in i+1...musageAA.length){
   				if(musageAA[j]<musageAA[min]){
   					min = j;
   				}
   				var temp = musageAA[i];
   				var idtemp = mNewIDArray[i];
   				var colortemp = mColorArray[i];

   				musageAA[i] = musageAA[min];
   				musageAA[min] = temp;

   				mNewIDArray[i] = mNewIDArray[min];
   				mNewIDArray[min] = idtemp;

   				mColorArray[i] = mColorArray[min];
   				mColorArray[min] = colortemp;

   			}


   		}
   		musageAA.reverse();
   		mNewIDArray.reverse();
   		mColorArray.reverse();
		trace(musageAA);
		trace(mNewIDArray);
		trace(mColorArray);



	}	

	//is Called when a button is pushed
	private function onButtonPush(coordSystemType:Int):Void{

		switch( coordSystemType ) {
    		case 0:
				mViewMode = VIEWMODE_DAY;
				DataInterface.instance.logInteraction(LogType.Button, "BarScreenViewHour");
    		case 1:
				mViewMode = VIEWMODE_WEEK;
				DataInterface.instance.logInteraction(LogType.Button, "BarScreenViewDay");
        	case 2:
				mViewMode = VIEWMODE_MONTH;
				DataInterface.instance.logInteraction(LogType.Button, "BarScreenViewThreeDays");
    		default:
				mViewMode = VIEWMODE_DAY;
    	}

		
		redrawEverything();


	}

	private function redrawEverything():Void{

		if(mViewMode == 0){
			//hour
			mTitle.text = "Forbrug denne time";

		}
		if(mViewMode == 1){
			//day
			mTitle.text = "Forbrug i dag";

		}
		if(mViewMode == 2){
			///week
			mTitle.text = "Forbrug denne uge";

		}

				

		mTimeButton.changeButtonState(mViewMode);
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());

		
		fillWithData();


		if(mWattMax <= 100){

                    mKwhArray = ["0,01 kWt", "0,02 kWt", "0,03 kWt","0,04 kWt","0,05 kWt", "0,06 kWt","0,07 kWt", "0,08 kWt","0,09 kWt","0,1 kWt"];
                    mBarScale = 10;
                }
                else if(mWattMax > 100 && mWattMax <= 500){

                    mKwhArray = ["0,05 kWt", "0,1 kWt", "0,15 kWt","0,2 kWt ","0,25 kWt", "0,3 kWt","0,35 kWt", "0,4 kWt","0,45 kWt","0,5 kWt"];
                    mBarScale =  50;
                }
                else if(mWattMax > 500 && mWattMax <= 1000){

                    mKwhArray = ["0,1 kWt ", "0,2 kWt", "0,3 kWt","0,4 kWt","0,5 kWt", "0,6 kWt","0,7 kWt", "0,8 kWt","0,9 kWt","1 kWt "];
                    mBarScale =  100;
                }
                else if(mWattMax > 1000 && mWattMax <= 2000){

                    mKwhArray = ["0,2 kWt ", "0,4 kWt", "0,6 kWt","0,8 kWt","1 kWt ", "1,2 kWt","1,4 kWt", "1,6 kWt","1,8 kWt","2 kWt"];
                    mBarScale =  200;
                }
                else if(mWattMax > 2000 && mWattMax <= 3000){

                    mKwhArray = ["0,3 kWt ", "0,6 kWt ", "0,9 kWt ","1,2 kWt ","1,5 kWt ", "1,8 kWt ","2,1 kWt ", "2,4 kWt","2,7 kWt","3 kWt "];
                    mBarScale =  300;
                }
                else if(mWattMax > 2000 && mWattMax <= 4000){

                    mKwhArray = ["0,4 kWt ", "0,8 kWt ", "1,2 kWt","1,6 kWt","2 kWt ", "2,4 kWt","2,8 kWt", "3,2 kWt","3,6 kWt","4 kWt"];
                    mBarScale =  400;
                }
                else if(mWattMax > 2000 && mWattMax <= 20000){

                    mKwhArray = ["2 kWt ", "4 kWt ", "6 kWt ","8 kWt ","10 kWt ", "12 kWt ","14 kWt ", "16 kWt ","18 kWt ","20 kWt "];
                    mBarScale =  2000;
                }
                else{//defaulter til denne her hvis forbruget overstiger 20kw(meget!)

                    mKwhArray = ["4 kWt", "8 kWt ", "12 kWt ","16 kWt ","20 kWt ", "24 kWt ","28 kWt ", "32 kWt ","36 kWt ","40 kWt "];
                    mBarScale = 4000;
                }
		sortArray(musageAA,mNewIDArray,mColorArray);//sort it from heighest to lowest
		layout();

		
		mCoordSys.drawVerticalBar(mColorArray, musageAA,mBarScale);
	}

}



