package;

import flash.Lib;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.geom.Point;
import flash.events.MouseEvent;
import openfl.Assets;

import motion.Actuate;

import PowerTimer;
import DataInterface;


class ScreenSaver2 extends Sprite {
	
	private static inline var mRemoveInterval:Int = 10000; //Millisecs before unused bulb removal
	private static inline var mShuffleInterval:Int = 60000*10; //Millisecs between bulb shuffles. 10 minutes.
	private static inline var mScreenSaverSecs : Int = 5; //Seconds before the screensaver will start.
	
	private var mBackdrop : Bitmap;
	
	private var mBulbs : Array<Bulb2>;
	
	private var mLastTouchTime : Date;
	private var mUpdateTimer : PowerTimer;
	private var mRemoveTimer : PowerTimer; //Timer that removes a single unused bulb.
	
	private var mShuffleTimer : PowerTimer;
	
	
	public function new() {
		super();
		this.graphics.beginFill(0xFF00FF,0);
		this.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageHeight); //Draw frame area, to receive inputs from.
		this.graphics.endFill();
		
		mBackdrop = new Bitmap(Assets.getBitmapData("assets/background3.png"));
		mBackdrop.width = Lib.stage.stageWidth;
		mBackdrop.height = Lib.stage.stageHeight;
		this.addChild(mBackdrop);
		
		mBulbs = new Array<Bulb2>();
		Bulb2.initGrid(5,5);
		
		mUpdateTimer = new PowerTimer(1000);
		mUpdateTimer.onTime = update;
		mUpdateTimer.start();
		
		mRemoveTimer = new PowerTimer(mRemoveInterval); //every x seconds, a bulb that is not used will be removed.
		mRemoveTimer.onTime = removeABulbThatIsOff;
		mRemoveTimer.start();
		
		mShuffleTimer = new PowerTimer(mShuffleInterval);
		mShuffleTimer.onTime = function() {
			shuffleBulbs();
			};
		mShuffleTimer.start();
		
		mLastTouchTime = Date.now();
		
		//this.mouseEnabled = false;
		//this.mouseChildren = false;
		this.visible = false;
		
		this.addEventListener(MouseEvent.CLICK, onTouchScreenSaver);
		
		setBulbs();
		
	}
	
	//Update function invoked once a second.
	function update() {
		trace("Update");
		if(DateTools.delta(mLastTouchTime, DateTools.seconds(mScreenSaverSecs)).getTime() < Date.now().getTime()) {
			enableScreensaver();
		}
		setBulbs();
	}
	
	//Called from SwipeMill.
	public function onScreenTouch() : Void {
		mLastTouchTime = Date.now();
		disableScreensaver();
	}
	
	//Called when the user presses this ScreenSaver.
	function onTouchScreenSaver(event:MouseEvent) {
		disableScreensaver();
		mLastTouchTime = Date.now();
	}
	
	function enableScreensaver() {
		if(this.visible == true) //Already enabled.
			return; 
		
		this.visible = true;
		
		this.alpha=0;
		Actuate.tween(this, 5, {alpha:1});
		
	}
	
	function disableScreensaver() {
		if(this.visible == false) //Already disabled.
			return;
		this.visible = false;
	}
	
	
	//Turns the different bulbs on/off accordning to the current usage.
	//If there are too few bulbs, it will add more. 
	//If there are too many, the ones not needed will be turned off.
	function setBulbs() {
		var watts:Int = Std.int(DataInterface.instance.getTotalCurrentLoad());
		var bulbWatts = DataInterface.instance.bulbWatts;
		trace(watts);
		trace(bulbWatts);
		var count:Int = Std.int(watts/bulbWatts);
		if(count>mBulbs.length){ //Bulbs are missing, so create more.
			var newBulb : Bulb2;
			for(i in 0...(count - mBulbs.length)) {
				newBulb = Bulb2.createNewBulb();
				if(newBulb!=null) {
					this.addChild(newBulb);
					mBulbs.push(newBulb); //Creates a new bulb and pushes into the array.
				}
			}
		}
		trace(mBulbs);
		var wattCount = 0;
		for(b in mBulbs) {
			if(b!=null) {
				wattCount += bulbWatts;
				if(wattCount>watts)
					b.on = false;
				else
					b.on = true;
			}
		}
	}
	
	//Shuffles the position of the current visible bulbs. Does not add or remove any bulbs.
	function shuffleBulbs() {
		Bulb2.repositionBulbs(mBulbs);
	}
	
	//Removes a single specified bulb.
	function removeBulb(bulb:Bulb2) {
		if(bulb==null)
			return;
		//Fade out, then remove from array:
		Actuate.tween(bulb, 3, {alpha:0}).onComplete(function(){
			this.removeChild(bulb);
			mBulbs.remove(bulb);
			Bulb2.removeFromGrid(bulb);
			}
		);
	}
	
	//Finds a single bulb which is off, then removes it.
	function removeABulbThatIsOff() {
		for(b in mBulbs) {
			if(b!=null && b.on==false) {
				removeBulb(b);
				return;
			}
		}
	}
	
}

