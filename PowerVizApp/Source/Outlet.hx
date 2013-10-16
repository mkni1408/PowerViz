//
//Class that defines an outlet
//

class Outlet{

	private var arrayID:Int;//arrayid for use by the instantiation class
	private var id:String;//ID, is currently not used, but it is intended to be the id of the outlet ex. ADF10102
	private var category:String;//outlet category, this is just ex. lamp, stove, tv etc.
	private var room:String;//room id -> should be set, defaults to default
	//an array of on off data. odd numbers signals that a contact has been connected
	//even numbers that it has been shut off
	private var onOffArray:Array<Float>;

	public function new(_arrayID:Int,_id:String, _category:String, _onOffArray:Array<Float>, _room:String){
		this.arrayID = _arrayID;
		this.id=_id;
		this.category=_category;
		//default value
		if(_room == ""){
			this.room = "Default";
		}
		else{
		this.room = _room;
		}

		this.onOffArray=_onOffArray;
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
	public function getcategory():String{

		return category;
	}
	public function getOnOffData():Array<Float>{

		return onOffArray;
	}
	public function getRoom():String{

		return room;
	}


}