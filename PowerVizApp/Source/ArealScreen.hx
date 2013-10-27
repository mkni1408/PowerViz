package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.Lib;

import DataInterface;
import ArealDiagram;
import FontSupply;
import DataInterface;
import TimeChangeButton;
import CoordSystem;
import Outlet;

/**
Screen displaying the Areal diagram.
Uses the ArealDiagram class for drawing the special diagram.

This class obtains data from the DataInterface singleton class.
**/

class ArealScreen extends Sprite {

	private static inline var VIEWMODE_DAY:Int = 0;
	private static inline var VIEWMODE_WEEK:Int = 1;
	private static inline var VIEWMODE_MONTH:Int = 2;

	private var mBack : Sprite;
	private var mDiagram : ArealDiagram;
	private var mCoordSys : CoordSystem;
	private var mtimeArray: Array<String>;
	private var mUsageArray : Array<String>;
	private var mTitle : TextField;
	private var mTimeButton : TimeChangeButton;
	private var mLegend:Legend;
	private var mRoomArray:Array<String>;
	private var mColorArray:Array<Int>;
	
	private var mViewMode:Int;
	private var mFront:Sprite;

	public function new() {
		super();
		
		mRoomArray = new Array<String>();
		mColorArray = new Array<Int>();

		getColorAndRoomData();

		mViewMode = VIEWMODE_DAY; //Daymode by default.
		
		mBack = new Sprite();

		mBack.graphics.beginFill(0xFFFFFF);
		mBack.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageWidth);
		mBack.graphics.endFill();
		this.addChild(mBack);

		mtimeArray = ["","2:00","","4:00","","6:00","","8:00","","10:00","","12:00",""
							,"14:00","","16:00","","18:00","","20:00","","22:00","","24:00"];

		mUsageArray = ["100Wt", "200Wt", "300wt","400Wt","500Wt", "600Wt","700Wt", 
							"800Wt","900Wt","1000Wt"];

		
		mDiagram = new ArealDiagram();
		mDiagram.mouseEnabled=false;
		mBack.addChild(mDiagram);
		
		
		//testGenerate(); //TODO: Remove when working properly.
		//this.width = HWUtils.screenWidth;
		//this.height = HWUtils.screenHeight;
		
		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		mTitle.text = "Forbrug i dag ";
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
		mTitle.selectable = false;
		
		
		
		mTimeButton = new TimeChangeButton([VIEWMODE_DAY, VIEWMODE_WEEK,VIEWMODE_MONTH,],mViewMode,onButtonPush); //Day, week, month.
		this.addChild(mTimeButton);//hack add on thisso that it will not dissapear when children removed
		
		mCoordSys = new CoordSystem();
		
		
		layout();
	}
	
	/**
	Places the graphical elements on the screen.
	**/
	private function layout() {
	
		

		while(mBack.numChildren > 0)
			mBack.removeChildAt(0);

		mTitle.width = mTitle.textWidth;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = Lib.stage.stageHeight/30;

		mBack.addChild(mTitle);

		mLegend = new Legend();
		mLegend.drawLegend(mBack.width/1.25,mBack.height/1.25,mColorArray.length,mRoomArray,mColorArray);

		mBack.addChild(mLegend);
	
	
		mDiagram.width = Lib.stage.stageWidth / 1.15;
		mDiagram.height = Lib.stage.stageHeight / 1.25;
		mDiagram.x = (Lib.stage.stageWidth - mDiagram.width) / 2;
		mDiagram.y = Lib.stage.stageHeight - ((Lib.stage.stageHeight - mDiagram.height)/2);	
		
		
		mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;
		mTimeButton.y = 0;
		
		mCoordSys.generate(Lib.stage.stageWidth/1.25, (Lib.stage.stageHeight/1.25)-mLegend.height, "X", "Y", (Lib.stage.stageWidth/1.25)/mtimeArray.length, ((Lib.stage.stageHeight/1.25)-mLegend.height)/mUsageArray.length, 
															mtimeArray, mUsageArray, true, false);
		mCoordSys.x = (Lib.stage.stageWidth- mCoordSys.width);
		mCoordSys.y = (Lib.stage.stageHeight/1.25)+50;

		mLegend.x =mCoordSys.x;
		mLegend.y = mCoordSys.y + mLegend.height;

		mBack.addChild(mCoordSys);

	}
	
	/*Gets data through DataInterface, then creates the diagram.*/
	private function fillWithData() {
	
		DataInterface.instance.requestArealDataToday(onDataReceivedDay);
		return;
		
		var outlets = DataInterface.instance.getAllOutlets();
		var colors = new Array<Int>();
		var usageAA =  new Array< Array<Float> >();
		for(t in outlets) {
			usageAA.push(DataInterface.instance.getOutletLastDayUsage(t));
			colors.push(DataInterface.instance.getOutletColor(t));
		}
		mDiagram.generate(usageAA, colors, 100,100);
		
	}	
	
	private function onDataReceivedDay(outletIds:Array<Int>, usage:Map<Int, Array<Float>>, colors:Map<Int, Int>) : Void {
		
		var _usage = new Array< Array<Float> >();
		var _colors = new Array<Int>();
		var _ta:Array<Float>;
		
		for(id in outletIds) {
			_ta = usage.get(id);
			while(_ta.length<96)
				_ta.push(0);
			if(_ta.length>96)
				_ta = _ta.slice(0,96);
				
			_usage.push(_ta);
			
			_colors.push(colors.get(id));
		}
		
		mDiagram.generate(_usage, _colors, 100,100);
		
	}
	
	/**Some test function.**/
	private function testGenerate() { 
		fillWithData();
	}
	
	private function onButtonPush(coordSystemType:Int):Void{

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
			mUsageArray = ["100Wt", "200Wt", "300wt","400Wt","500Wt", "600Wt","700Wt", "800Wt","900Wt","1000Wt"];
			mTitle.text = "Forbrug denne time";

		}
		if(mViewMode == 1){
			//day
			mUsageArray = ["1kWt  ", "2kWt  ", "3kWt  ","4kWt  ","5kWt  ", "6kWt  ","7kWt  ", "8kWt  ","9kWt  ","10kWt  "];
			mTitle.text = "Forbrug i dag";

		}
		if(mViewMode == 2){
			///week
			mUsageArray = ["10kWt ", "20kWt ", "30kWt ","40kWt ","50kWt ", "60kWt ","70kWt ", "80kWt ","90kWt ","100kWt "];
			mTitle.text = "Forbrug denne uge";

		}
		mTimeButton.changeButtonState(mViewMode);
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());

		layout();
		fillWithData();
	}



	private function getColorAndRoomData():Void{

			var outletData:Array<Outlet>;

			 outletData = DataInterface.instance.getOnOffData();

			//add unique rooms to the room array
		for(i in 0...outletData.length){

			var isPresent = false;

			for(count in 0...mRoomArray.length){
				
				if(mRoomArray[count]==outletData[i].getRoom()){
					//the category is present so we set the bool
					isPresent = true;
					break;
				}
				else{
					//the category was not present
					//TODO: HANDLE IT
				}
			}

			if(isPresent){
				//the category was preasent -> do not add
			}
			else{
				//the category was not present -> add to array
				mRoomArray.push(outletData[i].getRoom());
				mColorArray.push(outletData[i].roomColor);

			}

		}


	}

}



