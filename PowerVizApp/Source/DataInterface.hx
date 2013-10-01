
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
	public function getTotalCurrentLoad() : Float {
		return 576.4; //A random number.
	}
	
	/*Returns the current load on a specific switch.*/
	public function getCurrentLoadOutlet(houseId:Int, outletId:Int) {
	}
	
	/*Returns an array of all switch in the house.*/
	public function getAllOutlets(houseId:Int) : Array<Int> {
		return [1,2,3,4,5,6,7,8];
	}
	

}
