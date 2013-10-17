package;

import flash.display.Sprite;
import CoordSystem;
import flash.Lib;
import OnOffBar;
import Outlet;
import ColorGenerator;
import DataInterface;
import flash.text.TextField;
import FontSupply;

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



	public function new(){

		super();


		mNewIDArray = new Array<String>();
		mNewRoomArray = new Array<String>();
		mNewDataArray = new Array<Float>();
		mNewOutletArray = new Array<Outlet>();
		mMapArray = new Array<Array<Int>>();
		mColorArray = new Array<Int>();

		mtimeArray = ["","2:00","","4:00","","6:00","","8:00","","10:00","","12:00","","14:00","","16:00","","18:00","","20:00","","22:00","","24:00"];

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
		


		mCoordSystem = new CoordSystem();
		//fetches room date
		fetchCategoryData();//done

		//calculates the coordinate system size
		
		calculateandDrawCoordSystem();
		calculateandDrawLines();

		

		mTitle.width = mTitle.textWidth+2;	
		mTitle.x = (Lib.stage.stageWidth - mTitle.textWidth) / 2;
		mTitle.y = 20;
		//mBack.addChild(mMainSprite);


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

		//add legend
		mCoordSystem.createLegend(mColorArray.length,mNewRoomArray,mColorArray);


		//add to parent sprite	
		testSprite.addChild(mCoordSystem);

		mBack.addChild(testSprite);

		mBack.addChild(monOffBar);

		this.addChild(mBack);
		
							


	}
	//should Calculate how large the diagram should be
	private function calculateandDrawCoordSystem():Void{


		mCoordSystem.generate(mBack.width/1.25, mBack.height/1.35, "X", "Y", (mBack.width/1.25)/mtimeArray.length,(mBack.height/1.35)/mNewIDArray.length,mtimeArray,mNewIDArray,false,true);


		mCoordSystem.x = (mBack.width- mCoordSystem.width);
		mCoordSystem.y = (mBack.height-75);


		
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
			
			if(counterArray.length == 1){
				//mCoordSystem.generateSeperatorTextFields(counter,counterArray[beforeCounter],mNewRoomArray[i]);
				counterArray.push(counter);
				beforeCounter ++;
			}
			else{

				//mCoordSystem.generateSeperatorTextFields(counter,counterArray[beforeCounter],mNewRoomArray[i]);
				counterArray.push(counter);
				beforeCounter ++;
				
			}
			
			
			
			
			
		}

	}


	//redraw the bars
	private function redrawBars():Void{

		//should fetch the data
		//fetchOnOffData();

		//should examine the array
		//should draw the bars accordingly to the array

	}


	//fetch the categories along with how many contacts in each room
	//(should be called in init so that we can calculate size of graph)
	//shoukld be called room
	private function fetchCategoryData():Void{
		
		
		var tempOutlet= DataInterface.instance.getOnOffData();//fetch the outlets

		
		mMapArray=rearrangeData(tempOutlet);//rearrange the data

		var colorGenerator = new ColorGenerator();

		
		mColorArray = colorGenerator.generateColors(mMapArray.length);//generate colors for legend and bars

		for(i in 0...mMapArray.length){
			
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
        		
				
        	}
        	
    	}

    	updateMap(mNewOutletArray);


	}

	private function drawOnOffData(outletData:Array<Float>,id:Int,color:Int):Void{

		var count = 0;
		var count2 = 1;
		var lengthofArray =Math.floor((outletData.length/2));
		var incId = id;
		
		for(i in 0...lengthofArray){

			mCoordSystem.drawBar(outletData[count], outletData[count2], mCoordSystem.getYcoordinate(incId+1),mCoordSystem.getYcoordinate(incId+1),color);


			count=count+2;
			count2=count2+2;


		}

	}


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

			}

			//moutletArray.push(mOutletArray[i]);
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