/**
A single bulb on the screen.
To place the bulbs at positions so that no two bulbs have the same position,
a simple Boolean grid is used to keep track of the placement of the different lightbulbs.
**/
class Bulb2 extends Sprite {
	
	//The bulb placement grid:
	private static var smGrid:Array<Bool>; //True if used, false if free.
	private static var smGridWidth : Int;
	private static var smGridHeight : Int;
	
	public static function initGrid(w:Int, h:Int) {
		smGrid = new Array<Bool>();
		for(i in 0...w) {
			for(j in 0...h) {
				smGrid.push(false);
			}
		}
		smGridWidth = w;
		smGridHeight = h;
	}
	
	//Returns a free random grid index.
	public static function findFreeGridIndex() : Int {
		if(Lambda.count(smGrid, function(b:Bool):Bool{ return !b; })==0) //If the grid does not contain free cells.
			return -1; //
			
		var randomVal:Int = Math.floor(Math.random()*smGrid.length); //Limit to grid size...
		while(smGrid[randomVal]==true) {
			randomVal = Math.floor(Math.random()*smGrid.length);
		}
		return randomVal;
	}
	
	//Translates a grid index into a 2D point.
	public static function indexToPoint(index:Int) : Point {
		
		var hspace = Lib.stage.stageWidth / (smGridWidth+2);
		var vspace = Lib.stage.stageHeight / (smGridHeight+2);
		
		return new Point(((index % smGridWidth)*hspace)+hspace,(Math.floor(index/smGridWidth)*vspace)+vspace);
	}
	
	//Creates a new bulb at an optimal position.
	public static function createNewBulb() : Bulb2{
		var index = findFreeGridIndex();
		if(index<0)
			return null;
		//Create the bulb, then set the cell in the grid to "used":
		var bulb = new Bulb2();
		var point = indexToPoint(index);
		bulb.setPos(point);
		smGrid[index] = true;
		bulb.mGridIndex = index;
		return bulb;
	}
	
	public static function repositionBulbs(bulbs:Array<Bulb2>) {
		for(i in 0...smGrid.length) {
			smGrid[i] = false; 
		}
		var index:Int;
		var point:Point;
		for(bulb in bulbs) {
			index = findFreeGridIndex();
			if(index<0)
				return;
			bulb.mGridIndex = index;
			smGrid[index] = true;
			point = indexToPoint(index);
			bulb.setPos(point);
		}
	}
	
	public static function removeFromGrid(bulb:Bulb2) {
		if(bulb.mGridIndex<0 || bulb.mGridIndex>=smGrid.length)
			return;
		smGrid[bulb.mGridIndex] = false;
	}
	
	
	//----------------------------------------
	
	private var mBitmapOn : Bitmap;
	private var mBitmapOff : Bitmap;
	public var on(get, set):Bool;
	private var _on : Bool;
	private var mGridIndex : Int;
	
	private var mUnitHeight:Int;
	
	public function new() {
		super();
		mBitmapOn = new Bitmap(Assets.getBitmapData("assets/bulbon.png"));
		mBitmapOff = new Bitmap(Assets.getBitmapData("assets/bulboff.png"));
		this.addChild(mBitmapOn);
		this.addChild(mBitmapOff);
		setSize();
		_on=true;
		this.alpha = 0;
		Actuate.tween(this, 2, {alpha:1});
	}
	
	function setSize() {
		var aspect = mBitmapOn.width / mBitmapOn.height;
		mBitmapOn.width = Lib.stage.stageWidth / 18;
		mBitmapOn.height = mBitmapOn.width / aspect;
		mBitmapOff.width = mBitmapOn.width;
		mBitmapOff.height = mBitmapOn.height;
	}
	
	function set_on(v:Bool) : Bool {
		_on = v;
		mBitmapOn.visible = _on;
		mBitmapOff.visible = !_on; //_on inverted.
		return _on;
	}
	function get_on() : Bool { return _on; }
	
	//Draws the power cord that "holds the bulb".
	function drawCord() {
		this.graphics.lineStyle(2, 0x000000);
		this.graphics.moveTo(mBitmapOn.width/2, 0);
		this.graphics.lineTo(mBitmapOn.width/2, -this.y);
	}
	
	public function setPos(point:Point) {
		var variance = (indexToPoint(1).x - indexToPoint(0).x) / 3;
		this.graphics.clear();
		this.x = point.x + (Math.random()*variance);
		this.y = point.y + (Math.random()*variance);
		drawCord();
	}

}