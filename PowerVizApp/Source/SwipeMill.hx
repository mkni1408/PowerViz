package;

import motion.Actuate;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.TouchEvent;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import flash.Lib;

import PowerTimer;
import Enums; //From PowerVizCommon.
import DataInterface;


/*
Swipe mill, used for swipe between screens.

This is basically a DisplayObject container that receives input events, and then cycles through the
elements contained.

To get a notice when a new DisplayElement is on focus, replace the onScreenChange() function from outside this class.

*/

class SwipeMill {

	public dynamic static function onScreenChange(newIndex:Int) {} //Replace/override/substute this to get screen change. 
	public dynamic static function onScreenTouch() : Void {}

	private static var mSwipeDeltaMin:Int = 200;

	private static var mObjects:Array<DisplayObject>;
	private static var mTouchReceiver:Sprite;
	private static var mFingerDown : Bool;
	private static var mScreenPos:Float; 
	public static var screenPos(get,set):Float;
	
	//Used for keeping track for the swipe motion:
	private static var mStartScreenPos:Float; 
	private static var mStartScreenPosi:Int;
	private static var mStartX:Int;
	private static var mPrevX:Int; //Previous x position of the mouse/touch.
	private static var mDeltaX:Int;
	
	//Graphics for representing interacion information:
	private static var mArrows : SwipeArrows;
	private static var mSwipeDots : SwipeDots;
	

	/*Initializes the SwipeMill. Call this ONCE, preferebly in the main sprite constuctor.*/
	public static function init(parent:Sprite) {
		mObjects = new Array<DisplayObject>();
		createVisualElements(parent);
		registerEvents();
		mFingerDown = false;
		mScreenPos = 0.0;
		mStartX = 0;
		mPrevX = 0;
		mDeltaX = 0;
	}
	
	/*Add a single display element to the SwipeMill.*/
	public static function add(obj:DisplayObject) {
		mTouchReceiver.addChild(obj);
		mObjects.push(obj);
		positionObjects();
		mSwipeDots.addDot();
	}	
	
	/**Removes all screens from the SwipeMill.**/
	public static function clear() {
		for(s in mObjects) {
			mTouchReceiver.removeChild(s);
			mSwipeDots.clear();
		}
		mObjects = new Array<DisplayObject>();
	}
	
	
	//Internal function. Create the sprite elements used for receiving touch/mouse events.
	private static function createVisualElements(parent:Sprite) {
		mTouchReceiver = new Sprite();
		mTouchReceiver.graphics.beginFill(0xFF00FF, 0);
		mTouchReceiver.graphics.drawRect(0,0, Lib.current.stage.stageWidth, Lib.current.stage.stageWidth);
		mTouchReceiver.graphics.endFill();
		
		
		parent.addChild(mTouchReceiver);
		
		mArrows = new SwipeArrows();
		parent.addChild(mArrows);
		mArrows.onLeftClick = onLeftArrow;
		mArrows.onRightClick = onRightArrow;
		
		mSwipeDots = new SwipeDots();
		mSwipeDots.x = Lib.current.stage.stageWidth / 2;
		mSwipeDots.y = Lib.current.stage.stageHeight / 2;
		parent.addChild(mSwipeDots);
	}
	
	
	/*Registers all events that the SwipeMill is listening for.*/
	private static function registerEvents() {
		#if desktop
			mTouchReceiver.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			mTouchReceiver.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			mTouchReceiver.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			mTouchReceiver.addEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);
			
		#end
		
