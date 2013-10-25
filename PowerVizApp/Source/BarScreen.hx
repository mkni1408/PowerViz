package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.Lib;

import DataInterface;
import BarGraph;
import FontSupply;
import TimeChangeButton;
import CoordSystem;

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
	//is used to determine which coordinate system type it is e.g week, day, month
	private var mViewMode:Int;
	private var mViewModes:Array<Int>;

	public function new() {
		super();

		mViewMode = VIEWMODE_DAY;

		mNewIDArray = new Array<String>();
		mKwhArray = new Array<String>();
		mRoomArray = new Array<String>();
		mColorArray = new Array<Int>();
		mViewModes = [VIEWMODE_DAY,VIEWMODE_WEEK,VIEWMODE_MONTH];
		
		mNewIDArray = DataInterface.instance.getAllOutletNames();
		mKwhArray = ["100Wt", "200Wt", "400Wt", "600Wt", "800Wt","1000Wt"];
		mBack = new Sprite();
		mBack.graphics.beginFill(0xFFFFFF);
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
		layout();
		fillWithData();

		this.addChild(mBack);
	}
	
	private function layout() {
	
		mTitle.width = mTitle.textWidth;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 20;
	
	
			
		mBarGraph.y = Lib.stage.stageHeight - ((Lib.stage.stageHeight - mBarGraph.height)/2);	
		

		
		mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;

		mTimeButton.y = 0;
		
		mCoordSys.generate(mBack.width/1.20, mBack.height/1.25, "X", "Y", (mBack.width/1.20)/mNewIDArray.length, (mBack.height/1.25)/mKwhArray.length, mNewIDArray, mKwhArray, true, false,true);
		mCoordSys.x = (Lib.stage.stageWidth- mCoordSys.width);
		mCoordSys.y = (Lib.stage.stageHeight/1.25)+50;


		//mCoordSys.createLegend(mNewIDArray.length, mNewIDArray, [0x005B96, 0x6497B1, 0xB1DAFB, 0x741d0d, 0xc72a00, 0xff7f24, 0x669900, 0x7acf00, 0xc5e26d]);
	}
	
	private function fillWithData() {
        
        var outlets = DataInterface.instance.getAllOutlets();
        var colors = new Array<Int>();
        var usageAA = new Array<Float>();

        switch(mViewMode) {
            case 0:
            	for(t in outlets) {
            	    usageAA.push(DataInterface.instance.getOutletLastHourTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
        		}
            case 1:
            	for(t in outlets) {
            	    usageAA.push(DataInterface.instance.getOutletLastDayTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
        		}
            case 2:
            	for(t in outlets) {
            	    usageAA.push(DataInterface.instance.getOutletLastWeekTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
       			 }
            default:
				for(t in outlets) {
                	usageAA.push(DataInterface.instance.getOutletLastHourTotal(t));
                	colors.push(DataInterface.instance.getOutletColor(t));
        		}
  	  	
			}
			
		

		mCoordSys.drawVerticalBar(colors, usageAA);
		
	

	}
		

	//is Called when a button is pushed
	private function onButtonPush(coordSystemType:Int):Void{

		trace("Button", coordSystemType, " Clicked");



		switch( coordSystemType ) {
    		case 0:
        	mViewMode = VIEWMODE_DAY;
    		case 1:
        	mViewMode = VIEWMODE_WEEK;
        	case 2:
        	mViewMode = VIEWMODE_MONTH;
    		default:
        	mViewMode = VIEWMODE_DAY;
    	}

		
		redrawEverything();


	}

	private function redrawEverything():Void{

		

		

		if(mViewMode == 0){
			//hour
			mKwhArray = ["100Wt", "200Wt", "400Wt", "600Wt", "800Wt","1000Wt"];
			mTitle.text = "Forbrug denne time";

		}
		if(mViewMode == 1){
			//day
			mKwhArray = ["1kWt", "2kWt", "4kWt", "6kWt", "8kWt","10kWt"];
			mTitle.text = "Forbrug i dag";

		}
		if(mViewMode == 2){
			///week
			mKwhArray = ["10kWh", "20kWh", "40kWh", "60kWh", "80kWh","100kWh"];
			mTitle.text = "Forbrug denne uge";

		}
		mTimeButton.changeButtonState(mViewMode);
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());

		layout();
		fillWithData();
	}

}



