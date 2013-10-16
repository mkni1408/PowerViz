
import flash.display.Sprite;

/*
ExtCoordinate System class.
This class makes it simple to create a coordinate system.
All it takes to work is a size, spacings and sets of labels.

Also it does nothing, so it should be erased - MKN
*/

class CoordSystem extends Sprite {

	public var pointxonYAxis:Array<Float>;

	public var pointyonYAxis:Array<Float>;

	public function new() {
		super();
	}
	
	public function generate(width:Float, height:Float, xLabel:String, yLabel:String, xSpace:Float, ySpace:Float,
							?xLabelStrings:Array<String>) {
	
		this.graphics.lineStyle(3, 0x000000);
		this.graphics.moveTo(0,0);
		this.graphics.lineTo(0, -height);
		this.graphics.moveTo(0,0);
		this.graphics.lineTo(width, 0);
		
		var numLinesY:Int = Std.int(height/ySpace);
		var y:Float=0;
		for(i in 0...numLinesY) {
			y -= ySpace;
			this.graphics.moveTo(-5, y);
			this.graphics.lineTo(5, y);
		}
		
		var numLinesX:Int = Std.int(width/xSpace);
		var x:Float=0;
		for(j in 0...numLinesX) {
			x += xSpace;
			this.graphics.moveTo(x, -5);
			this.graphics.lineTo(x, 5);
		}
	
	}
	

}
