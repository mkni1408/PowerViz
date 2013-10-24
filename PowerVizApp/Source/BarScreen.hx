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

	private var mBack : Sprite;
	private var mBarGraph : BarGraph;
	private var mTitle : TextField;
	private var mTimeButton : TimeChangeButton;
	private var mCoordSys : CoordSystem;
	private var mNewIDArray : Array<String>;
	private var mKwhArray : Array<String>;
	private var mRoomArray : Array<String>;
	private var mColorArray : Array <Int>;

	public function new() {
		super();
		
		trace("--");
				
		mNewIDArray = new Array<String>();
		mKwhArray = new Array<String>();
		mRoomArray = new Array<String>();
		mColorArray = new Array<Int>();
		
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
		
		mTimeButton = new TimeChangeButton([Time.HOUR, Time.WEEK]); //Day, week, month.
		mBack.addChild(mTimeButton);
		
		trace("--");
		
		layout();
		
		trace("--");
	}
	
	private function layout() {
	
		mTitle.width = mTitle.textWidth;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 20;
	
	
		mBarGraph.width = Lib.stage.stageWidth / 1.15;
		mBarGraph.height = Lib.stage.stageHeight / 1.25;
		mBarGraph.x = (Lib.stage.stageWidth - mBarGraph.width) / 2;
		mBarGraph.y = Lib.stage.stageHeight - ((Lib.stage.stageHeight - mBarGraph.height)/2);	
		
		trace("--");
		
		mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;
		mTimeButton.y = Lib.stage.stageHeight - mTimeButton.height;
	
		trace("--");
		
		mCoordSys.generate(mBarGraph.width, mBarGraph.height, "X", "Y", mBarGraph.width/9, mBarGraph.height/5, mNewIDArray, mKwhArray, true, false);
		mCoordSys.x = mBarGraph.x;
		mCoordSys.y = mBarGraph.y;
		trace("--");
		//mCoordSys.createLegend(mNewIDArray.length, mNewIDArray, [0x005B96, 0x6497B1, 0xB1DAFB, 0x741d0d, 0xc72a00, 0xff7f24, 0x669900, 0x7acf00, 0xc5e26d]);
	}
	
	private function fillWithData() {
	
		var outlets = DataInterface.instance.getAllOutlets();
		var colors = new Array<Int>();
		var usageAA =  new Array<Float>();
		for(t in outlets) {
			usageAA.push(DataInterface.instance.getOutletLastDayTotal(t));
			colors.push(DataInterface.instance.getOutletColor(t));
		}
		
		mBarGraph.drawBar(colors, usageAA);
		
	}

}



