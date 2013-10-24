package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.Lib;

import DataInterface;
import CoinGraph;
import FontSupply;
import TimeChangeButton;
import CoordSystem;

/*
Screen displaying the Coin Graph.
Uses the CoinGraph class for drawing the special diagram.
*/

class CoinScreen extends Sprite {

	private static inline var VIEWMODE_DAY:Int = 0;
	private static inline var VIEWMODE_WEEK:Int = 1;
	private static inline var VIEWMODE_MONTH:Int = 2;
	private var mBack : Sprite;
	private var mCoinGraph : CoinGraph;
	private var mTitle : TextField;
	private var mTimeButton : TimeChangeButton;
	private var mCoordSys : CoordSystem;
	private var mViewMode:Int;
	

	public function new() {
		super();
		
		mBack = new Sprite();
		mBack.graphics.beginFill(0xFFFFFF);
		mBack.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageWidth);
		mBack.graphics.endFill();
		this.addChild(mBack);
		mViewMode = VIEWMODE_DAY;
		
		mCoinGraph = new CoinGraph();
		mBack.addChild(mCoinGraph);
		mCoinGraph.mouseChildren = false;
		mCoinGraph.mouseEnabled = false;
				
		mTitle = new TextField();
		mTitle.mouseEnabled = false;
		mTitle.text = "Forbrug i dag ";
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
		mTitle.selectable = false;
		mBack.addChild(mTitle);
		
		fillWithData();
		
		mCoordSys = new CoordSystem();
		mBack.addChild(mCoordSys);
		mCoordSys.mouseChildren = false;
		mCoordSys.mouseEnabled = false;
		
		mTimeButton = new TimeChangeButton([Time.HOUR, Time.WEEK],mViewMode,redrawCoordSystem); //Day, week, month.
		mBack.addChild(mTimeButton);
		
		layout();
		
	}
	
	private function layout() {
	
		mTitle.width = mTitle.textWidth;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 20;
	
	
		mCoinGraph.width = Lib.stage.stageWidth / 1.15;
		mCoinGraph.height = Lib.stage.stageHeight / 1.25;
		mCoinGraph.x = (Lib.stage.stageWidth - mCoinGraph.width) / 2;
		mCoinGraph.y = Lib.stage.stageHeight - ((Lib.stage.stageHeight - mCoinGraph.height)/2);	
		
		
		mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;
		mTimeButton.y = Lib.stage.stageHeight - mTimeButton.height;
		
		mCoordSys.generate(mCoinGraph.width, mCoinGraph.height, "X", "Y", mCoinGraph.width/9, mCoinGraph.height/5);
		mCoordSys.x = mCoinGraph.x;
		mCoordSys.y = mCoinGraph.y;
	}
	
	/*Gets data through DataInterface, then creates the diagram.*/
	private function fillWithData() {
	
		var outlets = DataInterface.instance.getAllOutlets();
		var colors = new Array<Int>();
		var usageAA =  new Array<Float>();
		for(t in outlets) {
			usageAA.push(DataInterface.instance.getOutletLastDayTotal(t));
			colors.push(DataInterface.instance.getOutletColor(t));
		}
		
		mCoinGraph.drawCoinScreen(colors, usageAA, usageAA);
		
	}

	private function redrawCoordSystem(coordSystemType:Int):Void{

		mCoordSys.graphics.clear();
	}

}



