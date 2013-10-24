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
		mKwhArray = ["2kWh", "4kWh", "6kWh", "8kWh", "10kWh"];
		mBack = new Sprite();
		mBack.graphics.beginFill(0xFFFFFF);
		mBack.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageWidth);
		mBack.graphics.endFill();
		this.addChild(mBack);
		
		mBarGraph = new BarGraph();
		mBarGraph.mouseEnabled=false;
		mBack.addChild(mBarGraph);
				
		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		mTitle.text = "Forbrug i dag ";
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
		mTitle.selectable = false;
		mBack.addChild(mTitle);
		
		fillWithData();
		
		mCoordSys = new CoordSystem();
		mBack.addChild(mCoordSys);
		
		mTimeButton = new TimeChangeButton(mViewModes,mViewMode,onButtonPush); //Day, week, month.
		mBack.addChild(mTimeButton);
		
		layout();
		
	}
	
	private function layout() {
	
		mTitle.width = mTitle.textWidth;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 20;
	
	
		mBarGraph.width = Lib.stage.stageWidth / 1.15;
		mBarGraph.height = Lib.stage.stageHeight / 1.25;
		mBarGraph.x = (Lib.stage.stageWidth - mBarGraph.width) / 2;
		mBarGraph.y = Lib.stage.stageHeight - ((Lib.stage.stageHeight - mBarGraph.height)/2);	
		

		
		mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;

		mTimeButton.y = 0;
		
		mCoordSys.generate(mBarGraph.width, mBarGraph.height, "X", "Y", mBarGraph.width/9, mBarGraph.height/5, mNewIDArray, mKwhArray, true, false);
		mCoordSys.x = mBarGraph.x;
		mCoordSys.y = mBarGraph.y;
		trace("--");
		//mCoordSys.createLegend(mNewIDArray.length, mNewIDArray, [0x005B96, 0x6497B1, 0xB1DAFB, 0x741d0d, 0xc72a00, 0xff7f24, 0x669900, 0x7acf00, 0xc5e26d]);
	}
	
	private function fillWithData() {
        
        var outlets = DataInterface.instance.getAllOutlets();
        var colors = new Array<Int>();
        var usageAA = new Array<Float>();

        switch(mViewMode) {
            case 0:
            	for(t in outlets) {
            	    usageAA.push(DataInterface.instance.getOutletLastDayTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
        		}
            case 1:
            	for(t in outlets) {
            	    usageAA.push(DataInterface.instance.getOutletLastWeekTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
        		}
            case 2:
            	for(t in outlets) {
            	    usageAA.push(DataInterface.instance.getOutletLastMonthTotal(t));
            	    colors.push(DataInterface.instance.getOutletColor(t));
       			 }
            default:
				for(t in outlets) {
                	usageAA.push(DataInterface.instance.getOutletLastDayTotal(t));
                	colors.push(DataInterface.instance.getOutletColor(t));
        		}
  	  	}

			mBarGraph.drawBar(colors, usageAA);	
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
			trace(0);
			mKwhArray = ["2kWh", "4kWh", "6kWh", "8kWh", "10kWh"];
			mTitle.text = "Forbrug i dag";

		}
		if(mViewMode == 1){
			trace(1);
			mKwhArray = ["4kWh", "8kWh", "12kWh", "16kWh", "20kWh"];
			mTitle.text = "Forbrug denne uge";

		}
		if(mViewMode == 2){
			trace(2);
			mKwhArray = ["10kWh", "20kWh", "30kWh", "40kWh", "50kWh"];
			mTitle.text = "Forbrug denne måned";

		}
		mTimeButton.changeButtonState(mViewMode);
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());

		layout();
		fillWithData();
	}

}



