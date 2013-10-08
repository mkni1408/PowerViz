package;

import ScreenSaver;
import flash.display.Sprite; 
import CurrentUsage;

class Main extends Sprite{

	var screenSaver:ScreenSaver;
	var currentUsage:CurrentUsage;
	
	function new(){

			super();

			currentUsage = new CurrentUsage();


			addChild(currentUsage);

			//screenSaver = new ScreenSaver();
			//addChild(screenSaver);
	}

}