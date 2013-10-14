import flash.display.Sprite;
import flash.display.Graphics;
import flash.Lib;
import flash.display.Bitmap;
import flash.geom.Rectangle;
import openfl.Assets;
import openfl.display.Tilesheet;
import Math;

class CoinGraph extends Sprite {

	public function new() {
		super();
		
	}	
	
	public function drawBarScreen(colors:Array<Int>, heightBars:Array<Float>, heightCoins:Array<Float>) {
		
		//This is a hack:
		this.graphics.beginFill(0x000000,0.0);
		this.graphics.drawRect(0,0, 1,1);
		this.graphics.endFill();
		
		//barWidth is used to ensure that every bar has the same width.
		var barWidth:Float = Lib.stage.stageWidth/colors.length;
		
		//This variable is used as the starting point on the x-axis
		var xCoord:Float =(barWidth*0.50);
		var yCoord:Float = -25;
				
		var i:Int = 0;
		for(c in colors) {
			xCoord += (barWidth * 0.50);
			drawCoinBar(xCoord, yCoord, barWidth, heightCoins[i]);
			xCoord -= (barWidth * 0.50);
			drawBar(xCoord, yCoord, barWidth, colors[i], heightBars[i]);
			xCoord += (barWidth*1.50);
			i += 1;
		}
	}
	
	//Draws all bars.
	public function drawBar(xCoord:Float, yCoord:Float, barWidth:Float, colors:Int, heightBars:Float) {
			
			this.graphics.beginFill(colors);
			this.graphics.drawRect(xCoord, 0, barWidth*0.48, -heightBars);			
			this.graphics.endFill(); 
			
	}
	
	public function drawCoinBar(xCoord:Float, yCoord:Float, barWidth:Float, height:Float) {
	
		var coinBitmap = Assets.getBitmapData("assets/enkrone_tilemap.png");
		var tileSheet = new Tilesheet(coinBitmap);
		tileSheet.addTileRect(new Rectangle(0,0, 150,81)); //0
		tileSheet.addTileRect(new Rectangle(0,82, 150,81)); //1
		tileSheet.addTileRect(new Rectangle(0,82*2, 150,81)); //2
		
		var coinStack = new Sprite();
		coinStack.width = barWidth * 0.40;
		var vspace = 5;
		var count=0;
		var y:Float = yCoord;
		var randX:Float;
		while(count < height/20) {
			randX = xCoord + ((Math.random()-0.5) * 8);
			tileSheet.drawTiles(coinStack.graphics, [randX, y, 0, 0.3], Tilesheet.TILE_SCALE);
			y -= vspace;
			count += 1;
		}
		
		this.addChild(coinStack);
		
	}
	
}
