package;

import openfl.Assets;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.Lib;

import DataVBarDisplay;	
import SwipeMill;
import ScreenSaver;
import DataInterface;
import BarScreen;
import CurrentUsage;
import CoinScreen;
import OnOffDiagram;

//Main class which extends a sprite(sprite as in a display object) 
class Main extends Sprite {

	private var mScreenSaver : ScreenSaver = null;
	private var mArealScreen : ArealScreen = null;
	private var mBarScreen : BarScreen = null;
	private var mCurrentUsage : CurrentUsage = null;
	private var mCoinScreen : CoinScreen = null;
	private var mOnOff: OnOffDiagram = null;
	
	//constructor - instantiates new SwipeMill object. 
	public function new () {
		
		super ();
		
		SwipeMill.init(this);	
		SwipeMill.onScreenChange = this.onScreenChange;
		
		prepareSwipeTest();

		//add screensaver to the main sprite
		mScreenSaver = new ScreenSaver();
		addChild(mScreenSaver);

		SwipeMill.onScreenTouch = mScreenSaver.onScreenTouch;

		
	}
	
	//prepares the swipetest, we add images to the swipemill
	public function prepareSwipeTest() {
		
		mOnOff = new OnOffDiagram();
		SwipeMill.add(mOnOff);

		mArealScreen = new ArealScreen();
		SwipeMill.add(mArealScreen);
		
		mBarScreen = new BarScreen();
		SwipeMill.add(mBarScreen);

		mCurrentUsage = new CurrentUsage();
		SwipeMill.add(mCurrentUsage);
		
		mCoinScreen = new CoinScreen();
		SwipeMill.add(mCoinScreen);

		

		SwipeMill.screenPos = 0.0; //Set to the first screen.
	}
	//the actual adding of the images, we get image, we get 
	//add image to swipemill  
	private function addImageToSwipeTest(img:String) {
		var image = new Bitmap(Assets.getBitmapData(img));
		image.width = Lib.stage.stageWidth;
		image.height = Lib.stage.stageHeight;
		//this.addChild(image);
		SwipeMill.add(image);
	}
	
	
	private function onScreenChange(newIndex:Int) {
		trace("onScreenChange(" + newIndex + ")");
	}
	
}



