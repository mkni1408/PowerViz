	import flash.display.Sprite;
import flash.display.Graphics;

class BarGraph extends Sprite {

	public function new() {
		super();
		
		drawBar([0x005B96, 0x6497B1, 0xB1DAFB, 0x741d0d, 0xc72a00, 0xff7f24, 0x669900, 0x7acf00, 0xc5e26d], 
				[100, 50, 200, 120, 15, 170, 10, 150, 80]);
		
	}	
	
	private function drawBar(colors:Array<Int>, height:Array<Int>) {
	
		//xCoord is used to create the first graph 5 pixels from the y-axis
		var xCoord:Float = 0;
		
		//rectWidth is used to make use that every rectangle has a width of 10pixels.
		var rectWidth:Int = 2;
		
		var i:Int = 0;
		for(c in colors) {
			
			this.graphics.beginFill(colors[i]);
			this.graphics.drawRect(xCoord, 0, rectWidth, -height[i]);			
			
			xCoord += 2.2; //Makes a space of 0.2 pixel between each Bar
			
			i += 1; //Increment by one
		}
	}


}
