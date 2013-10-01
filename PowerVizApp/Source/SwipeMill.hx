package ;

import motion.Actuate;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TouchEvent;
import flash.events.MouseEvent;

import HWUtils;



/*
Sipe mill, used for swipe between screens.
*/

class SwipeMill {

	public dynamic static function onScreenChange(newIndex:Int) {} //Override this to get screen change. 

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
	

	public static function init(parent:Sprite) {
		mObjects = new Array<DisplayObject>();
		createVisualElements(parent);
		registerEvents();
		mFingerDown = false;
		mScreenPos = 0.0;
	}
	
	public static function add(obj:DisplayObject) {
		mObjects.push(obj);
		positionObjects();
	}	
	
	
	
	private static function createVisualElements(parent:Sprite) {
		mTouchReceiver = new Sprite();
		mTouchReceiver.graphics.beginFill(0xFF00FF);
		mTouchReceiver.graphics.drawRect(0,0, 100, 100);
		mTouchReceiver.graphics.endFill();
		
		mTouchReceiver.width = HWUtils.screenWidth;
		mTouchReceiver.height = HWUtils.screenHeight;
		
		parent.addChild(mTouchReceiver);
	}
	
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
	
	static function get_screenPos() : Float {
		return mScreenPos;
	}
	static function set_screenPos(f:Float) : Float {
		mScreenPos = f;
		if(mScreenPos<0) {
			mScreenPos += mObjects.length;
		}
		positionObjects();
		return mScreenPos;
	}
	
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
	
	private static function onMakeScreenFitDone() {
		trace("Done tweening");
	}
	
	
	private static function onMouseDown(event:MouseEvent) {
		onTMDown(event.stageX);
	}
	
	private static function onTouchDown(event:TouchEvent) {
		onTMDown(event.stageX);
	}
	
	private static function onTMDown(x:Float) {
		mFingerDown = true;
		mStartX = Std.int(x);
		mStartScreenPos = mScreenPos;
		mStartScreenPosi = (mStartScreenPos % 1 > 0.5 ? Math.ceil(mStartScreenPos) : Math.ceil(mStartScreenPos));
		mDeltaX = 0;
		Actuate.stop(SwipeMill);
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
	}
	
	private static function onTouchLeave(event:TouchEvent) {
		onTMLeave();
	}
	
	private static function onMouseLeave(event:MouseEvent) {
		onTMLeave();
	}
	
	private static function onTMLeave() {
		mFingerDown = false;
		makeScreenFit();
	}

}



