package;


import flash.display.Sprite;
import flash.display.Graphics;
import flash.Lib;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import openfl.Assets;
import openfl.display.Tilesheet;
import Math;

/*
This class draws the CoinGraph.
*/

class CoinGraph extends Sprite {

	public function new() {
		super();
		
	}	
	
	/*
	This function is used to draw the bars and coinBars to the CoinScreen class.
	This function also specifies where each bar is placed on the x-axis. 
	*/
	public function drawCoinScreen(colors:Array<Int>, heightBars:Array<Float>, heightCoins:Array<Float>) {
		
		//This is a hack:
		this.graphics.beginFill(0x000000,0.0);
		this.graphics.drawRect(0,0, 1,1);
		this.graphics.endFill();
		
		//barWidth is used to ensure that every bar has the same width.
		var barWidth:Float = Lib.current.stage.stageWidth/colors.length;
		
		//This variable is used as the starting point on the x-axis
		var xCoord:Float =(barWidth*0.50);
		
		//This variable is used to position the bars correctly on the y-axis
		var yCoord:Float = -25;
		
		//Increment variable
		var i:Int = 0;
		
		/*
		The for loop runs for every value in colors to ensure that every element in the array is drawn.
		Some wierd issues occured when drawing the bars, and then drawing the coinBars.
		To solve these issues, the coinBars will be drawn first, and then the bars will be added.
		To ensure the correct positioning (e.g. coinBars after the Bars), a lot of addition and substraction is needed on the xCoord
		variable. 
		*/
		for(c in colors) {
			//Add the value of a half barWidth to xCoord, to get the correct position for the coinBar. 
			xCoord += (barWidth * 0.50);
			drawCoinBar(xCoord, yCoord, barWidth, heightCoins[i]);
			
			//Substract the value of a half barWidth to get the correct position for the Bar (place it infront of the coinBar).
			xCoord -= (barWidth * 0.50);
			drawBar(xCoord, yCoord, barWidth, colors[i], heightBars[i]);
			
			//Add barWidth*1.50 to xCoord to make a space between the coinBar and the next Bar 'section'
			xCoord += (barWidth*1.50);
			i += 1;
		}
	}
	
	//Draws all regular bars.
	private function drawBar(xCoord:Float, yCoord:Float, barWidth:Float, colors:Int, heightBars:Float) {
			
			this.graphics.beginFill(colors);
			this.graphics.drawRect(xCoord, 0, barWidth*0.48, -heightBars);			
			this.graphics.endFill(); 
			
	}
	
	//Draws all coinBars
	private function drawCoinBar(xCoord:Float, yCoord:Float, barWidth:Float, height:Float) {
	
		var coinBitmap = Assets.getBitmapData("assets/enkrone_tilemap.png");
		var tileSheet = new Tilesheet(coinBitmap);
		
		//Splits the tileSheet into three TileRects
		tileSheet.addTileRect(new Rectangle(0,0, 150,81)); //0
		tileSheet.addTileRect(new Rectangle(0,82, 150,81)); //1
		tileSheet.addTileRect(new Rectangle(0,82*2, 150,81)); //2
		
		var coinStack = new Sprite();
		
		//Make the coinStack.width match the size that is available.
		coinStack.width = barWidth * 0.40;
		
		//vertical space between images
		var vspace = 5;
		var count=0;
		var y:Float = yCoord;
		var randX:Float;
		while(count < height/20) {
			//randX is used to make the stack look randomized (e.g. some coins a bit more to the left/right, and some in the center)
			randX = xCoord + ((Math.random()-0.5) * 8);
			tileSheet.drawTiles(coinStack.graphics, [randX, y, 0, 0.3], Tilesheet.TILE_SCALE);
			y -= vspace;
			count += 1;
		}
		
		this.addChild(coinStack);
		
	}
	
}
