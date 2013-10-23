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
		var unpressed = new Bitmap (Assets.getBitmapData ("assets/button_unpressed.png"));
		var pressed = new Bitmap (Assets.getBitmapData ("assets/button_pressed.png"));
		//s.graphics.beginFill(color);
		//s.graphics.drawRect(0,0, 50,50);
		//s.graphics.endFill();
		mPressedButton.addChild(pressed);
		mUnpressedButton.addChild(unpressed);

		this.addChild(mPressedButton);
		this.addChild(mUnpressedButton);

		this.mPressedButton.visible = false;
		this.mUnpressedButton.visible = true;

		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		mTitle.text = name;
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

	trace("button clicked!");

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