package;


import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.Lib;
import Bulb;
import motion.Actuate;
import Math;
import DataInterface;
/*
// Sprite that defines a Screensaver
*/
class ScreenSaver extends Sprite {
	

	//variables needs to be set for the timers 
	//bulbTimerAction: the timer for the update frequency of the bulbs
	//screenSaverTimerAction: The time until the screensaver becomes visible again
	private var bulbTimerAction:Int = 5000;
	private var screenSaverTimerAction:Int = 20000;
	private var yourBulbFaderTimerAction:Int = 8000;


	private var firstBulb:Bulb;
	private var secondBulb:Bulb;
	private var thirdBulb:Bulb;
	private var fourthBulb:Bulb;
	private var fifthBulb:Bulb;
	private var sixthBulb:Bulb;
	private var seventhBulb:Bulb;
	private var eightBulb:Bulb;
	private var ninthBulb:Bulb;
	private var mIsTransparant: Bool;
	private var mHasRecievedTouchEvent: Bool;
	private var yourbulbTimer:haxe.Timer;
	private var yourScreensaverTimerTimer:haxe.Timer;
	private var yourBulbFaderTimer:haxe.Timer;
	private var dataInterface:DataInterface;

	private var mBulbArray:Array<Bulb>;


	public function new(){

		super();


		dataInterface = new DataInterface();

		mIsTransparant = true;
		mHasRecievedTouchEvent = false;


		firstBulb = new Bulb();
		secondBulb = new Bulb();
		thirdBulb = new Bulb();
		fourthBulb = new Bulb();
		fifthBulb = new Bulb();
		sixthBulb = new Bulb();
		seventhBulb = new Bulb();
		eightBulb = new Bulb();
		ninthBulb = new Bulb();


		

		//add background fill color
		this.graphics.beginFill(0xFFFFFF);
		this.graphics.drawRect(0,0,Lib.stage.stageWidth,Lib.stage.stageHeight);
		this.graphics.endFill();


		//add bulbobjects to main sprite
		addChild(firstBulb);
		addChild(secondBulb);
		addChild(thirdBulb);
		addChild(fourthBulb);

		addChild(fifthBulb);
		addChild(sixthBulb);
		addChild(seventhBulb);
		addChild(eightBulb);
		addChild(ninthBulb);

		mBulbArray = [firstBulb,secondBulb,thirdBulb,fourthBulb,fifthBulb,sixthBulb,seventhBulb,eightBulb,ninthBulb];	

		fadeBulbsWhenInactive();
		
		//place the bulbs
		placeBulbs();

		setBulbAction(50);

		this.mouseEnabled = false;

	}
	

	
	//change the bulbstates man
	public function calculatBulbStates(f:Float):Void{
				
				if(f < 0.1){

					changeBulbStates(true,false,false,false,false,false,false,false,false);


   				}	
   				else if(f > 0.1 && f < 0.2){


					changeBulbStates(true,true,false,false,false,false,false,false,false);

   				}
   				else if(f > 0.2 && f < 0.3){

					changeBulbStates(true,true,true,false,false,false,false,false,false);
   				}
   				else if(f > 0.3 && f < 0.4){

					changeBulbStates(true,true,true,true,false,false,false,false,false);
   				}
   				else if(f > 0.4 && f < 0.5){

					changeBulbStates(true,true,true,true,true,false,false,false,false);
   				}
   				else if(f > 0.5 && f < 0.6){

					changeBulbStates(true,true,true,true,true,true,false,false,false);
   				}
   				else if(f > 0.6 && f < 0.7){

					changeBulbStates(true,true,true,true,true,true,true,false,false);
   				}
   				else if(f > 0.7 && f < 0.8){

					changeBulbStates(true,true,true,true,true,true,true,true,false);
   				}
   				else if(f > 0.9 && f <= 1.0){

					changeBulbStates(true,true,true,true,true,true,true,true,true);
   				}



	}
	
