import flash.display.Sprite;
import flash.display.Graphics;
import flash.Lib;

class BarGraph extends Sprite {

	public function new() {
		super();
		
	}	
	
	public function drawBar(colors:Array<Int>, height:Array<Float> ) {

		this.graphics.clear();
	
		//This is a hack, which draws a transparent rectangle of 1x1 pixel
		this.graphics.beginFill(0x000000,0.0);
		this.graphics.drawRect(0,0, 1,1);
		this.graphics.endFill();
		
		//barWidth is used to ensure that every bar has the same width.
		var barWidth:Float = Lib.stage.stageWidth/colors.length;
		
		//This variable is used as the starting point on the x-axis
		var xCoord:Float =(0.10*barWidth);
		
		var i:Int = 0;
		for(c in colors) {
			// For every c in colors a rectangle will be drawn and colored.
			this.graphics.beginFill(colors[i]);
			this.graphics.drawRect(xCoord, 0, barWidth*0.90, -height[i]);			
			this.graphics.endFill();
			
			//Increment with barWidth and not barWidth*0.90 (as in drawRect()) is to make a space between each bar.
			xCoord += barWidth; 
			
			i += 1; //Increment by one
		}
	}


}
