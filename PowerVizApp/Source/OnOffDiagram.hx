package;

import flash.display.Sprite;
import flash.Lib;

import CoordSystem;
import OnOffBar;
import Outlet;
import ColorGenerator;
import DataInterface;
import flash.text.TextField;
import FontSupply;
import OnOffData;
import Legend;
import PowerTimer;

/*

Class that defines an on off bargraph

*/
class OnOffDiagram extends Sprite{

	private var mBack : Sprite;
	private var mCoordSystem:CoordSystem;
	private var mMainSprite: Sprite;
	private var monOffBar: OnOffBar;

	private var mtimeArray: Array<String>;
	private var mTestArray: Array<Float>;

	private var mNewIDArray: Array<String>;
	private var mNewRoomArray: Array<String>;
	private var mNewDataArray:Array<Float>;
	private var mNewOutletArray: Array<Outlet>;
	//array holding map from a room to categories in outletarray
	private var mMapArray:Array<Array<Int>>;
	private var mColorArray:Array<Int>;
	private var mTitle : TextField;
	private var mLegend:Legend;
	private var mOffset = 1.0;

	private var mTimer:PowerTimer;
	#if demo
		private var mTimerInterval:Int = 60*1000; //Once a minute in demo mode.
	#else
		private var mTimerInterval:Int = 5*60*1000; //Every 5 minutes in normal mode.
	#end

	public function new(){

		super();


		mNewIDArray = new Array<String>();
		mNewRoomArray = new Array<String>();
		mNewDataArray = new Array<Float>();
		mNewOutletArray = new Array<Outlet>();
		mMapArray = new Array<Array<Int>>();
		mColorArray = new Array<Int>();
		mLegend = new Legend();

		//mtimeArray = generateTimeArrayandCalcOffset();

		mBack = new Sprite();
		mBack.graphics.beginFill(0xFFFFFF, 0);
		mBack.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageHeight);
		mBack.graphics.endFill();
		
		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		mTitle.text = "Tænd/sluk i dag";
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
		mTitle.selectable = false;
		mBack.addChild(mTitle);

		
		mTimer = new PowerTimer(mTimerInterval);	
		mTimer.onTime = onTime;
		mTimer.start();
		
		mCoordSystem = new CoordSystem();
		