	//Place the bulbs(Calculated from the middle and is ofsetted)
	public function placeBulbs(){


		var positionHorisontal = (Lib.stage.stageWidth/10);
		var positionVertical = 0+40;
		var positionVerticaloffset = 65;

		//position the bulbs
		firstBulb.x = (positionHorisontal)-30;
		firstBulb.y = positionVertical+45;


		secondBulb.x = (positionHorisontal*3)-30;
		secondBulb.y = positionVertical+20;


		thirdBulb.x = (positionHorisontal*5)-30;
		thirdBulb.y = positionVertical+5;


		fourthBulb.x = (positionHorisontal*7)-30;
		fourthBulb.y = positionVertical+25;


		fifthBulb.x = (positionHorisontal+positionVerticaloffset)-10;
		fifthBulb.y = (Lib.stage.stageHeight/2)+30;


		sixthBulb.x = ((positionHorisontal*3)+positionVerticaloffset)-30;
		sixthBulb.y = (Lib.stage.stageHeight/2);

		seventhBulb.x = ((positionHorisontal*5)+positionVerticaloffset)-30;
		seventhBulb.y = (Lib.stage.stageHeight/2);

		eightBulb.x = (positionHorisontal*9)-30;
		eightBulb.y = positionVertical+35;

		ninthBulb.x = ((positionHorisontal*7)+positionVerticaloffset)-30;
		ninthBulb.y = (Lib.stage.stageHeight/2);


	}

//set screensaverstate. If the screensaver is transparent and we have not recieved any Touchevents, 
	//we make it visible. if it is invisible we tween it 
	public function setScreenSaver():Void{

			if(this.visible){
			this.visible = true;
			}
			else{

			this.alpha = 0.0;
			this.visible = true;
			Actuate.tween (this, 5, { alpha: 1 } );
			}
			startBulbActionTimer();

	}

	public function onScreenTouch():Void{

		this.visible = false;
		restartScreenSaverTimer();
		stopBulbActionTimer();
		//trace("Mouseeven has been registered!!");

	}

	/*
	//
	//Timer Methods
	//
	*/



	//restarts the  screensavertimer when a touchevent is recieved
	public function restartScreenSaverTimer(){

		yourScreensaverTimerTimer.stop();

			yourScreensaverTimerTimer= new haxe.Timer(screenSaverTimerAction);

			yourScreensaverTimerTimer.run = function():Void{
   			//trace("Screen saver Timer running!!");
   				
   				//trace(mIsTransparant);
   				//trace(mHasRecievedTouchEvent);
   				setScreenSaver();

			};


	}
	//stop bulbactiontimer when view is not visible
	public function stopBulbActionTimer(){
		
		yourbulbTimer.stop();
		yourBulbFaderTimer.stop();


	}

	//start bulbactiontimer when view is visible
	public function startBulbActionTimer(){
		
		yourbulbTimer.stop();

		yourbulbTimer= new haxe.Timer(bulbTimerAction);

			yourbulbTimer.run = function():Void{
   			//trace("BulbTimer running!!");
   				//get current load from dataInterface
   				var f  = DataInterface.instance.relativeUsage();
   				//var f  = Math.random();

   				//trace(f);

   				calculatBulbStates(f);
			};

		yourBulbFaderTimer.stop();
			yourBulbFaderTimer= new haxe.Timer(yourBulbFaderTimerAction);

			yourBulbFaderTimer.run = function():Void{
   			//trace("Screen saver Timer running!!");
   				
   				fadeBulbsWhenInactive();
   				
			};


	}


//starts timers that 1, updates bulbs and 2, checks if screen has been tuched.
	public function setBulbAction(watt:Float):Void {
			yourbulbTimer= new haxe.Timer(bulbTimerAction);

			yourbulbTimer.run = function():Void{
   			//trace("BulbTimer running!!");
   				//get current load from dataInterface
   				var f  = dataInterface.getTotalCurrentLoad();

   				//var f  = Math.random();

   				//trace(f);

   				calculatBulbStates(f);
			};


			yourScreensaverTimerTimer= new haxe.Timer(screenSaverTimerAction);

			yourScreensaverTimerTimer.run = function():Void{
   			//trace("Screen saver Timer running!!");
   				
   				//trace(mIsTransparant);
   				//trace(mHasRecievedTouchEvent);
   				setScreenSaver();
   				
			};

			yourBulbFaderTimer= new haxe.Timer(yourBulbFaderTimerAction);

			yourBulbFaderTimer.run = function():Void{
   			//trace("Screen saver Timer running!!");
   				
   				fadeBulbsWhenInactive();
   				
			};

	}

	//changes the state of the bulbs to on=true or off=false
	private function changeBulbStates(firstbulb:Bool, secondbulb:Bool, thirdbulb:Bool, fourthbulb:Bool, fifthbulb:Bool, sixthbulb:Bool, seventhbulb:Bool, eightbulb:Bool, ninthbulb:Bool):Void
	{

					firstBulb.bulb_changeState(firstbulb);
   					secondBulb.bulb_changeState(secondbulb);
					thirdBulb.bulb_changeState(thirdbulb);
					fourthBulb.bulb_changeState(fourthbulb);
					fifthBulb.bulb_changeState(fifthbulb);
					sixthBulb.bulb_changeState(sixthbulb);
					seventhBulb.bulb_changeState(seventhbulb);

	}

	private function fadeBulbsWhenInactive():Void{

		for(i in 0...mBulbArray.length){

			mBulbArray[i].bulbFade();

		}

	}



	
}
