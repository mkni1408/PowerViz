
import flash.display.Sprite;

class ArealDiagram extends Sprite {

	private var mMaxValue : Float;

	public function new() {
		super();
	}
	
	/*
	Generates the ArealDiagram.
	values: An array of arrays of floats, where each value is a load in a specific point in time.
	colors: An array of colors used for visualizing/painting the different areas. 
	This function assumes, that all arrays in 'values' are of equal length.
	*/
	public function generate(values:Array< Array<Float> >, colors:Array<Int>, width:Float, height:Float) {
	
		var bottoms = new Array<Float>(); //Bottom values of the previous row.
		
		for(i in values[0]) 
			bottoms.push(0); //Start out by setting the bottom line to the bottom.
			
		//For each array, draw a polygon, where the bottom line is the bottoms line, and the top line is bottom+value.
		var i:Int=0;
		for(a in values) {
		
			bottoms = drawArea(bottoms, a, this.graphics, colors[i], width/values[0].length, 1); //Draw each area, getting the new bottom line.
			i += 1;
		}
	
		//this.width = width;
		//this.height = height;
		
		mMaxValue = highestAccumValue(values);
		
	}
	
	//Draws a single area. Returns the top edge of the area.
	private function drawArea(bottoms:Array<Float>, values:Array<Float>, gfx:flash.display.Graphics, color:Int, hspace:Float, vmult:Float) : Array<Float> {
	
		var topLine = new Array<Float>(); //The new bottom line. The return value of this function.
	
		var x:Float = 0; //x drawing position.
		var y:Float = 0; //y drawing position.
		var i:Int = 0; //Index into values.
	
		gfx.beginFill(color); //Start filling with the specified color.
		gfx.moveTo(0, bottoms[0]); //Move to the starting position.
		
		x=0; //Start of the line.
		i=0;
		for(b in bottoms) {
			gfx.lineTo(x, b); //Draw the bottom part
			topLine.push(b - (values[i]*vmult)); //Prepare the top line.
			x += hspace; //Next position.
			i+=1; //Increment index.
		}
		
		topLine.reverse(); //Reverse the topLine, since we are drawing it backwards.
		for(t in topLine) { 
			x -= hspace; //Moving backwards.
			gfx.lineTo(x, t); //Drawing each line segment.
		}
		
		gfx.endFill(); //Done drawing.
		
		topLine.reverse();
		return topLine;
		
	}
	
	/*Returns the highest accumulated value of all arrays passed.
	Used for calculating the max in the diagram.*/
	private function highestAccumValue(values:Array< Array<Float> >) : Float {
		
		var highest : Float = 0;
	
		var i:Int=0;
		var accum:Float=0;
		while(i<values[0].length) {
			accum=0;
			for(v in values) {
				accum += v[i];		
			}	
			i += 1;
		}
		return highest;
	}
	
}



