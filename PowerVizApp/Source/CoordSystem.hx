
import flash.display.Sprite;
import flash.text.TextField;
import FontSupply;
import OnOffData;

/*
Coordinate System class.
This class makes it simple to create a coordinate system.
All it takes to work is a size, spacings and sets of labels.
*/

class CoordSystem extends Sprite {

	private var xCoordinates : Array<Float>;
	private var yCoordinates : Array<Float>;
	private var yHeight : Float;
	private var xHeight : Float;
	private var xWidth : Float;
	private var VerticalBars: Sprite;

	public function new() {
		super();
		xCoordinates = new Array<Float>();
		yCoordinates = new Array<Float>();
		VerticalBars = new Sprite();
		this.addChild(VerticalBars);
	}
	
	/**
	Generates the coordinate system sprite.
	width and height are the width and height of the coordninate system.
	xSpace and ySpace is the space between measuring lines horizontally and vertically.
	The optional labelStrings arrays are the labels for each element on the different axis.
	xLabelsBetween and yLabelsBetween indicate if the labels on the axes should be on the lines or between then.
	**/
	public function generate(width:Float, height:Float, xLabel:String, yLabel:String, xSpace:Float, ySpace:Float,
							?xLabelStrings:Array<String>, ?yLabelStrings:Array<String>, ?xLabelsBetween:Bool, ?yLabelsBetween:Bool, ?xLabelVertical:Bool) {
	

		var counterArray = new Array<Int>();
		this.graphics.clear();
		
		//ensure that there is no children 
		while(this.numChildren > 0)
			this.removeChildAt(0);


		this.graphics.lineStyle(3, 0x000000);
		this.graphics.moveTo(0,0);
		this.graphics.lineTo(0, -height);
		this.graphics.moveTo(0,0);
		this.graphics.lineTo(width, 0);
		
		var betweenX:Bool = (xLabelsBetween==null ? false : xLabelsBetween);
		var betweenY:Bool = (yLabelsBetween==null ? false : yLabelsBetween);
		var xVertical:Bool = (xLabelVertical==null ? false : xLabelVertical);
		
		
		var numLinesY:Int = Std.int(height/ySpace);
		yHeight = ySpace;
		var y:Float=0;
		var labelIndex:Int=0;
		var labelText = "";
		addYcoordinate(y);
		for(i in 0...numLinesY) { //Draw the Y axis.
			
			y -= ySpace;
			addYcoordinate(y);
			
			this.graphics.moveTo(-5, y);
			this.graphics.lineTo(5, y);
			
			if(yLabelStrings!=null) {
				labelText = (yLabelStrings.length<=labelIndex ? "" : yLabelStrings[labelIndex]);
				if(labelText!="")
					addTextField(0, (betweenY ? y + (ySpace/2) : y), labelText, true,false);
					//add the ycoordinate
					
			}
			labelIndex+=1;
		}
		
		
		var numLinesX:Int = Std.int(width/xSpace);
		xWidth = width;
		xHeight = xSpace;
		var x:Float=0;
		labelIndex=0;
		addXcoordinate(x);
		for(j in 0...numLinesX) { //Draw the X axis.
			
			x += xSpace;
			addXcoordinate(x);
			this.graphics.moveTo(x, -5);
			this.graphics.lineTo(x, 5);
		
			if(xLabelStrings!=null) {
				labelText = (xLabelStrings.length<=labelIndex ? "" : xLabelStrings[labelIndex]);
		
				if(labelText!="")

					//condition to handle vertical textfields
					if(xVertical){
					addTextField(x-(xSpace/2),0, labelText, false,xVertical);
					//add the xcoordinate
					}
					else{
						addTextField((betweenX ? x - (xSpace/2) : x), 0, labelText, false,false);
					}
				}
			
			labelIndex += 1;
		}
	
		this.mouseEnabled = false;	
	
	}
	
	private function addTextField(x:Float, y:Float, text:String, between:Bool, vertical:Bool) {

			
		var tf = new TextField();
		var txt = haxe.Utf8.encode(text); //Encode into utf8, since that is the only format that the textFormat accepts in C++.
		tf.mouseEnabled = false;
		tf.selectable = false;
		//maximizing input to 7 chars
		if(txt.length <= 7){
			tf.text = txt;
		}
		else{	
			tf.text = txt.substr(0,7);
		}
		
		tf.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());

