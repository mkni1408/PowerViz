import flash.display.Sprite;

class Legend extends Sprite{

	private var mHeight:Float;
	private var mWidth:Float;

	public function new():Void{

		super();

		

	}


	public function drawLegend(xWidth:Float, yWidth:Float, numberOfentries:Int,arrayOfLabelStrings:Array<String>,arrayOfColors:Array<Int>):Void{

		var rowHeight = 15;

		var numOfRows = numOfItems/6;

		
		numOfRows = Math.ceil(numOfRows);

		this.height = rowHeight * numOfRows;

		var legendSpace = xWidth/6;
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
			tf.width = (tf.textWidth*1.1) + 5;
			tf.height = tf.textHeight+3;
			tf.x = xCor+10;
			tf.y = yCor-5;





			xCor=(xCor+legendSpace)-legendWidth;
			}

			this.addChild(legendSprite);

			legendSprite.x = (xWidth - legendSprite.width)/2;


			return legendHeight;


	}

	public function getHeight():Float{


		return mHeight;

	}
	

}