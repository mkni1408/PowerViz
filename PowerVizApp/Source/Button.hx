 package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.display.Bitmap;
import openfl.Assets;

class Button extends Sprite{
	
public var mButtonID(default,null):Int;
private var mTitle : TextField;
private var mfunc:Int -> Void;
private var mUnpressedButton:Sprite;
private var mPressedButton:Sprite;


public function new(name:String, color:Int,id:Int,f:Int->Void){

		super();

		mUnpressedButton = new Sprite();
		mPressedButton = new Sprite();
		//var s = new Sprite();
		
		var pressed : Bitmap = null;
		var unpressed : Bitmap = null;
		
		
		switch(id) {
			case 0:
				unpressed = new Bitmap (Assets.getBitmapData ("assets/hour_unpressed.png"));
				pressed = new Bitmap (Assets.getBitmapData ("assets/hour_pressed.png"));
				
			case 1:
				unpressed = new Bitmap (Assets.getBitmapData ("assets/day_unpressed.png"));
				pressed = new Bitmap (Assets.getBitmapData ("assets/day_pressed.png"));
				
			case 2:
				unpressed = new Bitmap (Assets.getBitmapData ("assets/week_unpressed.png"));
				pressed = new Bitmap (Assets.getBitmapData ("assets/week_pressed.png"));
				
			default:
				unpressed = new Bitmap (Assets.getBitmapData ("assets/button_unpressed.png"));
				pressed = new Bitmap (Assets.getBitmapData ("assets/button_pressed.png"));
		}
		
		pressed.smoothing = true; //Smooth if scaled.
		unpressed.smoothing = true;
		
		mPressedButton.addChild(pressed);
		mUnpressedButton.addChild(unpressed);
		
		//var unpressed = new Bitmap (Assets.getBitmapData ("assets/button_unpressed.png"));
		//var pressed = new Bitmap (Assets.getBitmapData ("assets/button_pressed.png"));
		//s.graphics.beginFill(color);
		//s.graphics.drawRect(0,0, 50,50);
		//s.graphics.endFill();

		mPressedButton.width = 72;
		mPressedButton.height = 72;


		mUnpressedButton.width = 72;
		mUnpressedButton.height = 72;

		this.addChild(mPressedButton);
		this.addChild(mUnpressedButton);

		this.mPressedButton.visible = false;
		this.mUnpressedButton.visible = true;
		
		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		//mTitle.text = name;
		mTitle.setTextFormat(FontSupply.instance.getButtonFormat());
		mTitle.selectable = false;
		mTitle.width = mTitle.textWidth+5;
		mTitle.height = mTitle.textHeight+5;
		this.addChild(mTitle);

		mTitle.x = (this.width/2)-(mTitle.width/2);
		mTitle.y = (this.height/2)-(mTitle.height/2);

		//this.addChild(s);


		mButtonID = id;
		mfunc = f;

		this.addEventListener(MouseEvent.CLICK, buttonClicked);


}


public function buttonClicked(event:MouseEvent):Void{

	mfunc(mButtonID);

	//haxelibvtrace("button clicked!");

}

public function chageState(pressed:Bool):Void{

	if(pressed){

		this.mPressedButton.visible = true;
		this.mUnpressedButton.visible = false;

	}
	else{

		this.mPressedButton.visible = false;
		this.mUnpressedButton.visible = true;
	}


}


}