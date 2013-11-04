package;

import flash.display.Sprite;
//class that defines an onoffBar
class OnOffBar extends Sprite{

		public function new(){

			super();
		}
		//draws an onoffbar given a from and to X coordinate and an Y coordinate 
		public function drawBar(pointXfrom:Float,pointXto:Float, pointYfrom,pointYto:Float){

			trace("drawing bar from:", pointXfrom, "to:",  pointXto, "With:", pointYfrom, "thickness!");

			this.graphics.beginFill(0x000000);
			this.graphics.drawRect(pointXfrom,pointYfrom, pointXto, pointYfrom-10);
			this.graphics.endFill();


		}

}