package;

import flash.geom.Point;
import flash.display.Sprite;

class CircleSectorRenderer {

	//Draws a sector of a cirle onto the specified sprite in the specified color.
	//From and to are given in radians.
	public static function drawSector(sprite:Sprite, center:Point, radius:Float, from:Float, to:Float) {
	
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
	public static function sectorLabelPos(center:Point, radius:Float, from:Float, to:Float) : Point {
	
		return pointOnArc(center, radius, from + ((to-from)/2));
	
	}
	
	//Returns a point on a circle arc.
	//Think polar coords :-)
	private static function pointOnArc(center:Point, radius:Float, angle:Float) : Point {
		var r = new Point();
		r.x = (radius * Math.cos(angle)) + center.x;
		r.y = (radius * Math.sin(angle)) + center.y;
		return r;
	}

}


