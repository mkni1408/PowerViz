package;


import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.Lib;
import Bulb;
import Math;
import DataInterface;


class ScreenSaver extends Sprite {
	

	//variables needs to be set for the timers
	private var bulbTimerAction:Int = 3000;
	private var screenSaverTimerAction:Int = 20000;


	private var firstBulb:Bulb;
	private var secondBulb:Bulb;
	private var thirdBulb:Bulb;
	private var fourthBulb:Bulb;
	private var fifthBulb:Bulb;
	private var sixthBulb:Bulb;
	private var seventhBulb:Bulb;
	private var mIsTransparant: Bool;
	private var mHasRecievedTouchEvent: Bool;
	private var yourbulbTimer:haxe.Timer;
	private var yourScreensaverTimerTimer:haxe.Timer;
	private var dataInterface:DataInterface;


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
		
		//place the bulbs
		placeBulbs();

		setBulbAction(50);

		this.mouseEnabled = false;

	}
	

	
	//change the bulbstates man
	public function changeBulbStates(f:Float):Void{
				
				if(f < 0.2){

   					firstBulb.bulb_changeStateToOn();
   					secondBulb.bulb_changeStateToOff();
					thirdBulb.bulb_changeStateToOff();
					fourthBulb.bulb_changeStateToOff();
					fifthBulb.bulb_changeStateToOff();

   					trace("first bulb is on");

   				}	
   				else if(f > 0.2 && f < 0.4){
   					firstBulb.bulb_changeStateToOn();
   					secondBulb.bulb_changeStateToOn();
					thirdBulb.bulb_changeStateToOff();
					fourthBulb.bulb_changeStateToOff();
					fifthBulb.bulb_changeStateToOff();

   					trace("first and second bulb is on");
   				}
   				else if(f > 0.4 && f < 0.6){
   					firstBulb.bulb_changeStateToOn();
   					secondBulb.bulb_changeStateToOn();
					thirdBulb.bulb_changeStateToOn();
					fourthBulb.bulb_changeStateToOff();
					fifthBulb.bulb_changeStateToOff();
   					trace("first, second and third bulb is on");
   				}
   				else if(f > 0.6 && f < 0.8){
   					firstBulb.bulb_changeStateToOn();
   					secondBulb.bulb_changeStateToOn();
					thirdBulb.bulb_changeStateToOn();
					fourthBulb.bulb_changeStateToOn();
					fifthBulb.bulb_changeStateToOff();
   					trace("first, second, third and fourth bulb is on");
   				}
   				else if(f > 0.8 && f <= 1){
   					firstBulb.bulb_changeStateToOn();
   					secondBulb.bulb_changeStateToOn();
					thirdBulb.bulb_changeStateToOn();
					fourthBulb.bulb_changeStateToOn();
					fifthBulb.bulb_changeStateToOn();
   					trace("first, second, third, fourth and fifth bulb is on");
   				}
   				else{

   					firstBulb.bulb_changeStateToOn();
   					secondBulb.bulb_changeStateToOn();
					thirdBulb.bulb_changeStateToOn();
					fourthBulb.bulb_changeStateToOn();
					fifthBulb.bulb_changeStateToOn();
					sixthBulb.bulb_changeStateToOn();
					seventhBulb.bulb_changeStateToOn();
   					trace("All is on!");
   				}



	}
	
	//Place the bulbs
	public function placeBulbs(){


		var positionHorisontal = (Lib.stage.stageWidth/10);
		var positionVertical = 0+40;
		var positionVerticaloffset = 65;

		//position the bulbs
		firstBulb.x = positionHorisontal;
		firstBulb.y = positionVertical+45;


		secondBulb.x = positionHorisontal*3;
		secondBulb.y = positionVertical+20;



		thirdBulb.x = positionHorisontal*5;
		thirdBulb.y = positionVertical+5;


		fourthBulb.x = positionHorisontal*7;
		fourthBulb.y = positionVertical+25;



		fifthBulb.x = positionHorisontal+positionVerticaloffset;
		fifthBulb.y = (Lib.stage.stageHeight/2)+30;



		sixthBulb.x = (positionHorisontal*3)+positionVerticaloffset;
		sixthBulb.y = (Lib.stage.stageHeight/2);




		seventhBulb.x = (positionHorisontal*5)+positionVerticaloffset;
		seventhBulb.y = (Lib.stage.stageHeight/2);
	}

//set screensaverstate. If the screensaver is transparent and we have not recieved any Touchevents, 
	//we make it visible. Else we make it invisible
	public function setScreenSaver():Void{


			this.visible = true;
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
   			trace("Screen saver Timer running!!");
   				
   				trace(mIsTransparant);
   				trace(mHasRecievedTouchEvent);
   				setScreenSaver();

			};


	}
	//stop bulbactiontimer when view is not visible
	public function stopBulbActionTimer(){
		
		yourbulbTimer.stop();


	}

	//start bulbactiontimer when view is visible
	public function startBulbActionTimer(){
		
		yourbulbTimer.stop();

		yourbulbTimer= new haxe.Timer(bulbTimerAction);

			yourbulbTimer.run = function():Void{
   			trace("BulbTimer running!!");
   				//get current load from dataInterface
   				var f  = dataInterface.getTotalCurrentLoad(1);
   				//var f  = Math.random();

   				trace(f);

   				changeBulbStates(f);
			};


	}


//starts timers that 1, updates bulbs and 2, checks if screen has been tuched.
	public function setBulbAction(watt:Float):Void {
			yourbulbTimer= new haxe.Timer(bulbTimerAction);

			yourbulbTimer.run = function():Void{
   			trace("BulbTimer running!!");
   				//get current load from dataInterface
   				var f  = dataInterface.getTotalCurrentLoad(1);

   				//var f  = Math.random();

   				trace(f);

   				changeBulbStates(f);
			};


			yourScreensaverTimerTimer= new haxe.Timer(screenSaverTimerAction);

			yourScreensaverTimerTimer.run = function():Void{
   			trace("Screen saver Timer running!!");
   				
   				trace(mIsTransparant);
   				trace(mHasRecievedTouchEvent);
   				setScreenSaver();
   				
			};

	}



	
}
