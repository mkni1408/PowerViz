package;

import flash.display.Sprite;
import flash.utils.Timer;
import flash.Lib;
import flash.events.TimerEvent;

import CoordSystem;
import OnOffBar;
import Outlet;
import ColorGenerator;
import DataInterface;
import flash.text.TextField;
import FontSupply;
import OnOffData;
import Legend;

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

	private var mTimer:Timer;

	public function new(){

		super();


		mNewIDArray = new Array<String>();
		mNewRoomArray = new Array<String>();
		mNewDataArray = new Array<Float>();
		mNewOutletArray = new Array<Outlet>();
		mMapArray = new Array<Array<Int>>();
		mColorArray = new Array<Int>();
		mLegend = new Legend();

		mtimeArray = ["","2:00","","4:00","","6:00","","8:00","","10:00","","12:00",""
									,"14:00","","16:00","","18:00","","20:00","","22:00","","24:00"];

		mBack = new Sprite();
		mBack.graphics.beginFill(0xFFFFFF);
		mBack.graphics.drawRect(0,0, Lib.stage.stageWidth, Lib.stage.stageHeight);
		mBack.graphics.endFill();
		
		mTitle = new TextField();
		mTitle.mouseEnabled=false;
		mTitle.text = "Forbrug i dag";
		mTitle.setTextFormat(FontSupply.instance.getTitleFormat());
		mTitle.selectable = false;
		mBack.addChild(mTitle);

		/*
		mTimer = new Timer(5*1000); //Should be run every 5 minutes.		
		mTimer.addEventListener(TimerEvent.TIMER, onTime);
		mTimer.start();
*/
		mCoordSystem = new CoordSystem();
		
		DataInterface.instance.requestOnOffData(onDataReturnedFromDataInterface);
				
	}
	
	private function onTime(event:TimerEvent) {
		DataInterface.instance.requestOnOffData(onDataReturnedFromDataInterface);
	}
	
	private function onDataReturnedFromDataInterface(data:Array<Outlet>) : Void {
		
		handleCategoryData(data);

		drawDiagram();
		
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
		mTitle.y = 20;
		

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
		mLegend.drawLegend(mBack.width/1.25,mBack.height/1.25,mColorArray.length,mNewRoomArray,mColorArray);

		mBack.addChild(mLegend);

		mCoordSystem.generate(mBack.width/1.25, (mBack.height/1.25)-mLegend.height, "X", "Y", 
								(mBack.width/1.25)/mtimeArray.length,((mBack.height/1.25)-mLegend.height)/mNewIDArray.length,
								mtimeArray,mNewIDArray,false,true);

		mCoordSystem.x = (mBack.width- mCoordSystem.width);
		mCoordSystem.y = (mBack.height/1.25)+50;
		mLegend.x =mCoordSystem.x;
		mLegend.y = mCoordSystem.y + mLegend.height;
		
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



}
