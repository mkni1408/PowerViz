
import haxe.remoting.HttpAsyncConnection;


class DataInterface {

	private static var mCnx : HttpAsyncConnection;

	public static function connect() {
		var url = "http://78.47.92.222/pvsdev/";
		mCnx = HttpAsyncConnection.urlConnect(url);
		mCnx.setErrorHandler(DataInterface.error);
	}
	
	private static function error(err:String) {
		trace("ERROR: " + err);
	}
	
	public static function addLoad(houseId:Int, outletId:Int, add:Float, ?time:Date) {	
		var t:Date = (time==null ? Date.now() : time);
		mCnx.Api.simulator_addToCurrentLoad.call([houseId, outletId, add, t], DataInterface.addLoadDone);
	}
	private static function addLoadDone(v) {	
		//trace(v);
	}
	
	
	public static function setLoad(houseId:Int, outletId:Int, set:Float, ?time:Date) {
		var t:Date = (time==null ? Date.now() : time);
		mCnx.Api.simulator_setCurrentLoad.call([houseId, outletId, set, t], DataInterface.setLoadDone);
	}
	private static function setLoadDone(v) {
		//trace(v);
	}
	
	
	public static function setPowerSource(source:String, time:Date) {
		var args = new Array<Dynamic>();
		args.push(time);
		args.push(source);
		mCnx.Api.simulator_setPowerSource.call([time, source], DataInterface.setPowerSourceDone);
	}
	private static function setPowerSourceDone(v) {
	}

}