		updateData();
				
	}
	
	private function onTime() {
		updateData();
	}
	
	private function updateData() {
		var data = DataInterface.instance.getOnOffData();
		//
		
		handleCategoryData(data);
		mtimeArray = generateTimeArrayandCalcOffset();
		drawDiagram();
		mBack.addChild(mTitle);
		mBack.addChild(monOffBar);
		this.addChild(mBack);
	}
	
	
	private function drawDiagram() {
		//fetch data  
		//NOT necessary, as its called from the callback. //fetchCategoryData();

		//calculates the coordinate system size
		
		while(mBack.numChildren > 0)
			mBack.removeChildAt(0);
		
		//Draw coordinatesystem, legend and lines
		calculateandDrawCoordSystem();
		calculateandDrawLines();
		
		//set textlabel position
		mTitle.width = mTitle.textWidth+2;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 0;
		

		var testSprite = new Sprite();
		monOffBar = new OnOffBar();

		//add the bars
		var outletCounter = 0;

		for(i in 0...mMapArray.length){
			
			var outArray = mMapArray[i];
			


			
			for(count in 0...outArray.length){
				fetchOnOffData(mNewOutletArray[outArray[count]],mColorArray[i]);
				
			}

		}
		
		//add to parent sprite	
		testSprite.addChild(mCoordSystem);

		mBack.addChild(testSprite);

	}
	
	
	//should Calculate how large the diagram should be
	private function calculateandDrawCoordSystem():Void{
		
		//legend = legend.drawLegend(mBack.width/1.25,mBack.height/1.25,mColorArray.length,mNewRoomArray,mColorArray);
		mLegend = new Legend();
		mLegend.drawLegend(mBack.width/1.20,mBack.height/1.20,mColorArray.length,mNewRoomArray,mColorArray);

		mBack.addChild(mLegend);

		mCoordSystem.generate(mBack.width/1.20, (mBack.height/1.20)-mLegend.height, "X", "Y", 
								(mBack.width/1.20)/mtimeArray.length,((mBack.height/1.20)-mLegend.height)/mNewIDArray.length,
								mtimeArray,mNewIDArray,true,true,false,true,mOffset);

		mCoordSystem.x = (mBack.width- mCoordSystem.width);
		mCoordSystem.y = (mBack.height/1.25)+50;
		mLegend.x =mCoordSystem.x;
		mLegend.y = mCoordSystem.y + mLegend.height + 10;
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
        mTitle.y = 0;
		
	}
	
	
	//draws seperatorlines
	private function calculateandDrawLines():Void{
		var counter = 0;
		var beforeCounter = 0;

		var counterArray = new Array<Int>();

		counterArray.push(counter);


		for(i in 0...mMapArray.length){

			var tmpMap = mMapArray[i];
			var arrayTail = tmpMap.length;
			counter=(counter+mMapArray[i].length);
			
			mCoordSystem.generateSeperatorLines(counter,counterArray[beforeCounter],mNewRoomArray[i]);
			
			counterArray.push(counter);
			beforeCounter += 1;
			
		}

	}


	//NOT USED YET: Should redraw the bars everytime the timer asks for data
	private function redrawBars():Void{

		//should fetch the data
		//fetchOnOffData();

		//should examine the array
		//should draw the bars accordingly to the array

	}

	//UPDATE: Implemented as a callback to DataInterface...
	//fetch the categories along with how many contacts in each room
	//(should be called in init so that we can calculate size of graph)
	//shoukld be called room
	private function handleCategoryData(data:Array<Outlet>):Void{
	
		mNewIDArray = new Array<String>();
		mNewRoomArray = new Array<String>();
		mNewDataArray = new Array<Float>();
		mNewOutletArray = new Array<Outlet>();
		mColorArray = new Array<Int>();

		mMapArray = new Array<Array<Int>>();
		
		var tempOutlet = data; //DataInterface.instance.getOnOffData();//fetch the outlets

		
		mMapArray=rearrangeData(tempOutlet);//rearrange the data


		for(i in 0...mMapArray.length){	//add sorted data to outletarray and name array
			
			var tmpAr = mMapArray[i];
			
			for(count in 0...tmpAr.length){
				mNewOutletArray.push(tempOutlet[tmpAr[count]]);
				mNewIDArray.push(tempOutlet[tmpAr[count]].getname());

			}
			
		}
		
		
		//set the ArrayId to match the new place in the array
		for(i in 0...mNewOutletArray.length){

			mNewOutletArray[i].setArrayID(i);	
		}

		
		//adds all the outlets in order to the outlet array
		for( i in 0...mNewIDArray.length ) {
			var mTempOutletArray = mNewIDArray[i];

        	for(outlet in 0...mTempOutletArray.length){
        		
				//Michael har planer om at gøre nogt her! Tror han nok.
        	}
        	
    	}
    	//update map to match the new id's
    	updateMap(mNewOutletArray);


	}
	
	
	//draws bars in the coordinate system
	private function drawOnOffData(outletData:Array<OnOffData>,id:Int,color:Int):Void{

		var count = 0;
		var count2 = 1;
		var lengthofArray =outletData.length;
		var incId = id;
		trace("......");
			trace(outletData);
		trace("......");
		

		for(i in 0...lengthofArray){


			mCoordSystem.drawBar(outletData[i], mCoordSystem.getYcoordinate(incId+1),mCoordSystem.getYcoordinate(incId+1),color);

		}


	}

	//no point to this function except overhead - calls the draw data function
	private function fetchOnOffData(outlet:Outlet,color:Int):Void{
		
		drawOnOffData(outlet.getOnOffData(),outlet.getArrayid(),color);		
		
	}

	
	//rearrange data so that it can be used in the coordinate systemß
	private function rearrangeData(outletArray:Array<Outlet>):Array<Array<Int>>{

		//add unique rooms to the room array
		for(i in 0...outletArray.length){

			var isPresent = false;

			for(count in 0...mNewRoomArray.length){
				
				if(mNewRoomArray[count]==outletArray[i].getRoom()){
					//the category is present so we set the bool
					isPresent = true;
					break;
				}
				else{
					//the category was not present
					//TODO: HANDLE IT
				}
			}

			if(isPresent){
				//the category was preasent -> do not add
			}
			else{
				//the category was not present -> add to array
				mNewRoomArray.push(outletArray[i].getRoom());
				mColorArray.push(outletArray[i].roomColor);

			}

		}


		var mapArray = new Array<Array<Int>>();

		

		//add room names
		for(i in 0...mNewRoomArray.length){

			var isPresent = false;

			var tempMap = new Array<Int>();

			for(count in 0...outletArray.length){
				
				if(outletArray[count].getRoom()==mNewRoomArray[i]){
					isPresent = true;

					tempMap.push(count);
					//break;
				}
				else{
					//the category was not present
					//TODO: HANDLE IT

				}

			}
			mapArray.push(tempMap);

		}
		return mapArray;

	}
	
	
	
	private function updateMap(outletArray:Array<Outlet>):Void{

		var mapArray = new Array<Array<Int>>();

		//add room names
		for(i in 0...mNewRoomArray.length){

			var isPresent = false;
			
			var tempMap = new Array<Int>();

			for(count in 0...outletArray.length){
				
				if(outletArray[count].getRoom()==mNewRoomArray[i]){
					isPresent = true;

					tempMap.push(count);
					//break;
				}
				else{
					//the category was not present
					//TODO: HANDLE IT

				}
				
			}
			mapArray.push(tempMap);

			mMapArray = mapArray;

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

                for(i in 0...24){


                        stringAr.push(Std.string(i));

                }

                var arrEl = 0;
                stringAr.reverse();

                var tempTime = Std.string(date.getHours());

                for(el in 0...stringAr.length -1 ){//calculate

                    if(stringAr[el] == tempTime)
                    {
                        arrEl = el;
                    }
                }


                
                
                    
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
                        mOffset = ((Lib.stage.stageWidth/1.20)/stringAr.length)*offset;
                        //offset = 2.0;//test


                        

                        

                


                         //calculate the offset and set it
                        tempArray = stringAr.splice(arrEl,stringAr.length);

                        tempArray = tempArray.concat(stringAr);
                        tempArray.reverse();
                        

                   
                 

 

                return tempArray;


            }



}