		#if mobile
			mTouchReceiver.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDown);
			mTouchReceiver.addEventListener(TouchEvent.TOUCH_END, onTouchUp);
			mTouchReceiver.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			mTouchReceiver.addEventListener(TouchEvent.TOUCH_OUT, onTouchLeave);
		#end
	}
	
	/*Returns the current position. Position 1 is screen one, 2 screen two etc.
	Therefore, when position is 1.5, the position is in the midle between screen one and two.*/
	static function get_screenPos() : Float {
		return mScreenPos;
	}
	/*Sets the screen position. See comment above.*/
	static function set_screenPos(f:Float) : Float {
		
		mScreenPos = f;
		
		if(mScreenPos < 0)
			mScreenPos = 0;
		if(mScreenPos >= mObjects.length-1)
			mScreenPos = mObjects.length-1;
		
		positionObjects();
		setArrowsVisibility();
			
		return mScreenPos;
		
	}
	
	/*Internal function. Positions all the DisplayObjects.*/
	private static function positionObjects() {
	
		var i = 0;
		for(obj in mObjects) {
			obj.x = (i - mScreenPos)*obj.width;
			i+=1;
		}
		
		if(mSwipeDots!=null)
			mSwipeDots.setActive(mScreenPos);
		
	}
	
	/*Internal function. Makes the DisplayObjects "move" to the correct position.
	Uses the Actuate tweening library.*/
	private static function makeScreenFit() {
		var newScreen : Int = 0; //TODO - for sending events.
		var to:Float=0;
		
		if(mScreenPos % 1 > 0.5) {
			to = (mScreenPos - (mScreenPos % 1)+1);
			//motion.Actuate.tween(SwipeMill, 1, {screenPos : (mScreenPos - (mScreenPos % 1)+1) } );
		}
		else {
			to = (mScreenPos - (mScreenPos % 1));
			//motion.Actuate.tween(SwipeMill, 1, {screenPos : (mScreenPos - (mScreenPos % 1)) } );
		}
		motion.Actuate.tween(SwipeMill, 1, {screenPos : to}).onComplete(SwipeMill.onMakeScreenFitDone, []);
		
		
		if(to != mStartScreenPosi) {
			//trace(mScreenPos);
			onScreenChange(Std.int(to));
		}
		
	}
	
	/*Called when the tween effect ends. Purpose unknown.*/
	private static function onMakeScreenFitDone() {
		//trace("onMakeScreenFitDone() - " + mScreenPos);
		DataInterface.instance.logInteraction(LogType.ScreenChange, Std.string(screenPos), "Changed to screen " + screenPos);
	}
	
	private static function setArrowsVisibility() {
		if(mScreenPos<0.1) {
			mArrows.showLeft(false);
			mArrows.showRight(true);
		}
		else if(mScreenPos>(mObjects.length-1)-0.1) {
			mArrows.showLeft(true);
			mArrows.showRight(false);
		}
		else {
			mArrows.showLeft(true);
			mArrows.showRight(true);
		}
	}
	
	
	//Listener for the mouse down event.
	private static function onMouseDown(event:MouseEvent) {
		onTMDown(event.stageX);
	}
	
	//Listener for the touch down event.
	private static function onTouchDown(event:TouchEvent) {
		onTMDown(event.stageX);
	}
	
	//Actual functionality for mouse/touch down events.
	private static function onTMDown(x:Float) {
		mFingerDown = true; //Set the finger to currently down.
		mStartX = Std.int(x); 
		mStartScreenPos = mScreenPos;
		mStartScreenPosi = (mStartScreenPos % 1 > 0.5 ? Math.ceil(mStartScreenPos) : Math.ceil(mStartScreenPos)); //Start screen position in integers.
		mDeltaX = 0;
		Actuate.stop(SwipeMill); //Stop any tweening that might be going on.
		onScreenTouch();
		mSwipeDots.showDots();
	}
	
	private static function onMouseUp(event:MouseEvent) {
		onTMUp(event.stageX);
	}
	
	private static function onTouchUp(event:TouchEvent) {
		onTMUp(event.stageX);
	}
	
	private static function onTMUp(x:Float) {
		mFingerDown = false;
		makeScreenFit();
		onScreenTouch();
		mSwipeDots.hideDots();
	}
	
	private static function onMouseMove(event:MouseEvent) {
		onTMMove(event.stageX);
	}
	
	private static function onTouchMove(event:TouchEvent) {
		onTMMove(event.stageX);
	}
	
	private static function onTMMove(x:Float) {
		if(mFingerDown) {
			mDeltaX = Std.int(x - mStartX);
			screenPos = mStartScreenPos - (mDeltaX / Lib.current.stage.stageWidth);
		}
	}
	
	private static function onTouchLeave(event:TouchEvent) {
		onTMLeave();
	}
	
	private static function onMouseLeave(event:MouseEvent) {
		onTMLeave();
	}
	
	private static function onTMLeave() {
		mFingerDown = false;
		makeScreenFit(); //When the finger leaves the screen, make the screen tween into correct position.
	}
	
	private static function onLeftArrow() {
		Actuate.stop(SwipeMill, "screenPos");
		Actuate.tween(SwipeMill, 0.75, {screenPos:Math.floor(screenPos-1)}).onComplete(makeScreenFit); 
		mSwipeDots.showDots();
		mSwipeDots.hideDots();
		onScreenTouch();
	}
	
	private static function onRightArrow() {
		Actuate.stop(SwipeMill, "screenPos");
		Actuate.tween(SwipeMill, 0.75, {screenPos:Math.floor(screenPos+1)}).onComplete(makeScreenFit);
		mSwipeDots.showDots();
		mSwipeDots.hideDots();
		onScreenTouch();
	}

}

