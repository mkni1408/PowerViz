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

/**
Screen displaying the Areal diagram.
Uses the ArealDiagram class for drawing the special diagram.

This class obtains data from the DataInterface singleton class.
**/

class ArealScreen extends Sprite {
        //should be changed to Hour,day,month
        private static inline var VIEWMODE_DAY:Int = 0;
        private static inline var VIEWMODE_WEEK:Int = 1;
        private static inline var VIEWMODE_MONTH:Int = 2;

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

        public function new() {
                super();
                
                mRoomArray = new Array<String>();
                mColorArray = new Array<Int>();

                getColorAndRoomData();

                mViewMode = VIEWMODE_WEEK; //Daymode by default.
                
                mBack = new Sprite();

                mBack.graphics.beginFill(0xFFFFFF);
                mBack.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageWidth);
                mBack.graphics.endFill();
                this.addChild(mBack);

                mTimeArray = ["","2:00","","4:00","","6:00","","8:00","","10:00","","12:00",""
                                                        ,"14:00","","16:00","","18:00","","20:00","","22:00","","24:00"];


                mUsageArray = ["100Wt", "200Wt", "300wt","400Wt","500Wt", "600Wt","700Wt", 
                                                        "800Wt","900Wt","1000Wt"];

                
                mDiagram = new ArealDiagram();
                mDiagram.mouseEnabled=false;
                
                mTitle = new TextField();
                mTitle.mouseEnabled=false;
                mTitle.text = "Forbrug i dag ";
                mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
                mTitle.selectable = false;
                
                mTimeButton = new TimeChangeButton([VIEWMODE_DAY, VIEWMODE_WEEK,VIEWMODE_MONTH,],mViewMode,onButtonPush); //Day, week, month.
                
                
                mCoordSys = new CoordSystem();
                
                addChildrenToBack();
                
