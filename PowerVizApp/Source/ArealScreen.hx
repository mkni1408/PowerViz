package;

import flash.display.Sprite;
import flash.text.TextField;

import DataInterface;
import ArealDiagram;
import FontSupply;

/*
Screen displaying the Areal diagram.
Uses the ArealDiagram class for drawing the special diagram.

This class obtains data from the DataInterface singleton class.
*/

class ArealScreen extends Sprite {

	private var mBack : Sprite;
	private var mDiagram : ArealDiagram;
	private var mTitle : TextField;

	public function new() {
		super();
		
		mBack = new Sprite();
		mBack.graphics.beginFill(0xFFFFFF);
		mBack.graphics.drawRect(0,0, HWUtils.screenWidth, HWUtils.screenHeight);
		mBack.graphics.endFill();
		this.addChild(mBack);
		
		mDiagram = new ArealDiagram();
		mDiagram.mouseEnabled=false;
		mBack.addChild(mDiagram);
		
		testGenerate(); //TODO: Remove when working properly.
		//this.width = HWUtils.screenWidth;
		//this.height = HWUtils.screenHeight;
		
		mTitle = new TextField();
		mTitle.text = "Forbrug i dag ";
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
		mTitle.selectable = false;
		mBack.addChild(mTitle);
		
		layout();
	}
	
	private function layout() {
	
		//TODO: Fix the layout problems with this arealDiagram. Something is very strange. 
	
		mDiagram.width = mBack.width / 1.5;
		mDiagram.height = mBack.height / 1.5;
		mDiagram.x = (mBack.width - mDiagram.width) / 2;
		mDiagram.y = mBack.height - ((mBack.height - mDiagram.height)/1.1);
		//mDiagram.y = mBack.height;	
	
		mTitle.width = mTitle.textWidth;	
		mTitle.x = (mBack.width - mTitle.textWidth) / 2;
		mTitle.y = 50;
	}
	
	
	private function testGenerate() { 
	
		mDiagram.generate( [[2,3,4,5,6],[5,2,1,3,6],[6,1,3,2,1]] , [0xFF0000, 0x00FF00, 0x0000FF], 100, 100 );
	
	}
	

}



