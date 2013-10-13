
import flash.display.Sprite;
import flash.text.TextField;

import FontSupply;

/*
Coordinate System class.
This class makes it simple to create a coordinate system.
All it takes to work is a size, spacings and sets of labels.
*/

class CoordSystem extends Sprite {

	public function new() {
		super();
	}
	
	/**
	Generates the coordinate system sprite.
	width and height are the width and height of the coordninate system.
	xSpace and ySpace is the space between measuring lines horizontally and vertically.
	The optional labelStrings arrays are the labels for each element on the different axis.
	xLabelsBetween and yLabelsBetween indicate if the labels on the axes should be on the lines or between then.
	**/
	public function generate(width:Float, height:Float, xLabel:String, yLabel:String, xSpace:Float, ySpace:Float,
							?xLabelStrings:Array<String>, ?yLabelStrings:Array<String>, ?xLabelsBetween:Bool, ?yLabelsBetween:Bool) {
	
		this.graphics.lineStyle(3, 0x000000);
		this.graphics.moveTo(0,0);
		this.graphics.lineTo(0, -height);
		this.graphics.moveTo(0,0);
		this.graphics.lineTo(width, 0);
		
		var betweenX:Bool = (xLabelsBetween==null ? false : xLabelsBetween);
		var betweenY:Bool = (yLabelsBetween==null ? false : yLabelsBetween);
		
		
		var numLinesY:Int = Std.int(height/ySpace);
		var y:Float=0;
		var labelIndex:Int=0;
		var labelText = "";
		for(i in 0...numLinesY) { //Draw the Y axis.
			y -= ySpace;
			this.graphics.moveTo(-5, y);
			this.graphics.lineTo(5, y);
			
			if(yLabelStrings!=null) { //y labels exist.
				labelText = (yLabelStrings.length<=labelIndex ? "" : yLabelStrings[labelIndex]);
				if(labelText!="")
					addTextField(0, (betweenY ? y + (ySpace/2) : y), labelText, true);
			}
			labelIndex+=1;
		}
		
		var numLinesX:Int = Std.int(width/xSpace);
		var x:Float=0;
		labelIndex=0;
		for(j in 0...numLinesX) { //Draw the X axis.
			x += xSpace;
			this.graphics.moveTo(x, -5);
			this.graphics.lineTo(x, 5);
			
			if(xLabelStrings!=null) { //Oh, we've got strings.
				labelText = (xLabelStrings.length<=labelIndex ? "" : xLabelStrings[labelIndex]);
				if(labelText!="")
					addTextField((betweenX ? x - (xSpace/2) : x), 0, labelText, false);
			}
			
			labelIndex += 1;
		}
	
	}
	
	private function addTextField(x:Float, y:Float, text:String, vertical:Bool) {
		
		var tf = new TextField();
		tf.mouseEnabled = false;
		tf.selectable = false;
		tf.text = text;
		tf.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
		this.addChild(tf);
		tf.width = (tf.textWidth*1.1) + 5;
		tf.height = (tf.textHeight * 1.1) + 5;
		
		if(vertical) {
			tf.x = x - (tf.width + 3);
			tf.y = y - (tf.height/2);
		}
		else{
			tf.x = x - (tf.width/2);
			tf.y = y + 3;
		}
	}
	

}
