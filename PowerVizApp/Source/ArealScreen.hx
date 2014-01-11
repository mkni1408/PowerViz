package;

import flash.display.Sprite;
import flash.text.TextField;
import flash.Lib;

import DataInterface;
import ArealDiagram;
import FontSupply;
import DataInterface;
import TimeChangeButton;
import CoordSystem;
import Outlet;
import PowerTimer;

import Enums;

/**
Screen displaying the Areal diagram.
Uses the ArealDiagram class for drawing the special diagram.

This class obtains data from the DataInterface singleton class.
**/

class ArealScreen extends Sprite {
        //should be changed to Hour,day,month
        private static inline var VIEWMODE_HOUR:Int = 0;
        private static inline var VIEWMODE_DAY:Int = 1;
        private static inline var VIEWMODE_THREEDAYS:Int = 2;

        private var mBack : Sprite;
        private var mDiagram : ArealDiagram;
        private var mCoordSys : CoordSystem;
        private var mTimeArray: Array<String>;
        private var mUsageArray : Array<String>;
        private var mTitle : TextField;
        private var mTimeButton : TimeChangeButton;
        private var mLegend:Legend;
        private var mRoomArray:Array<String>;
        private var mColorArray:Array<Int>;
        private var mViewMode:Int;
        private var mFront:Sprite;
        private var mOffset = 1.0;
        private var mTimer:PowerTimer;
        #if demo
            private var mTimerInterval:Int = 60*1000; //Once a minute in demo mode.
        #else
            private var mTimerInterval:Int = 5*60*1000; //Every 5 minutes in normal mode.
        #end




