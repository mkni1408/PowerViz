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
		mBack.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageHeight);
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
	
			
		mBarGraph.y = Lib.stage.stageHeight - ((Lib.stage.stageHeight - mBarGraph.height)/2);	
		
		mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;

		mTimeButton.y = 0;
		
		mCoordSys.generate(mBack.width/1.20, mBack.height/1.30, "X", "Y", (mBack.width/1.20)/mNewIDArray.length, (mBack.height/1.30)/mKwhArray.length, mNewIDArray, mKwhArray, true, false,true);
		mCoordSys.x = (Lib.stage.stageWidth- mCoordSys.width);
		mCoordSys.y = (Lib.stage.stageHeight/1.30)+50;

		mTitle.width = mTitle.textWidth+5;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 0;

		//trace("Coordinate",(mCoordSys.y - mCoordSys.height));


		//mCoordSys.createLegend(mNewIDArray.length, mNewIDArray, [0x005B96, 0x6497B1, 0xB1DAFB, 0x741d0d, 0xc72a00, 0xff7f24, 0x669900, 0x7acf00, 0xc5e26d]);
	}
	
	private function fillWithData() {
        
        var outlets = DataInterface.instance.getAllOutlets();
        var colors = new Array<Int>();
        musageAA = new Array<Float>();
        mWattMax = 0;

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

                    mKwhArray = ["10Wt  ", "20Wt  ", "30Wt  ","40Wt  ","50Wt  ", "60Wt  ","70Wt  ", "80Wt  ","90Wt  ","100Wt "];
                    mBarScale = 10;
                }
                else if(mWattMax > 100 && mWattMax <= 500){

                    mKwhArray = ["50Wt  ", "100Wt ", "150Wt ","200Wt ","250Wt ", "300Wt ","350Wt ", "400Wt","450Wt ","500Wt "];
                    mBarScale =  50;
                }
                else if(mWattMax > 500 && mWattMax <= 1000){

                    mKwhArray = ["100Wt ", "200Wt ", "300Wt ","400Wt ","500Wt ", "600Wt ","700Wt ", "800Wt ","900Wt ","1000Wt"];
                    mBarScale =  100;
                }
                else if(mWattMax > 1000 && mWattMax <= 2000){

                    mKwhArray = ["200Wt ", "400Wt ", "600Wt ","800Wt ","1000Wt", "1200Wt","1400Wt ", "1600Wt","1800Wt","2000Wt"];
                    mBarScale =  200;
                }
                else if(mWattMax > 2000 && mWattMax <= 3000){

                    mKwhArray = ["0,3kWt ", "0,6kWt ", "0,9kWt ","1,2kWt ","1,5kWt ", "1,8kWt ","2,1kWt ", "2,4kWt","2,7kWt","3kWt"];
                    mBarScale =  300;
                }
                else if(mWattMax > 2000 && mWattMax <= 4000){

                    mKwhArray = ["0,4Wt ", "0,8Wt ", "1,2kWt","1,6kWt","2kWt  ", "2,4kWt ","2,8kWt", "3,2kWt","3,6kWt","4kWt  "];
                    mBarScale =  400;
                }
                else if(mWattMax > 2000 && mWattMax <= 20000){

                    mKwhArray = ["2kWt  ", "4kWt  ", "6kWt  ","8kWt  ","10kWt  ", "12kWt  ","14kWt  ", "16kWt ","18kWt ","20kWt "];
                    mBarScale =  2000;
                }
                else{//defaulter til denne her hvis forbruget overstiger 20kw(meget!)

                    mKwhArray = ["4kWt ", "8kWt ", "12kWt ","16kWt ","20kWt ", "24kWt ","28kWt ", "32kWt ","36kWt ","40kWt "];
                    mBarScale = 4000;
                }
		layout();
		mCoordSys.drawVerticalBar(mColorArray, musageAA,mBarScale);
	}

}



