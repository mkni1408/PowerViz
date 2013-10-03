package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.Lib;

import DataInterface;
import ArealDiagram;
import FontSupply;
import TimeChangeButton;

/*
Screen displaying the Areal diagram.
Uses the ArealDiagram class for drawing the special diagram.

This class obtains data from the DataInterface singleton class.
*/

class ArealScreen extends Sprite {

	private var mBack : Sprite;
	private var mDiagram : ArealDiagram;
	private var mTitle : TextField;
	private var mTimeButton : TimeChangeButton;

	public function new() {
		super();
		
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
		
		layout();
	}
	
	private function layout() {
	
		mTitle.width = mTitle.textWidth;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 50;
	
	
		mDiagram.width = Lib.stage.stageWidth / 1.15;
		mDiagram.height = Lib.stage.stageHeight / 1.25;
		mDiagram.x = (Lib.stage.stageWidth - mDiagram.width) / 2;
		mDiagram.y = Lib.stage.stageHeight - ((Lib.stage.stageHeight - mDiagram.height)/2);	
		
		
		mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;
		mTimeButton.y = Lib.stage.stageHeight - mTimeButton.height;
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



