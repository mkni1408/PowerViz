package;

import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;

//import CircleSectorRenderer;

/*
A circle diagram. 
Usage:
Create a new CircleDiagram instance, then call the generate method to prepare it for display.
When calling generate on an already generated diagram, the existing diagram will be 
removed and a new generated from scratch.
*/

class CircleDiagram extends Sprite {

	private var mRadius:Float;
	private var mLabels:Array<TextField>;

	public function new() {
		super();
		mLabels = new Array<TextField>();
		mRadius = 100;
	}
	
	public function generate(values:Array<Float>, labels:Array<String>, colors:Array<Int>, ?labelPostfix:String, ?percent:Bool) {
	
		this.graphics.clear();
	
		var total:Float=0;
		for(f in values) {
			total += f;
		}
		
		var point = new Point(0,0);
		var labelPoints = new Array<Point>();
		
		var index:Int=0;
		var rad:Float=0;
		var prevRad:Float=0;
		var prevVal:Float=0;
		for(v in values) {
			rad = valueToRadians(prevVal + v, total);
			this.graphics.beginFill(colors[index]);
			drawSector(this, point, mRadius, prevRad, rad); //Draw sector.
			labelPoints.push(sectorLabelPos(point, mRadius*0.7, prevRad, rad)); //Calculate sector label position.
			this.graphics.endFill();
			prevRad = rad;
			prevVal = prevVal + v;
			index += 1;
		}
		
		generateLabels(labelPoints, values, total, percent==null ? false : percent, labelPostfix==null ? "" : labelPostfix);
	
	}
	
	private function generateLabels(points:Array<Point>, values:Array<Float>, total:Float, percent:Bool, postfix:String) {
		
		for(L in mLabels) {
			this.removeChild(L);
		}
		
		var format = new TextFormat();
		format.font = "Arial";
		format.color = 0x000000;
		format.size = 20;
		format.bold = true;
		
		var text:TextField;
		var index = 0;
		for(p in points) {
			text = new TextField();
			text.text = "" + (percent ? valueToPercent(values[index], total) : values[index]);
			text.text = text.text.substr(0, 4);
			text.text += (percent ? "%" : postfix);
			this.addChild(text);
			mLabels.push(text); //Save object for easier removal at a later time.
			text.setTextFormat(format);
			text.selectable = false;
			text.width = text.textWidth*1.2;
			text.height = text.textHeight;
			text.x = p.x - (text.width/2);
			text.y = p.y - (text.height/2);
			index += 1;
		}
	}
	
	private function valueToRadians(value:Float, total:Float) : Float {
		
		return (value/total) * 6.283185307;
		
	}
	
	private function valueToPercent(value:Float, total:Float) : Float {
		return (value/total) * 100.0;
	}
	
	public function setRadius(r:Float) {
		mRadius = r;
	}
	
	
	//Draws a sector of a cirle onto the specified sprite in the specified color.
	//From and to are given in radians.
	private static function drawSector(sprite:Sprite, center:Point, radius:Float, from:Float, to:Float) {
	
		//Move the draw cursor to the center.
		//For each point on the arc, use the lineTo() method.
		//Finish by making a lineTo() to the center of the circle.
		
		sprite.graphics.moveTo(center.x, center.y);
		var count:Float = from;
		var poa:Point;
		while(count<to) {
			poa = pointOnArc(center, radius, count);
			sprite.graphics.lineTo(poa.x, poa.y);
			count += 0.1;
		}
		poa = pointOnArc(center, radius, to);
		sprite.graphics.lineTo(poa.x, poa.y);
		sprite.graphics.lineTo(center.x, center.y);
		
	}

	//Calculates the position of the sector label.	
	private static function sectorLabelPos(center:Point, radius:Float, from:Float, to:Float) : Point {
	
		return pointOnArc(center, radius, from + ((to-from)/2));
	
	}
	
	//Returns a point on a circle arc.
	//Think polar coords :-)
	private static function pointOnArc(center:Point, radius:Float, angle:Float) : Point {
		/*
		var r = new Point();
		r.x = (radius * Math.cos(angle)) + center.x;
		r.y = (radius * Math.sin(angle)) + center.y;
		return r;
		*/
		var p = Point.polar(radius, angle);
		p.x += center.x;
		p.y += center.y;
		return p;
	}
	

}
