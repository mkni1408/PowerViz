package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.Lib;

import DataInterface;
import ArealDiagram;
import FontSupply;
import TimeChangeButton;
import CoordSystem;

/*
Screen displaying the Areal diagram.
Uses the ArealDiagram class for drawing the special diagram.

This class obtains data from the DataInterface singleton class.
*/

class ArealScreen extends Sprite {

	private static inline var VIEWMODE_DAY:Int = 0;
	private static inline var VIEWMODE_WEEK:Int = 1;
	private static inline var VIEWMODE_MONTH:Int = 2;

	private var mBack : Sprite;
	private var mDiagram : ArealDiagram;
	private var mCoordSys : CoordSystem;
	private var mTitle : TextField;
	private var mTimeButton : TimeChangeButton;
	
	private var mViewMode:Int;

	public function new() {
		super();
		
		mViewMode = VIEWMODE_DAY; //Daymode by default.
		
		mBack = new Sprite();
		mBack.graphics.beginFill(0xFFFFFF);
		mBack.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageWidth);
		mBack.graphics.endFill();
		this.addChild(mBack);
		
		mDiagram = new ArealDiagram();
		mDiagram.mouseEnabled=false;
		mBack.addChild(mDiagram);
		
		
		testGenerate(); //TODO: Remove when working properly.
		//this.width = HWUtils.screenWidth;
		//this.height = HWUtils.screenHeight;
		
		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		mTitle.text = "Forbrug i dag ";
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
		mTitle.selectable = false;
		mBack.addChild(mTitle);
		
		
		mTimeButton = new TimeChangeButton([Time.HOUR, Time.WEEK]); //Day, week, month.
		mBack.addChild(mTimeButton);
		
		mCoordSys = new CoordSystem();
		mBack.addChild(mCoordSys);
		
		layout();
	}
	
	private function layout() {
	
		mTitle.width = mTitle.textWidth;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = Lib.stage.stageHeight/30;
	
	
		mDiagram.width = Lib.stage.stageWidth / 1.15;
		mDiagram.height = Lib.stage.stageHeight / 1.25;
		mDiagram.x = (Lib.stage.stageWidth - mDiagram.width) / 2;
		mDiagram.y = Lib.stage.stageHeight - ((Lib.stage.stageHeight - mDiagram.height)/2);	
		
		
		mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;
		mTimeButton.y = Lib.stage.stageHeight - mTimeButton.height;
		
		mCoordSys.generate(mDiagram.width, mDiagram.height, "X", "Y", mDiagram.width/24, mDiagram.height/10, 
															["0", "1", "2", "3"], ["10", "20", "30"], true, false);
		mCoordSys.x = mDiagram.x;
		mCoordSys.y = mDiagram.y;
	}
	
	/*Gets data through DataInterface, then creates the diagram.*/
	private function fillWithData() {
	
		var houseId:Int = 0; //TODO: Change this to the real HouseID:
		var outlets = DataInterface.instance.getAllOutlets(houseId);
		var colors = new Array<Int>();
		var usageAA =  new Array< Array<Float> >();
		for(t in outlets) {
			usageAA.push(DataInterface.instance.getOutletLastDayUsage(houseId, t));
			colors.push(DataInterface.instance.getOutletColor(houseId, t));
		}
		
		mDiagram.generate(usageAA, colors, 100,100);
		
	}	
	
	
	private function testGenerate() { 
		fillWithData();
	
	}
	

}



