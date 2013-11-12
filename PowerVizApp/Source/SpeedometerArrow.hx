package;

import flash.display.Sprite;
import flash.Lib;
import flash.display.Bitmap;
import openfl.Assets;
import motion.Actuate;

class SpeedometerArrow extends Sprite
{

		private var mSpeedometerArrow : Sprite;
		public function new(){


			super();
			var bitMapArrow = new Bitmap (Assets.getBitmapData ("assets/arrow.png"));

			mSpeedometerArrow = new Sprite();

			mSpeedometerArrow.addChild (bitMapArrow);
			bitMapArrow.x = -bitMapArrow.width;
			bitMapArrow.y = -(bitMapArrow.height/2);

			mSpeedometerArrow.width /= 3.5;
			mSpeedometerArrow.height /= 3.5;

			this.addChild(mSpeedometerArrow);
			mSpeedometerArrow.mouseEnabled = false;

		}

		public function setValue(v:Float, ?jitter:Bool) {

			Actuate.tween (this, 2, { rotation: (v * 237)-30 } );
			//this.rotation = (v * 237)-30;
			
			if(jitter != null && jitter==true)
				setJitterMode();
			else
				disableJitterMode();

		}
		
		function setJitterMode() {
			//TODO: Set jittering using Actuate.
		}
		
		function disableJitterMode() {
			//TODO: Disable the jitter and go back to normal behaviour.
		}

}
