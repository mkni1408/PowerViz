package;

import openfl.Assets;
import flash.display.Sprite;
import flash.display.Bitmap;

import DataVBarDisplay;	
import SwipeMill;
import HWUtils;
import ScreenSaver;
import DataInterface;
import BarScreen;
import CurrentUsage;
import CoinScreen;

//Main class which extends a sprite(sprite as in a display object) 
class Main extends Sprite {

	private var mScreenSaver : ScreenSaver = null;
	private var mArealScreen : ArealScreen = null;
	private var mBarScreen : BarScreen = null;
	private var mCurrentUsage : CurrentUsage = null;
	private var mCoinScreen : CoinScreen = null;
	
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
		//test
		
		//addImageToSwipeTest("assets/bulb.png");
		addImageToSwipeTest("assets/testimg/01.png");
		addImageToSwipeTest("assets/testimg/02.png");
		addImageToSwipeTest("assets/testimg/03.png");
		addImageToSwipeTest("assets/testimg/04.png");
		addImageToSwipeTest("assets/testimg/05.png");
		
		mArealScreen = new ArealScreen();
		SwipeMill.add(mArealScreen);
		
		mBarScreen = new BarScreen();
		SwipeMill.add(mBarScreen);

		mCurrentUsage = new CurrentUsage();
		SwipeMill.add(mCurrentUsage);
		
		mCoinScreen = new CoinScreen();
		SwipeMill.add(mCoinScreen);

		SwipeMill.screenPos = 6.0; //Set to the first screen.
	}
	//the actual adding of the images, we get image, we get 
	//add image to swipemill  
	private function addImageToSwipeTest(img:String) {
		var image = new Bitmap(Assets.getBitmapData(img));
		image.width = HWUtils.screenWidth;
		image.height = HWUtils.screenHeight;
		//this.addChild(image);
		SwipeMill.add(image);
	}
	
	
	private function onScreenChange(newIndex:Int) {
		trace("onScreenChange(" + newIndex + ")");
	}
	
}



