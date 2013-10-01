package;

import openfl.Assets;
import flash.display.Sprite;
import flash.display.Bitmap;

import DataVBarDisplay;	
import SwipeMill;
import HWUtils;


class Main extends Sprite {
	
	
	public function new () {
		
		super ();
		
		SwipeMill.init(this);	
		SwipeMill.onScreenChange = this.onScreenChange;
		
		prepareSwipeTest();
	}
	
	
	public function prepareSwipeTest() {
		addImageToSwipeTest("assets/testimg/01.png");
		addImageToSwipeTest("assets/testimg/02.png");
		addImageToSwipeTest("assets/testimg/03.png");
		addImageToSwipeTest("assets/testimg/04.png");
		addImageToSwipeTest("assets/testimg/05.png");
		SwipeMill.screenPos = 1.6;
	}
	
	private function addImageToSwipeTest(img:String) {
		var image = new Bitmap(Assets.getBitmapData(img));
		var data = Assets.getBitmapData(img);
		trace(data.rect);
		image.width = HWUtils.screenWidth;
		image.height = HWUtils.screenHeight;
		this.addChild(image);
		SwipeMill.add(image);
	}
	
	private function onScreenChange(newIndex:Int) {
		trace("onScreenChange(" + newIndex + ")");
	}
	
}



