package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.Lib;

import DataInterface;
import ArealDiagram;
import FontSupply;
import TimeChangeButton;
import CoordSystem;

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
		
		
		mTimeButton = new TimeChangeButton([Time.HOUR, Time.WEEK],mViewMode,redrawCoordSystem); //Day, week, month.
		mBack.addChild(mTimeButton);
		
		mCoordSys = new CoordSystem();
		mBack.addChild(mCoordSys);
		
		layout();
	}
	
	/**
	Places the graphical elements on the screen.
	**/
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
															["0", "1", "2", "træ"], ["10", "20", "30"], true, false);
		mCoordSys.x = mDiagram.x;
		mCoordSys.y = mDiagram.y;
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
	
	private function redrawCoordSystem(coordSystemType:Int):Void{

		mCoordSys.graphics.clear();
	}
}



