package;

import openfl.Assets;
import flash.display.Sprite;
import flash.display.Bitmap;

import DataVBarDisplay;	
import SwipeMill;
import HWUtils;
import ScreenSaver;
import DataInterface;

//Main class which extends a sprite(sprite as in a display object) 
class Main extends Sprite {
	
	//constructor - instantiates new SwipeMill object. 
	public function new () {
		
		super ();
		
		SwipeMill.init(this);	
		SwipeMill.onScreenChange = this.onScreenChange;
		
		prepareSwipeTest();
	}
	
	//prepares the swipetest, we add images to the swipemill
	public function prepareSwipeTest() {
		//test
		//var screenSaver = new ScreenSaver();
		//SwipeMill.add(screenSaver);
		addImageToSwipeTest("assets/bulb.png");
		addImageToSwipeTest("assets/testimg/01.png");
		addImageToSwipeTest("assets/testimg/02.png");
		addImageToSwipeTest("assets/testimg/03.png");
		addImageToSwipeTest("assets/testimg/04.png");
		addImageToSwipeTest("assets/testimg/05.png");
		SwipeMill.screenPos = 1.0;
	}
	//the actual adding of the images, we get image, we get 
	//add image to swipemill  
	private function addImageToSwipeTest(img:String) {
		var image = new Bitmap(Assets.getBitmapData(img));
		image.width = HWUtils.screenWidth;
		image.height = HWUtils.screenHeight;
		this.addChild(image);
		SwipeMill.add(image);
	}
	
	
	private function onScreenChange(newIndex:Int) {
		trace("onScreenChange(" + newIndex + ")");
	}
	
}



