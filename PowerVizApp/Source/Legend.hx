import flash.display.Sprite;
import flash.text.TextField;

class Legend extends Sprite{

	private var mHeight:Float;
	private var mWidth:Float;

	public function new():Void{

		super();

		

	}


	public function drawLegend(xWidth:Float, yHeight:Float, numberOfentries:Int,arrayOfLabelStrings:Array<String>,arrayOfColors:Array<Int>):Legend{

		var rowHeight = 15;

		var numOfRows = Math.ceil(numberOfentries/6);

		//calculate number of rows
		//numOfRows = Math.ceil(numOfRows);

		this.height = rowHeight * numOfRows;


		var legendSpace = xWidth/6;



			var legendWidth = legendSpace/10;
			var legendHeight = legendSpace/10;
		

		//x and y coordinates
		var xCor = 0.0;
		var yCor = 0.0;
		var counter = 0;
		trace("numberOfentries",numberOfentries);

		var legendSprite = new Sprite();
		for(row in 0...numOfRows){



			for(i in 0...numberOfentries){
			//handle the boxes

			legendSprite.graphics.lineStyle(1, 0x000000);
			legendSprite.graphics.beginFill(arrayOfColors[counter]);
			legendSprite.graphics.drawRect(xCor,yCor, -legendWidth, legendHeight);
			legendSprite.graphics.endFill();

			//add the textfield
			var tf = new TextField();
			tf.mouseEnabled = false;
			tf.selectable = false;
			tf.text = arrayOfLabelStrings[counter];
			tf.setTextFormat(FontSupply.instance.getCoordAxisLabelFormat());
			legendSprite.addChild(tf);
			tf.width = (tf.textWidth*1.1) + 5;
			tf.height = tf.textHeight+3;
			tf.x = xCor+10;
			tf.y = yCor-5;




			xCor=(xCor+legendSpace)-legendWidth;
			counter ++;


			//break if the number of entries is beyond 6 
			if(counter%6 == 0 || counter == numberOfentries){
				xCor = 0.0;
				yCor = yCor +rowHeight+ 3.0;
				break;
			}

			

			}

			if(counter == numberOfentries){

				break;
			}
		}
			this.addChild(legendSprite);

			legendSprite.x = (xWidth - legendSprite.width)/2;


			return this;


	}

	public function getHeight():Float{


		return mHeight;

	}
	

}