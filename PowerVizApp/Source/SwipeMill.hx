package ;

import motion.Actuate;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TouchEvent;
import flash.events.MouseEvent;

import HWUtils;



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
	

	/*Initializes the SwipeMill. Call this ONCE, preferebly in the main sprite constuctor.*/
	public static function init(parent:Sprite) {
		mObjects = new Array<DisplayObject>();
		createVisualElements(parent);
		registerEvents();
		mFingerDown = false;
		mScreenPos = 0.0;
	}
	
	/*Add a single display element to the SwipeMill.*/
	public static function add(obj:DisplayObject) {
		mTouchReceiver.addChild(obj);
		mObjects.push(obj);
		positionObjects();
	}	
	
	
	//Internal function. Create the sprite elements used for receiving touch/mouse events.
	private static function createVisualElements(parent:Sprite) {
		mTouchReceiver = new Sprite();
		mTouchReceiver.graphics.beginFill(0xFF00FF);
		mTouchReceiver.graphics.drawRect(0,0, HWUtils.screenWidth, HWUtils.screenHeight);
		mTouchReceiver.graphics.endFill();
		
		//mTouchReceiver.width = HWUtils.screenWidth;
		//mTouchReceiver.height = HWUtils.screenHeight;
		
		parent.addChild(mTouchReceiver);
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
	
	/*Returns the current position. Position 1 is screen, 2 screen two etc.
	Therefore, when position is 1.5, the position is in the midle between screen one and two.*/
	static function get_screenPos() : Float {
		return mScreenPos;
	}
	/*Sets the screen position. See comment above.*/
	static function set_screenPos(f:Float) : Float {
		mScreenPos = f;
		if(mScreenPos<0) {
			mScreenPos += mObjects.length;
		}
		positionObjects();
		return mScreenPos;
	}
	
	/*Internal function. Positions all the DisplayObjects.*/
	private static function positionObjects() {
		
		if(mScreenPos>=mObjects.length) {
			mScreenPos -= mObjects.length;
		}
		
		if(mScreenPos < -1) {
			mScreenPos += mObjects.length;
		}
		
		var i = 0;
		for(obj in mObjects) {
			obj.x = (i - mScreenPos)*obj.width;
			i+=1;
		}
		
		if(mScreenPos>(mObjects.length-1)) {
			mObjects[0].x = (i - mScreenPos)*mObjects[0].width;
		}
		
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
			onScreenChange(Std.int(to));
		}
	}
	
	/*Called when the tween effect ends. Purpose unknown.*/
	private static function onMakeScreenFitDone() {
		//trace("Done tweening");
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
			screenPos = mStartScreenPos - (mDeltaX / HWUtils.screenWidth);
		}
		onScreenTouch();
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

}



