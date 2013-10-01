
/*
Class that handles all data comming from the server.
This class works mainly as a dummy during the development.

Later on, when the server side is getting there, this dummy class wil start spitting out REAL DATA.
So, beware, be nice to the interface.
*/

class DataInterface {

	static private var __instance : DataInterface = null;
	public static var instance(get, never) : DataInterface;
	static function get_instance() : DataInterface {
		if(__instance == null)
			__instance = new DataInterface();
		return __instance;
	}
	
	public function new() {
	}
	
	
	/*Returns the current total load in watts.*/
	public function getTotalCurrentLoad(houseId:Int) : Float {
		return 576.4; //A random number.
	}
	
	/*Returns the current load in watts on a specific switch.*/
	public function getCurrentLoadOutlet(houseId:Int, outletId:Int) {
	
		var values = [122, 89, 56, 245, 189,111, 78, 411, 211];
		return values[outletId];
	}
	
	/*Returns an array of all switch in the house.*/
	public function getAllOutlets(houseId:Int) : Array<Int> {
		return [0,1,2,3,4,5,6,7,8];
	}
	
	/*Returns all names for all outlets.*/
	public function getAllOutletNames(houseId:Int) : Array<String> {
		return ["TV1", "TV2", "PS3", "XBox", "Kogekande", "Fryser", "MedieCenter Stuen", "Massagestol", "Løbebånd"];
	}
		
	/*Returns a specific outlet name, based on the outlet ID.*/
	public function getOutletName(houseId:Int, outletId:Int) : String{
		return getAllOutletNames(houseId)[outletId];
	}
	
	
}