        public function new() {
                super();
                
                mRoomArray = new Array<String>();
                mColorArray = new Array<Int>();

				

                getColorAndRoomData();
				
                mViewMode = VIEWMODE_DAY; //Daymode by default.
                
                mBack = new Sprite();
				
                mBack.graphics.beginFill(0xFFFFFF,0);
                mBack.graphics.drawRect(0,0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
                mBack.graphics.endFill();
                this.addChild(mBack);
				
                mTimeArray = generateTimeArrayandCalcOffset();
				

                mUsageArray = ["100Wt", "200Wt", "300wt","400Wt","500Wt", "600Wt","700Wt", 
                                                        "800Wt","900Wt","1000Wt"];

                
                mDiagram = new ArealDiagram();
                mDiagram.mouseEnabled=false;
                
                mTitle = new TextField();
                mTitle.mouseEnabled=false;
                mTitle.text = "Forbrug i dag ";
                mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
                mTitle.selectable = false;
                
                mTimeButton = new TimeChangeButton([VIEWMODE_HOUR, VIEWMODE_DAY,VIEWMODE_THREEDAYS,],mViewMode,onButtonPush); //Day, week, month.
                
                mCoordSys = new CoordSystem();

				
                callDrawMethods();
				

				/** Screen timers are not used anymore. Callbacks are used instead.
                mTimer = new PowerTimer(mTimerInterval); 
                mTimer.onTime = onTime;
                mTimer.start();
                **/
				DataInterface.instance.callbackQuarter.addCallback(onTime); //Use the DataInterface callback mechanism.

        }

        private function onTime() {
            redrawEverything();
        }
        
        private function addChildrenToBack() {        
                mBack.addChild(mDiagram);
                mBack.addChild(mTimeButton);

                mBack.addChild(mCoordSys);
                mBack.addChild(mTitle);
        }
        
        /**
        Places the graphical elements on the screen.
        **/
        private function doLayout() {

                mTitle.width = mTitle.textWidth;        
                mTitle.x = (Lib.current.stage.stageWidth - mTitle.textWidth) / 2;
                mTitle.y = 0;

                //mBack.addChild(mTitle);

                mLegend = new Legend();
                mLegend.drawLegend(mBack.width/1.15,mBack.height/1.25,mColorArray.length,mRoomArray, mColorArray);
                mBack.addChild(mLegend);
                //mBack.addChild(mLegend);
        
                //generates a usagearray and returns a height devide number 
                var devider = generateUsageArray(mDiagram.maxValue);

                
                mTimeButton.x = Lib.current.stage.stageWidth - mTimeButton.width;
                mTimeButton.y = 0;

                mCoordSys.generate(Lib.current.stage.stageWidth/1.15, (Lib.current.stage.stageHeight/1.25)-mLegend.height, "X", "Y", 
                    (Lib.current.stage.stageWidth/1.15)/mTimeArray.length, ((Lib.current.stage.stageHeight/1.25)-mLegend.height)/mUsageArray.length, 
                                                                                                        mTimeArray, mUsageArray, false,false,false,true,mOffset);
                mCoordSys.x = 100;
                mCoordSys.y = (Lib.current.stage.stageHeight/1.25)+40;

                mLegend.x = mCoordSys.x;
                mLegend.y = mCoordSys.y + 30;

                mDiagram.x = mCoordSys.x;
                mDiagram.y = mCoordSys.y;        
                
                mDiagram.width = Lib.current.stage.stageWidth/1.15;
                mDiagram.height = (mCoordSys.getHeight()/devider)*mDiagram.maxValue;
                
/*
                 switch( mViewMode ) {
                    case VIEWMODE_HOUR:
                        mDiagram.width = Lib.current.stage.stageWidth/1.15;
                        mDiagram.height = (mCoordSys.getHeight()/devider)*mDiagram.maxValue;
                    case VIEWMODE_DAY:
                        mDiagram.width = Lib.current.stage.stageWidth/1.15;
                        mDiagram.height = (mCoordSys.getHeight()/devider)*mDiagram.maxValue;
                    case VIEWMODE_THREEDAYS:
                        mDiagram.width = Lib.current.stage.stageWidth/1.15;
                        mDiagram.height = (mCoordSys.getHeight()/devider)*mDiagram.maxValue;
                    default:
                        mDiagram.width = Lib.current.stage.stageWidth/1.15;
                        mDiagram.height = (mCoordSys.getHeight()/devider)*mDiagram.maxValue;
                        
            }*/
                //mBack.addChild(mCoordSys);

        }
        
        /*Gets data through DataInterface, then creates the diagram.*/
        private function fillWithData() {
                /*
                DataInterface.instance.requestArealDataToday(onDataReceivedDay);
                return;
                */
                //var outlets = DataInterface.instance.getAllOutlets();

                var colors = new Array<Int>();
                var usageAA =  new Array< Array<Float> >();
                //for(t in outlets) {
                //        usageAA.push(DataInterface.instance.getOutletLastDayUsage(t));
                //        colors.push(DataInterface.instance.getOutletColor(t));
                //}*/
                var r:ArealDataStruct = {outletIds:new Array<Int>(), watts:new Map<Int, Array<Float>>(), colors:new Map<Int,Int>()};
				
				
                if(mViewMode==VIEWMODE_HOUR){//hour
                    r = DataInterface.instance.getArealUsageHour();
                }
                 if(mViewMode==VIEWMODE_DAY){//Day
                    r = DataInterface.instance.getArealUsageToday();
                }
                 if(mViewMode==VIEWMODE_THREEDAYS){//Week
                    r = DataInterface.instance.getArealUsageWeek();
                }

                

                var rvIds = new Array<Int>();
                var rvUsage = new Map<Int, Array<Float>>();
                var rvColors = new Map<Int, Int>();

                rvIds = r.outletIds;
                rvUsage = r.watts;
                rvColors = r.colors;

                drawData(rvIds,rvUsage,rvColors);
				
        }        
        
        private function drawData(outletIds:Array<Int>, usage:Map<Int, Array<Float>>, colors:Map<Int, Int>) : Void {
                
                var data = prepareArray(outletIds,usage,colors);
            
                mDiagram.graphics.clear();
                
                var LOD:Int = 0; //Default
                if(mViewMode == VIEWMODE_THREEDAYS)
                	LOD = 1;
                if(mViewMode == VIEWMODE_DAY)
                	LOD = 0; 

                mDiagram.generate(data.usage, data.colors, Lib.current.stage.stageWidth / 1.15,Lib.current.stage.stageHeight / 1.25, LOD);
       
        }
        
      
        
        private function onButtonPush(coordSystemType:Int):Void{

            switch( coordSystemType ) {
	            case 0:
	       			mViewMode = VIEWMODE_HOUR; //HOUR
	       			DataInterface.instance.logInteraction(LogType.Button, "ArealScreenViewHour", "Viewing hour data in Arealscreen");
	            case 1:
	       			mViewMode = VIEWMODE_DAY; //DAY
	       			DataInterface.instance.logInteraction(LogType.Button, "ArealScreenViewDay", "Viewing day data in Arealscreen");
	        	case 2:
	        		mViewMode = VIEWMODE_THREEDAYS; //Three days.
	        		DataInterface.instance.logInteraction(LogType.Button, "ArealScreenViewThreeDays", "Viewing three days data in Arealscreen");
	            default:
	        		mViewMode = VIEWMODE_DAY; //Defaults to hour.
	        		DataInterface.instance.logInteraction(LogType.Button, "ArealScreenViewHour", "Defaults to viewing hour data in Arealscreen");
        	}
            redrawEverything(); 
        }

        private function redrawEverything():Void{


                 mTimeButton.changeButtonState(mViewMode);
                var date = Date.now();
                if(mViewMode == 0){
                        //hour
                        mUsageArray = ["0,1 kWt", "0,2 kWt", "0,3 kWt","0,4 kWt","0,5 kWt", "0,6 kWt","0,7 kWt", "0,8 kWt","0,9 kWt","  1 kWt"];

                        mTimeArray = generateTimeArrayandCalcOffset();

                        mTitle.text = "Forbrug denne time ";

                }
                if(mViewMode == 1){
                        //day
                        mUsageArray = [" 1kWt  ", " 2kWt  ", "3kWt  ","4kWt  ","5kWt  ", "6kWt  ","7kWt  ", "8kWt  ","9kWt  ","10kWt  "];

                        mTimeArray = generateTimeArrayandCalcOffset();

                        mTitle.text = "Dagens forbrug ";

                }
                if(mViewMode == 2){
                       mTimeArray = generateTimeArrayandCalcOffset();
                        
                        ///week
                        mUsageArray = ["10kWt ", "20kWt ", "30kWt ","40kWt ","50kWt ", "60kWt ","70kWt ", "80kWt ","90kWt ","100kWt "];
                        //mTimeArray = ["Tirsdag","Onsdag","Torsdag","Fredag","Lørdag","Søndag"];
                        mTitle.text = "Seneste 3 dages forbrug ";

                }
                
                

               
                mTitle.setTextFormat(FontSupply.instance.getTitleFormat());

                while(mBack.numChildren > 0)
                    mBack.removeChildAt(0);

                mDiagram = new ArealDiagram();
                mCoordSys = new CoordSystem();
                
                callDrawMethods();
                
        }

        private function callDrawMethods():Void {
			
                getColorAndRoomData();
				
                fillWithData();
				
                doLayout();
				
                addChildrenToBack();
        }



        private function getColorAndRoomData():Void {
                        
                mRoomArray = new Array<String>();
                mColorArray = new Array<Int>();
                for(r in DataInterface.instance.houseDescriptor.getRoomArray()) {
                        mRoomArray.push(r.roomName);
                        mColorArray.push(r.roomColor);
                }
                
        }

        private function getWeekDay(day:Int):String {

             switch( day ) {
                case 0:
                     return "Søndag";
                case 1:
                     return "Mandag";
                case 2:
                    return "Tirsdag";
                case 3:
                     return "Onsdag";
                case 4:
                     return "Torsdag";
                case 5:
                    return "Fredag";
                case 6:
                    return "Lørdag";

                default:
                    return "Dag ";
            }
        }

        private function prepareArray(outletIds:Array<Int>, usage:Map<Int, Array<Float>>, colors:Map<Int, Int>):{usage:Array<Array<Float>>,colors:Array<Int>}{

                var _usage = new Array< Array<Float> >();
                var _colors = new Array<Int>();
                var _returnUsage = new Array< Array<Float> >();
                var _returnColors = new Array<Int>();
                var _ta:Array<Float>;
                var _room = new Array<Array<Int>>();
                var _outlets = new Array<Outlet>();
                var _roomMap = new Array<Int>();
                
                for(room in DataInterface.instance.houseDescriptor.getRoomArray()) {
                    for(outlet in room.getOutletsArray()) {
                           
                    	_outlets.push(new Outlet(0, Std.string(outlet.outletId), outlet.name, 
                                                            null, room.roomName, 0,
                                                            room.roomColor, outlet.outletColor));

                            
                    }
                }


                    
                for(room in mRoomArray){
                    //trace(DataInterface.instance.houseDescriptor.getRoom(id).roomName);
                    var tmpArray = new Array<Int>();
                    for(out in _outlets){

                        //trace("comparing "+Std.parseInt(out.getid())+" with "+id);

                        if(out.getRoom() == room){

                        tmpArray.push(Std.parseInt(out.getid()));
                        

                        }

                    }
                    
                    _room.push(tmpArray);
                                       
                }


               

                if(mViewMode==VIEWMODE_HOUR){//hour
                    
                    if(outletIds.length == 0){//hack, ellers forsvinder diagrammet ud af siden
                    _ta = new Array<Float>();
                        for(t in 0...4){
                                _ta.push(0);
                            }

                             _usage.push(_ta);

                    }
                    else{
                
                        for(id in outletIds) {

                            _ta = usage.get(id);
                            while(_ta.length<4)
                                    _ta.push(0);
                            if(_ta.length>4)
                                    _ta = _ta.slice(0,4);
                                
                            _usage.push(_ta);
                            _roomMap.push(id);
                                
                        
                            _colors.push(colors.get(id));

                        }

                    }

                    
                }
                 if(mViewMode==VIEWMODE_DAY){//Day
                    if(outletIds.length == 0){//hack, ellers forsvinder diagrammet ud af siden hvis tomt
                    _ta = new Array<Float>();


                        for(t in 0...96){
                                _ta.push(0);
                            }
                            
                             _usage.push(_ta);
                            

                    }
                    else{
                
                        for(id in outletIds) {
                            
                            _ta = usage.get(id);
                            while(_ta.length<96)
                                    _ta.push(0);
                            if(_ta.length>96)
                                    _ta = _ta.slice(0,96);
                                
                            _usage.push(_ta);
                            _roomMap.push(id);

                                
                        
                            _colors.push(colors.get(id));

                        }

                    }
                }
                 if(mViewMode==VIEWMODE_THREEDAYS){//Week
                    if(outletIds.length == 0){//hack, ellers forsvinder diagrammet ud af siden
                    _ta = new Array<Float>();
                        for(t in 0...288){
                                _ta.push(0);
                            }

                             _usage.push(_ta);

                    }
                    else{
                
                        for(id in outletIds) {
                            _ta = usage.get(id);
                            while(_ta.length<288)
                                    _ta.push(0);
                            if(_ta.length>288)
                                    _ta = _ta.slice(0,288);
                                
                            _usage.push(_ta);
                            _roomMap.push(id);

                                
                        
                            _colors.push(colors.get(id));

                        }
                    }
                    //trace(_usage);
                }


                //rearrange the array so it matches room colors

                for(room in _room){//grab the room array

                    for(ro in room){//for each value in room array: int

                        for(i in 0..._usage.length){
                            if(_roomMap[i]==ro){
                                _returnUsage.push(_usage[i]);
                                _returnColors.push(_colors[i]);
                                break;
                            }
                        }
                    }
                }


                if(_returnUsage.length == 0){

                    return {usage:_usage,colors:_colors}
                }
                return {usage:_returnUsage,colors:_returnColors}
            
                
            }
            //creates an array of strings that matches the max watt consumption
            //returns a devider used to calculate the height of the arealdiagram
            private function generateUsageArray(maxValue:Float):Float{

                if(maxValue <= 100){

                    mUsageArray = ["0,01 kW", "0,02 kW", "0,03 kW","0,04 kW","0,05 kW", "0,06 kW","0,07 kW", "0,08 kW","0,09 kW","0,1 kW"];
                    return 10;
                }
                else if(maxValue > 100 && maxValue <= 500){

                    mUsageArray = ["0,05 kW", "0,1 kW", "0,15 kW","0,2 kW","0,25 kW", "0,3 kW","0,35 kW", "0,4 kW","0,45 kW","0,5 kW"];
                    return 50;
                }
                else if(maxValue > 500 && maxValue <= 600){

                    mUsageArray = ["0,6 kW", "0,12 kW", "0,18 kW","0,24 kW","0,3 kW", "0,36 kW","0,42 kW", "0,48 kW","0,54 kW","0,6 kW"];
                    return 61;
                }
                else if(maxValue > 600 && maxValue <= 750){

                    mUsageArray = ["0,75 kW", "0,15 kW", "0,225 kW","0,3 kW","0,375 kW", "0,450 kW","0,525 kW", "0,6 kW","0,675kW ","0,75 kW "];
                    return 75;
                }
                else if(maxValue > 750 && maxValue <= 1000){

                    mUsageArray = ["0,1 kW ", "0,2 kW ", "0,3 kW ","0,4 kW ","0,5 kW ", "0,6 kW ","0,7 kW ", "0,8 kW ","0,9 kW "," 1 kW "];
                    return 100;
                }
                else if(maxValue > 1000 && maxValue <= 2000){

                    mUsageArray = ["0,2 kW ", "0,4 kW ", "0,6 kW ","0,8 kW "," 1 kW ", "1,2 kW "," 1,4 kW ", " 1,6 kW "," 1,8 kW "," 2 kW "];
                    return 200;
                }
                else if(maxValue > 2000 && maxValue <= 3000){

                    mUsageArray = [" 0,3 kW ", " 0,6 kW ", " 0,9 kW ","1,2 kW ","1,5 kW ", " 1,8 kW ","2,1 kW ", "2,4 kW ","2,7 kW "," 3 kW "];
                    return 300;
                }
                else if(maxValue > 2000 && maxValue <= 4000){

                    mUsageArray = [" 0,4 kW", "0,8 kW ", "1,2 kW ","1,6 kW ","2 kW ", "2,4 kW ","2,8 kW ", "3,2 kW ","3,6 kW ","4 kW "];
                    return 400;
                }
                else{//defaulter til denne her hvis forbruget overstiger 20kw(meget!)

                    mUsageArray = ["2 kW ", "4 kW ", "6 kW ","8 kW ","10 kW", "12 kW","14 kW ", "16 kW ","18 kW ","20 kW "];
                    return 2000;
                }

            }

            

            //generates an offset pr. viewmode
            //generates an array of labels for x coordinate
            private function generateTimeArrayandCalcOffset():Array<String>{

                var date = Date.now();
                var stringAr = new Array<String>();
                var minutesString = "00";
                var offset = 0.0;
                var tempArray = new Array<String>();
                var hour = date.getHours();
                var minutes = date.getMinutes();

                for(i in 0...24){//generate initial time array


                        stringAr.push(Std.string(i));

                }

                var arrEl = 0;
                stringAr.reverse();

                var tempTime = Std.string(date.getHours());

                for(el in 0...stringAr.length -1 ){//calculate a position according to the time now

                    if(stringAr[el] == tempTime)
                    {
                        arrEl = el;
                    }
                }


                switch(mViewMode){
                    case VIEWMODE_HOUR://Hour
                        mOffset = 0;
      
                        for(i in 0...44){//pushing minutes into array, needs to be reversed

                                if(minutes == 45){
                                    tempArray.push(Std.string(hour)+":45");
                                }
                                if(minutes == 30){
                                    tempArray.push(Std.string(hour)+":30");
                                }
                                if(minutes == 15){
                                    tempArray.push(Std.string(hour)+":15");
                                }
                                if(minutes == 0){
                                    tempArray.push(Std.string(hour)+":00");
                                    hour -= 1;
                                    if(hour == -1){
                                        hour = 23;
                                    }
                                    minutes = 59;
                                }

                                minutes -= 1;

                        }

                        tempArray.reverse();

                    case VIEWMODE_DAY://day
                        if(date.getMinutes() >= 0 && date.getMinutes() < 15){
                           minutesString = "00"; 
                           offset= 0.0;
                        }
                        else if(date.getMinutes() >= 15 && date.getMinutes() < 30){
                            minutesString = "15";
                            offset= 0.25;
                        }
                        else if(date.getMinutes() >= 30 && date.getMinutes() < 45){
                            minutesString = "30"; 
                            offset= 0.50;     
                        }
                        else if(date.getMinutes() >= 45 && date.getMinutes() < 59){
                            minutesString = "45"; 
                            offset= 0.75;
                        }
                        //should be the length of the coordsystem
                        mOffset = ((Lib.current.stage.stageWidth/1.15)/stringAr.length)*offset;
                        //offset = 2.0;//test


                         //trim array an generate the offset and set it
                        tempArray = stringAr.splice(arrEl,stringAr.length);

                        tempArray = tempArray.concat(stringAr);
                        tempArray.reverse();

                                  //to compensate for every second time
                        var NewtimeArray = new Array<String>();  
                 
                        for(time in 0...tempArray.length){

                            if(time%2 == 0){
                                NewtimeArray.push(tempArray[time]+":00");
                            }
                            else{
                                 NewtimeArray.push(" ");
                            }

                        }
                       tempArray  =NewtimeArray;
                        

                    case VIEWMODE_THREEDAYS://3 days
                        offset = date.getHours();

                        var dateCount = date.getDay();


                        for(i in 0...3){    //pushing days into array, needs to be reversed
                            
                            tempArray.push(getWeekDay(dateCount));
                            dateCount -= 1;
                            if(dateCount == -1){
                                dateCount = 6;//start from saturday

                            }

                        }
                        tempArray.reverse();

                        mOffset = (((Lib.current.stage.stageWidth/1.15)/tempArray.length)/24)*offset;



                }

                return tempArray;


            }


        



}
