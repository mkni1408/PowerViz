package;


import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.Lib;
import motion.Actuate;
import Math;
import openfl.Assets;
import flash.display.Bitmap;

import Enums;
import Bulb;
import DataInterface;
import PowerTimer;

/*
// Sprite that defines a Screensaver
*/
class ScreenSaver extends Sprite {
	

	//variables needs to be set for the timers 
	//bulbTimerAction: the timer for the update frequency of the bulbs
	//screenSaverTimerAction: The time until the screensaver becomes visible again
	private var bulbTimerAction:Int = 5000;
	private var screenSaverTimerAction:Int = 10000; //Millisecs before the screensaver should become active.
	private var yourBulbFaderTimerAction:Int = 8000;
	private var mBackground : Bitmap = null;
	private var mAlertBitmap : Bitmap = null;
	private var mAlertTimerInterval = 1500;

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
	private var yourbulbTimer:PowerTimer;
	private var yourScreensaverTimerTimer:PowerTimer;
	private var yourBulbFaderTimer:PowerTimer;
	private var mAlertTimer:PowerTimer;


	private var mBulbArray:Array<Bulb>;


	public function new(){

		super();


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
		//this.graphics.beginFill(0xFFFFFF);
		//this.graphics.drawRect(0,0,Lib.stage.stageWidth,Lib.stage.stageHeight);
		//this.graphics.endFill();
		mBackground = new Bitmap(openfl.Assets.getBitmapData("assets/background3.png"));
		mBackground.width = Lib.stage.stageWidth;
		mBackground.height = Lib.stage.stageHeight;
		this.addChild(mBackground);

		mAlertBitmap = new Bitmap(openfl.Assets.getBitmapData("assets/alert.png"));
		mAlertBitmap.width = 75;
		mAlertBitmap.height = 75;
		mAlertBitmap.x = (Lib.stage.stageWidth-mAlertBitmap.width)-10;
		mAlertBitmap.y = (Lib.stage.stageHeight-mAlertBitmap.height)-10;
		this.addChild(mAlertBitmap);
		mAlertBitmap.alpha = 0;
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

		mAlertTimer = new PowerTimer(mAlertTimerInterval); 
        mAlertTimer.onTime = onTime;

	}
	

	
	//change the bulbstates man
	public function calculatBulbStates(f:Float):Void{


				if(f < 0.1){

					changeBulbStates(true,false,false,false,false,false,false,false,false);
					mAlertTimer.stop();


   				}	
   				else if(f > 0.1 && f < 0.2){


					changeBulbStates(true,true,false,false,false,false,false,false,false);
					mAlertTimer.stop();

   				}
   				else if(f > 0.2 && f < 0.3){

					changeBulbStates(true,true,true,false,false,false,false,false,false);
					mAlertTimer.stop();
   				}
   				else if(f > 0.3 && f < 0.4){

					changeBulbStates(true,true,true,true,false,false,false,false,false);
					mAlertTimer.stop();
   				}
   				else if(f > 0.4 && f < 0.5){

					changeBulbStates(true,true,true,true,true,false,false,false,false);
					mAlertTimer.stop();
   				}
   				else if(f > 0.5 && f < 0.6){

					changeBulbStates(true,true,true,true,true,true,false,false,false);
					mAlertTimer.stop();
   				}
   				else if(f > 0.6 && f < 0.7){

					changeBulbStates(true,true,true,true,true,true,true,false,false);
					mAlertTimer.stop();
   				}
   				else if(f > 0.7 && f < 0.8){

					changeBulbStates(true,true,true,true,true,true,true,true,false);
					mAlertTimer.stop();
   				}
   				else if(f > 0.9 && f <= 1.0){

					changeBulbStates(true,true,true,true,true,true,true,true,true);
					mAlertTimer.stop();
   				}
   				else if(f > 1.0){
					mAlertTimer.start();
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
				this.visible = true; //???? If this is visible, set this to visible? 
			}
			else{
				this.alpha = 0.0;
				this.visible = true;
				Actuate.tween (this, 5, { alpha: 1 } );
				DataInterface.instance.logInteraction(LogType.ScreenChange, "ScreensaverEnabled");
			}
			startBulbActionTimer();

	}

	public function onScreenTouch():Void{
		
		if(this.visible==true) {
			DataInterface.instance.logInteraction(LogType.ScreenChange, "ScreensaverDisabled");
		}

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
		yourScreensaverTimerTimer = new PowerTimer(screenSaverTimerAction);
		yourScreensaverTimerTimer.onTime = function() {
			setScreenSaver();
		};
		yourScreensaverTimerTimer.start();


	}
	//stop bulbactiontimer when view is not visible
	public function stopBulbActionTimer(){
		
		yourbulbTimer.stop();
		yourBulbFaderTimer.stop();
		mAlertTimer.stop();

	}

	//start bulbactiontimer when view is visible
	public function startBulbActionTimer(){
		
		yourbulbTimer.stop();
		/*yourbulbTimer = new PowerTimer(bulbTimerAction);
		yourbulbTimer.onTime = function() {
			var f  = DataInterface.instance.getTotalCurrentLoad();
			calculatBulbStates(f);
		};*/
		yourbulbTimer.start();			

		yourBulbFaderTimer.stop();
		/*yourBulbFaderTimer = new PowerTimer(yourBulbFaderTimerAction);
		yourBulbFaderTimer.onTime = function(){
			fadeBulbsWhenInactive();
		};*/
		yourBulbFaderTimer.start();
		

	}


//starts timers that 1, updates bulbs and 2, checks if screen has been tuched.
	public function setBulbAction(watt:Float):Void {
			
			yourbulbTimer = new PowerTimer(bulbTimerAction);
			yourbulbTimer.onTime = function() {
				var f  = DataInterface.instance.relativeUsage();
				calculatBulbStates(f);
			};
			yourbulbTimer.start();
			

			yourScreensaverTimerTimer = new PowerTimer(screenSaverTimerAction);
			yourScreensaverTimerTimer.onTime = function() {
				setScreenSaver();
			};
			yourScreensaverTimerTimer.start();


			yourBulbFaderTimer = new PowerTimer(yourBulbFaderTimerAction);
			yourBulbFaderTimer.onTime = function(){
				fadeBulbsWhenInactive();
			};
			yourBulbFaderTimer.start();
			

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
					eightBulb.bulb_changeState(eightbulb);
					ninthBulb.bulb_changeState(ninthbulb);

	}

	private function fadeBulbsWhenInactive():Void{
		trace("fadeBulbsWhenInactive");
		for(i in 0...mBulbArray.length){

			mBulbArray[i].bulbFade();

		}

	}

	private function onTime() {

            if(mAlertBitmap.alpha == 1){
            	Actuate.tween (mAlertBitmap, 1, { alpha: 0 } );

            }
            else{
            	Actuate.tween (mAlertBitmap, 1, { alpha: 1 } );
            }
        }


	
}
