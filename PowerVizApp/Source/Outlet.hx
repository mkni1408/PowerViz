import OnOffData;
//
//Class that defines an outlet
//

class Outlet{

	private var arrayID:Int;//arrayid for use by the instantiation class

	private var id:String;//ID, is currently not used, but it is intended to be the id of the outlet ex. ADF10102

	private var name:String;//outlet category, this is just ex. lamp, stove, tv etc.

	private var room:String;//room id -> should be set, defaults to default

	private var wattUsageToday:Float;//total watt usage today 
	
	public var outletColor(default,null):Int; //Color of the outlet.
	public var roomColor(default,null):Int; //Color of the room.

	//an array of on off data. odd numbers signals that a contact has been connected
	//even numbers that it has been shut off
	private var onOffArray:Array<OnOffData>;

	public function new(_arrayID:Int,_id:String, _name:String, ?_onOffArray:Array<OnOffData>, 
								?_roomName:String, ?_wattUsage:Float, ?_roomColor:Int, ?_outletColor:Int){
		this.arrayID = _arrayID;
		this.id=_id;
		this.name=_name==null ? "Default" : _name;
		this.name=_name=="" ? "Default" : _name;
		//default value:
		this.room = _roomName==null ? "Default" : _roomName;

		this.onOffArray = _onOffArray==null ? new Array<OnOffData>() : _onOffArray;
		this.wattUsageToday = _wattUsage==null ? 0 : _wattUsage; 
		
		this.outletColor = _outletColor!=null ? _outletColor :  0xFF00FF;
		this.roomColor = _roomColor!=null ? _roomColor : 0xFF00FF;
	}


	public function getArrayid():Int{

		return arrayID;
	}

	public function setArrayID(aId:Int):Void{
		arrayID = aId;
	}

	public function getid():String{

		return id;
	}
	public function getname():String{

		return name;
	}
	public function getOnOffData():Array<OnOffData>{

		return onOffArray;
	}
	public function setOnOffData(data:Array<OnOffData>) {
	
		onOffArray = data;
	}
	public function getRoom():String{

		return room;
	}
	public function getWattUsageToday():Float{
		
		return wattUsageToday;
	}


}
