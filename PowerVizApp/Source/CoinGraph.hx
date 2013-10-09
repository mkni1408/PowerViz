import flash.display.Sprite;
import flash.display.Graphics;
import flash.Lib;
import flash.display.Bitmap;
import openfl.Assets;
import Math;

class CoinGraph extends Sprite {

	public function new() {
		super();
		
	}	
	
	public function drawBar(colors:Array<Int>, heightBars:Array<Float>, heightCoins:Array<Float>) {
	
		//This is a hack:
		this.graphics.beginFill(0x000000,0.0);
		this.graphics.drawRect(0,0, 1,1);
		this.graphics.endFill();
		
		//barWidth is used to ensure that every bar has the same width.
		var barWidth:Float = Lib.stage.stageWidth/colors.length;
		
		//This variable is used as the starting point on the x-axis
		var xCoord:Float =(0.10*barWidth);
		
		var i:Int = 0;
		for(c in colors) {
			this.graphics.beginFill(colors[i]);
			this.graphics.drawRect(xCoord, 0, barWidth*0.40, -heightBars[i]);			
			this.graphics.endFill();
			
			xCoord += barWidth*0.45;
			
			drawCoinBar(xCoord, barWidth, heightCoins[i]);
			
			xCoord += barWidth*0.55; 
			
			i += 1; //Increment by one
		}
	}
	
	public function drawCoinBar(xCoord:Float, barWidth:Float, height:Float) {
		
		
		
		var mCoinStack : Sprite = new Sprite();
		//var mCoinStackTop : Sprite = new Sprite();
		
		var bitmapCoinStack:Bitmap;
		
		var mModHeight:Int = Math.ceil(height / 25);
		
		switch(mModHeight) {
			case 1:
				bitmapCoinStack = new Bitmap(Assets.getBitmapData("assets/coinTest/CoinStack1.png"));
				mCoinStack.x = xCoord;
				mCoinStack.y = -8;
				bitmapCoinStack.height = 7.5;
			case 2:
				bitmapCoinStack = new Bitmap(Assets.getBitmapData("assets/coinTest/CoinStack2.png"));
				mCoinStack.x = xCoord;
				mCoinStack.y = -10;
				bitmapCoinStack.height = 10;
			case 3:
				bitmapCoinStack = new Bitmap(Assets.getBitmapData("assets/coinTest/CoinStack3.png"));
				mCoinStack.x = xCoord;
				mCoinStack.y = -12;
				bitmapCoinStack.height = 12;
			case 4:
				bitmapCoinStack = new Bitmap(Assets.getBitmapData("assets/coinTest/CoinStack4.png"));
				mCoinStack.x = xCoord;
				mCoinStack.y = -15;
				bitmapCoinStack.height = 15;
			case 5:
				bitmapCoinStack = new Bitmap(Assets.getBitmapData("assets/coinTest/CoinStack5.png"));
				mCoinStack.x = xCoord;
				mCoinStack.y = -18;
				bitmapCoinStack.height = 18;
			case 6:
				bitmapCoinStack = new Bitmap(Assets.getBitmapData("assets/coinTest/CoinStack6.png"));
				mCoinStack.x = xCoord;
				mCoinStack.y = -21;
				bitmapCoinStack.height = 21;
			case 7:
				bitmapCoinStack = new Bitmap(Assets.getBitmapData("assets/coinTest/CoinStack7.png"));
				mCoinStack.x = xCoord;
				mCoinStack.y = -25;
				bitmapCoinStack.height = 25;
			case 8:
				bitmapCoinStack = new Bitmap(Assets.getBitmapData("assets/coinTest/CoinStack8.png"));
				mCoinStack.x = xCoord;
				mCoinStack.y = -30;
				bitmapCoinStack.height = 30;
			default:
				bitmapCoinStack = null;
		}
		
		bitmapCoinStack.width = barWidth*0.45;
				
		mCoinStack.addChild(bitmapCoinStack);
		
		this.addChild(mCoinStack);
		
	}
	
}