                testFunctionToBeRemoveLater();
                
        }
        
        private function addChildrenToBack() {        
                //mBack.addChild(mDiagram);
                mBack.addChild(mTimeButton);

                mBack.addChild(mCoordSys);
                mBack.addChild(mTitle);
        }
        
        /**
        Places the graphical elements on the screen.
        **/
        private function doLayout() {

                mTitle.width = mTitle.textWidth;        
                mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
                mTitle.y = Lib.stage.stageHeight/30;

                //mBack.addChild(mTitle);

                mLegend = new Legend();
                mLegend.drawLegend(mBack.width/1.25,mBack.height/1.25,mColorArray.length,mRoomArray, mColorArray);
                mBack.addChild(mLegend);
                //mBack.addChild(mLegend);
        
        
                mBack.addChild(mDiagram);
                mDiagram.width = Lib.stage.stageWidth / 1.15;
                mDiagram.height = Lib.stage.stageHeight / 1.25;
                
                
                mTimeButton.x = Lib.stage.stageWidth - mTimeButton.width;
                mTimeButton.y = 0;

                mCoordSys.generate(Lib.stage.stageWidth/1.25, (Lib.stage.stageHeight/1.25)-mLegend.height, "X", "Y", (Lib.stage.stageWidth/1.25)/mTimeArray.length, ((Lib.stage.stageHeight/1.25)-mLegend.height)/mUsageArray.length, 
                                                                                                                        mTimeArray, mUsageArray, true, true);
                mCoordSys.x = (Lib.stage.stageWidth - mDiagram.width);
                mCoordSys.y = (Lib.stage.stageHeight/1.25)+50;
                

                mLegend.x = mCoordSys.x;
                mLegend.y = mCoordSys.y + mLegend.height;

                mDiagram.x = mCoordSys.x;
                mDiagram.y = mCoordSys.y;        
                

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
        

                if(mViewMode==0){//hour
                    r = DataInterface.instance.getArealUsageHour();
                }
                 if(mViewMode==1){//Day
                    r = DataInterface.instance.getArealUsageToday();
                }
                 if(mViewMode==2){//Week
                    r = DataInterface.instance.getArealUsageWeek();
                }

                

                var rvIds = new Array<Int>();
                var rvUsage = new Map<Int, Array<Float>>();
                var rvColors = new Map<Int, Int>();

                rvIds = r.outletIds;
                rvUsage = r.watts;
                rvColors = r.colors;

                onDataReceivedDay(rvIds,rvUsage,rvColors);
        }        
        
        private function onDataReceivedDay(outletIds:Array<Int>, usage:Map<Int, Array<Float>>, colors:Map<Int, Int>) : Void {
                
                var _usage = new Array< Array<Float> >();
                var _colors = new Array<Int>();
                var _ta:Array<Float>;

                if(outletIds.length == 0){//hack, ellers forsvinder diagrammet ud af siden
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

                                
                        
                            _colors.push(colors.get(id));

                    }
            }
                
                mDiagram.graphics.clear();

                mDiagram.generate(_usage, _colors, Lib.stage.stageWidth / 1.15,Lib.stage.stageHeight / 1.25);
                
        }
        
        /**Some test function.**/
        private function testFunctionToBeRemoveLater() { 
                fillWithData();
                doLayout();
        }
        
        private function onButtonPush(coordSystemType:Int):Void{

                switch( coordSystemType ) {
                    case 0:
                mViewMode = VIEWMODE_DAY;
                    case 1:
                mViewMode = VIEWMODE_WEEK;
                case 2:
                mViewMode = VIEWMODE_MONTH;
                    default:
                mViewMode = VIEWMODE_DAY;
            }
                
                redrawEverything(); 
        }

        private function redrawEverything():Void{

                if(mViewMode == 0){
                        //hour
                        mTimeArray = new Array<String>();//ensure that array is empty
                        mUsageArray = ["100Wt", "200Wt", "300wt","400Wt","500Wt", "600Wt","700Wt", "800Wt","900Wt","1000Wt"];
                         var date = Date.now();
                         var hour = date.getHours();
                         var minutes = date.getMinutes();


                        for(i in 0...60){

                                if(minutes == 45){
                                    mTimeArray.push(Std.string(hour)+":45");
                                }
                                if(minutes == 30){
                                    mTimeArray.push(Std.string(hour)+":30");
                                }
                                if(minutes == 15){
                                    mTimeArray.push(Std.string(hour)+":15");
                                }
                                if(minutes == 0){
                                    mTimeArray.push(Std.string(hour)+":00");
                                    hour -= 1;
                                    minutes = 59;
                                }

                                minutes -= 1;

                        }

                         mTimeArray.reverse();
                        //mTimeArray = [":15",":30",":45",""];


                        mTitle.text = "Forbrug denne time ";

                }
                if(mViewMode == 1){
                        //day
                        mUsageArray = ["1kWt  ", "2kWt  ", "3kWt  ","4kWt  ","5kWt  ", "6kWt  ","7kWt  ", "8kWt  ","9kWt  ","10kWt  "];
                        mTimeArray = ["","2:00","","4:00","","6:00","","8:00","","10:00","","12:00",""
                                                        ,"14:00","","16:00","","18:00","","20:00","","22:00","","24:00"];

                        mTitle.text = "Forbrug i dag ";

                }
                if(mViewMode == 2){
                        mTimeArray = new Array<String>();//ensure that array is empty
                        var dateCount = Date.now().getDay();


                        for(i in 0...6){    //pushing days into array, needs to be reversed
                            
                            mTimeArray.push(getWeekDay(dateCount));
                            dateCount -= 1;
                            trace(dateCount);
                            if(dateCount == -1){
                                dateCount = 6;

                            }

                        }
                        mTimeArray.reverse();
                        
                        ///week
                        mUsageArray = ["10kWt ", "20kWt ", "30kWt ","40kWt ","50kWt ", "60kWt ","70kWt ", "80kWt ","90kWt ","100kWt "];
                        //mTimeArray = ["Tirsdag","Onsdag","Torsdag","Fredag","Lørdag","Søndag"];
                        mTitle.text = "Forbrug denne uge ";

                }
                
                

                mTimeButton.changeButtonState(mViewMode);
                mTitle.setTextFormat(FontSupply.instance.getTitleFormat());

                while(mBack.numChildren > 0)
                    mBack.removeChildAt(0);



                mDiagram = new ArealDiagram();
                mLegend = new Legend();
                mCoordSys = new CoordSystem();
                
                fillWithData();
                addChildrenToBack();
                doLayout();

                
        }



        private function getColorAndRoomData():Void{
                        
                mRoomArray = new Array<String>();
                mColorArray = new Array<Int>();
                for(r in DataInterface.instance.houseDescriptor.getRoomArray()) {
                        mRoomArray.push(r.roomName);
                        mColorArray.push(r.roomColor);
                }
                
        }

        private function getWeekDay(day:Int):String{

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

}