		this.addChild(tf);
		tf.width = (tf.textWidth*1.1) + 5;
		tf.height = (tf.textHeight * 1.1);
		if(between) {
			tf.x = x - (tf.width + 3);
			tf.y = y - (tf.height/2);
			if(vertical)
			{
			//tf.rotation = 90;
		}
		}
		else{
			tf.x = (x - (tf.height/2))+(xHeight/2);
			tf.y = y + 3;
			if(vertical)
			{
				//trace("new X==",x);
			tf.rotation = 90;	
		}

		}
		//trace("tf",tf.x);
	}

	private function addXcoordinate(x:Float):Void{

		xCoordinates.push(x);
		//trace("pushing x coordinate",x);
	} 

	public function getXcoordinate(x:Int):Float{


		return xCoordinates[x];
	}
	
	private function addYcoordinate(y:Float):Void{

		yCoordinates.push(y);
		//	trace("pushing y coordinate",y);

	} 

	public function getYcoordinate(y:Int):Float{
		//y=y+1;

		return yCoordinates[y];
	}
	public function getXwidth():Float{

		return xWidth;
	}
	public function getHeight():Float{


		return yHeight;
	}

		//draws an onoffbar given a from and to X coordinate and an Y coordinate 
		//pointXfrom is the time that the contact went on converted to a float pointXto is 
		//the time the contact was shut off
		public function drawBar(pointXfrom:OnOffData, pointYfrom:Float,pointYto:Float,color:Int){

			//just sanitising the input
			/*
			if(pointXfrom>=24.0 )
			{
				pointXfrom = 23.99;

			}
			if(pointXfrom<=0.0 )
			{
				pointXfrom = 0.01;

			}
			if(pointXto>=24.0 )
			{
				pointXto = 23.99;

			}
			if(pointXto<=0.0 )
			{
				pointXto = 0.01;

			}*/
			//var date =Date.fromString("2013-10-21 10:15:00");

			this.graphics.lineStyle(1, 0x000000);
			this.graphics.beginFill(color);
			//this.graphics.drawRect(convertTime(pointXfrom.getStart()),pointYfrom+5.0, convertTime(pointXfrom.getStop())-convertTime(pointXfrom.getStart()), yHeight-10.0);
			this.graphics.drawRect(convertTime(pointXfrom.getStart()),pointYfrom+5.0, convertTime(pointXfrom.getStop())-convertTime(pointXfrom.getStart()), yHeight-10.0);

			this.graphics.endFill();


		}
		//generates the seperator lines
		public function generateSeperatorLines(pointYfrom:Int,pointUbefore:Int,roomLabel:String):Void{

			var pointY = getYcoordinate(pointYfrom); 

			this.graphics.lineStyle(3, 0x000000);
			this.graphics.moveTo(0, pointY);

			this.graphics.lineTo(xWidth, pointY);

			

			

		}
		public function generateSeperatorTextFields(y:Int,ybef:Int,roomLabel:String):Void{
			
			var yPoint = getYcoordinate(y); 
			var yPointbef = getYcoordinate(ybef);

			var half = (yPoint - yPointbef)/2;

			addTextField(xWidth+100, yPointbef+half, roomLabel, true, false);

		}

		private function convertTime(time:Date):Float{
			
			return (convertTimeHour(time)+convertTimeMinute(time));

		}
		//return the time position
		private function convertTimeHour(time:Date):Float{

			//trace("HOURS",time.getHours());
			//- 1 because of array starting at 0
			return getXcoordinate(time.getHours());

		}
		//returns the positionoffset 
		private function convertTimeMinute(time:Date):Float{
			//trace("MINUTES",time.getMinutes());
			var minutes = time.getMinutes()/60;
			//trace("minut:",xHeight * minutes);
			//trace((xHeight/100) * minutes);
			return (xHeight * minutes);
		}
		//creates legend
		public function createLegend(numberOfentries:Int,arrayOfLabelStrings:Array<String>,arrayOfColors:Array<Int>):Void{
			
			var legendSpace = xWidth/numberOfentries;
			var legendWidth = legendSpace/10;
			var legendHeight = legendSpace/10;
			var xCor = 0.0;
			var yCor = 50.0;


			var legendSprite = new Sprite();

			for(i in 0...numberOfentries){
			//handle the boxes
			legendSprite.graphics.lineStyle(1, 0x000000);
			legendSprite.graphics.beginFill(arrayOfColors[i]);
			legendSprite.graphics.drawRect(xCor,yCor, -legendWidth, legendHeight);
			legendSprite.graphics.endFill();

			//add the textfield
			var tf = new TextField();
			tf.mouseEnabled = false;
			tf.selectable = false;
			tf.text = arrayOfLabelStrings[i];
			tf.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
			legendSprite.addChild(tf);
			tf.width = (tf.textWidth*1.0) + 5;
			tf.height = tf.textHeight+3;
			tf.x = xCor+10;
			tf.y = yCor-5;





			xCor=(xCor+legendSpace)-legendWidth;
			}

			this.addChild(legendSprite);

			legendSprite.x = (xWidth - legendSprite.width)/2;
			legendSprite.mouseEnabled = false;


		}
		//draws vertical bars
		public function drawVerticalBar(colors:Array<Int>, height:Array<Float>,conversionType:Int) {

		trace(height);
		var barWidth:Float = xHeight;
		var totalpoints = yHeight/100;

		if(conversionType == 0){

		 totalpoints = (yHeight/100);
		}		
		if(conversionType == 1){

		 totalpoints = (yHeight/1000);
		}
		if(conversionType == 2){

		 totalpoints = (yHeight/10000);
		}
		
		
		var i:Int = 0;
		for(i in 0...height.length) {
			// For every c in colors a rectangle will be drawn and colored.
			this.graphics.lineStyle(1, 0x000000);
			this.graphics.beginFill(colors[i]);
			this.graphics.drawRect(xCoordinates[i]+((barWidth/2)-((barWidth*0.90)/2)), 0, barWidth*0.80, -height[i]*totalpoints);			
			this.graphics.endFill();
			
			//Increment with barWidth and not barWidth*0.90 (as in drawRect()) is to make a space between each bar.
			
		}

	}

	
		

}