class SwipeArrows extends Sprite {

	private var mLeftArrow : Sprite;
	private var mRightArrow : Sprite;

	public function new() {
		super();
		draw();
		registerEvents();
	}
	
	private function registerEvents() {
		mLeftArrow.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent){onLeftClick();});
		mRightArrow.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent){onRightClick();});
	}
	
	private function draw() {
		mLeftArrow = new Sprite();
		drawArrow(mLeftArrow.graphics, Lib.current.stage.stageWidth/20, Lib.current.stage.stageHeight/4);
		mLeftArrow.alpha=0.1;
		mLeftArrow.y = Lib.current.stage.stageHeight/2;
		mRightArrow = new Sprite();
		drawArrow(mRightArrow.graphics, Lib.current.stage.stageWidth/20, Lib.current.stage.stageHeight/4);
		mRightArrow.rotation = 180;
		mRightArrow.alpha=0.1;
		mRightArrow.x = Lib.current.stage.stageWidth;
		mRightArrow.y = Lib.current.stage.stageHeight/2;
		this.addChild(mLeftArrow);
		this.addChild(mRightArrow);
	}
	
	private function drawArrow(gfx:Graphics, w:Float, h:Float) {
		gfx.beginFill(0x000000);
		gfx.moveTo(w,-(h/2));
		gfx.lineTo(w,h/2);
		gfx.lineTo(0,0);
		gfx.lineTo(w,-(h/2));
		gfx.endFill();
	}
	
	public function showLeft(b:Bool) {
		mLeftArrow.visible = b;
	}
	
	public function showRight(b:Bool) {
		mRightArrow.visible = b;
	}
	
	dynamic public function onLeftClick() { trace("Left arrow clicked."); }
	dynamic public function onRightClick() { trace("Right arrow clicked"); }
	
}

class SwipeDots extends Sprite {

	private var mDots:Array<Sprite>;
	private var mActive:Int;

	public function new() {
		super();
		mDots = new Array<Sprite>();
		mActive = 0;
	}
	
	public function addDot() {

		var newDot = createDot();
		mDots.push(newDot);
		this.addChild(newDot);	
		arrangeDots();
		setActive(mActive);
		
	}
	
	public function clear() {
		for(d in mDots) {
			this.removeChild(d);
		}
		mDots = new Array<Sprite>();
	}
	
	public function setActive(curScreen:Float) {
	
		var oldVal = mActive;
	
		var newVal:Int = (curScreen - Math.floor(curScreen))<0.5 ? Math.floor(curScreen) : Math.ceil(curScreen);
		if(newVal<0)
			newVal=0;
		if(newVal>=mDots.length)
			newVal = 0 + (newVal - mDots.length);
		
		mActive = newVal;
		setDotAlpha(mActive);
		
	}
	
	private function arrangeDots() {
		var dotWidth = mDots[0]!=null ? mDots[0].width : 16;
		var totalWidth = (mDots.length*dotWidth) + ((mDots.length-1)*dotWidth);
		var dotSpace = Std.int(dotWidth / 2);
		
		var x:Int = -Std.int((totalWidth/2));
		for(i in 0...mDots.length) {
			mDots[i].x = x;
			x += Std.int(dotWidth)+dotSpace;
		}
	}
	
	private function createDot() : Sprite {
		var dot = new Sprite();
		dot.graphics.beginFill(0x0000A0);
		/*
		dot.graphics.drawCircle(0,0, Lib.current.stage.stageWidth/100);
		*/
		var w:Float = Lib.current.stage.stageWidth/20;
		var h:Float = Lib.current.stage.stageHeight/20;
		dot.graphics.drawRect(w/2, h/2, w,h);
		dot.graphics.endFill();
		dot.mouseEnabled = false;
		return dot;
	}
	
	public function showDots() {
		//trace("showDots");
		this.visible=true;
		Actuate.apply(this, {alpha:1});
	}
	
	public function hideDots() {
		//trace("hideDots");
		Actuate.tween(this, 2, {alpha:0}, false).delay(1);
	}
	
	public function setDotAlpha(active:Int) {
		for(i in 0...mDots.length) {
			Actuate.apply(mDots[i], {alpha:0.3});
			if(i == active) {
				Actuate.apply(mDots[i], {alpha:1});
			}
		}
	}
	

}







