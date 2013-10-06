import flash.display.Sprite;
import flash.display.Graphics;
import flash.Lib;

class BarGraph extends Sprite {

	public function new() {
		super();
		
	}	
	
	public function drawBar(colors:Array<Int>, height:Array<Float>) {
	
		//This variable was used to set the starting point of the first graph to 5px from y-axis
		var xCoord:Float = 0;
		
		//barWidth is used to ensure that every bar has the same width.
		var barWidth:Float = Lib.stage.stageWidth/colors.length;
		
		var i:Int = 0;
		for(c in colors) {
			this.graphics.beginFill(colors[i]);
			this.graphics.drawRect(xCoord, 0, barWidth, -height[i]);			
			
			xCoord += barWidth; 
			
			i += 1; //Increment by one
		}
	}


}
