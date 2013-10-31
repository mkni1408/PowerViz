
import flash.display.Sprite;

class ArealDiagram extends Sprite {

	public var maxValue(default,null) : Float;

	public function new() {
		super();
	}
	
	/*
	Generates the ArealDiagram.
	values: An array of arrays of floats, where each value is a load in a specific point in time.
	colors: An array of colors used for visualizing/painting the different areas. 
	This function assumes, that all arrays in 'values' are of equal length.
	*/
	public function generate(values:Array< Array<Float> >, colors:Array<Int>, width:Float, height:Float):Void {
		//remove children
		//trace(values);

		if(values.length<1 || values[0].length<1)
			return;
			
		//Clear before drawing:
		this.graphics.clear();

		
	
		var bottoms = new Array<Float>(); //Bottom values of the previous row.
		
		bottoms[values[0].length-1] = 0;//hack MEGAHACK <- Og Tue lavede det!
		/*
		for(i in values[0]) 
			bottoms.push(0); //Start out by setting the bottom line to the bottom.
		*/
			
		//For each array, draw a polygon, where the bottom line is the bottoms line, and the top line is bottom+value.
		var i:Int=0;
		for(a in values) {
			//trace("width",width);
			//bottoms = drawArea(bottoms, a, this.graphics, colors[i], width/values[0].length, 1); //Draw each area, getting the new bottom line.
			bottoms = drawArea2(bottoms, a, this.graphics, colors[i], 30, 1);
			
			i += 1;
		}
		
		maxValue = highestAccumValue(values);

		trace("MAXVALUE",maxValue);
		
	}
	
	//Draws a single area. Returns the top edge of the area.
	/*private function drawArea(bottoms:Array<Float>, values:Array<Float>, 
								gfx:flash.display.Graphics, color:Int, hspace:Float, vmult:Float) : Array<Float> {
	
		var topLine = new Array<Float>(); //The new bottom line. The return value of this function.
	
		var x:Float = 0; //x drawing position.
		var y:Float = 0; //y drawing position.
		var i:Int = 0; //Index into values.
		
		gfx.beginFill(color); //Start filling with the specified color.
		gfx.moveTo(0, bottoms[0]); //Move to the starting position.
			
		x=0; //Start of the line.
		i=0;
		var v:Float=0;
		for(b in bottoms) {
			#if cpp
				v = b;
			#else
				v = b==null ? 0 : b;
			#end


			gfx.lineTo(x, v); //Draw the bottom part. Take into consideration, that something might be null.
			topLine.push(v - (values[i]*vmult)); //Prepare the top line.
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
	
	
	Draws a single area. Returns the top edge of the area.
	This is an alternate implementation of the drawing method. The original method above 
	turned out to be slightly glitchy, so a new method is implemented here.
	This function draws using triangles in stead of the complex polygons used above.
	The result is perfect triangulation.
	*/
	private function drawArea2(bottoms:Array<Float>, values:Array<Float>, 
								gfx:flash.display.Graphics, color:Int, hspace:Float, vmult:Float) : Array<Float> {
								
			var topLine = new Array<Float>();
			
		
			for(i in 0...bottoms.length) {
				#if cpp
					topLine[i] = bottoms[i] - (values[i]*vmult);
					//trace("c++");
				#else
					topLine[i] = (bottoms[i]==null ? 0 : bottoms[i]) - (values[i]*vmult);
					//trace("neko");
				#end
			}
			
			var triangles = new Array<Float>();
			var indices = new Array<Int>();
			var first:Int = 0; //First index used inside the loop.
			
			var x:Float = 0;
			for(j in 0...topLine.length-1) { //Generate points and indices:
				triangles.push(x);
					
				triangles.push(topLine[j]);
				
				triangles.push(x+hspace);
				triangles.push(topLine[j+1]);
				
				triangles.push(x+hspace);
				triangles.push(bottoms[j+1]);
				
				triangles.push(x);
				triangles.push(bottoms[j]);
				
				first = j*4; //First index for the two triangles.
				
				indices.push(first); //Push indices for the two triangles.
				indices.push(first+1);
				indices.push(first+2);
				indices.push(first);
				indices.push(first+3);
				indices.push(first+2);
				//trace("X",x);
				x += hspace; //Move to next drawing position.
			}
			gfx.beginFill(color);
			gfx.drawTriangles(triangles, indices); //Draw generated triangles.
			gfx.endFill();
			
			return topLine;
	}
	
	/*Returns the highest accumulated value of all arrays passed.
	Used for calculating the max in the diagram.
	Very usefull for determining the scaling of the coordinates.
	*/
	private function highestAccumValue(values:Array< Array<Float> >) : Float {
		
		var totals = new Array<Float>(); //All values accumulated.
		
		var i:Int = 0;
		for(a in values) { //Accumulate the values.
			i = 0;
			for(v in a) {
				#if cpp
					totals[i] = totals[i] + v;
				#else
					totals[i] = (totals[i]==null ? v : totals[i] + v); //The heart of the accumulation.
				#end
				i += 1;
			}
		}
		
		var highest:Float = 0;
		for(t in totals) { //Find the highest among the accumulated values.
			if(t > highest)
				highest = t;
		}
		if(highest == 0){
			highest = 1;
		}
		return highest;
		
	}
	
}


