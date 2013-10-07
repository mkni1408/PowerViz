import flash.display.Sprite;
import flash.display.Graphics;
import flash.Lib;

class BarGraph extends Sprite {

	public function new() {
		super();
		
	}	
	
	public function drawBar(colors:Array<Int>, height:Array<Float>) {
	
		//This is a hack:
		this.graphics.beginFill(0x000000,0.0);
		this.graphics.drawRect(0,0, 1,1);
		this.graphics.endFill();
		
		//barWidth is used to ensure that every bar has the same width.
		var barWidth:Float = Lib.stage.stageWidth/colors.length;
		
		//This variable is used as the starting point on the x-axis
		var xCoord:Float =(0.25*barWidth);
		
		var i:Int = 0;
		for(c in colors) {
			this.graphics.beginFill(colors[i]);
			this.graphics.drawRect(xCoord, 0, barWidth*0.75, -height[i]);			
			this.graphics.endFill();
			xCoord += barWidth; 
			
			i += 1; //Increment by one
		}
	}


}
