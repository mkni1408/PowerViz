import flash.display.Sprite;
import flash.text.TextField;
import flash.events.MouseEvent;

class Button extends Sprite{
	
public var mButtonID(default,null):Int;
private var mTitle : TextField;
private var mfunc:Int -> Void;


public function new(name:String, color:Int,id:Int,f:Int->Void){

		super();
		var s = new Sprite();
		s.graphics.beginFill(color);
		s.graphics.drawRect(0,0, 50,50);
		s.graphics.endFill();

		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		mTitle.text = name;
		mTitle.setTextFormat(FontSupply.instance.getButtonFormat());
		mTitle.selectable = false;
		mTitle.width = mTitle.textWidth+5;
		mTitle.height = mTitle.textHeight+5;
		s.addChild(mTitle);

		mTitle.x = (s.width/2)-(mTitle.width/2);
		mTitle.y = (s.height/2)-(mTitle.height/2);

		this.addChild(s);


		mButtonID = id;
		mfunc = f;

		this.addEventListener(MouseEvent.CLICK, buttonClicked);


}


public function buttonClicked(event:MouseEvent):Void{

	mfunc(mButtonID);

	trace("button clicked!");

}


}