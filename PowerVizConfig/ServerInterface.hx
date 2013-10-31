
import HouseDescriptor;

class ServerInterface {
	public static var instance(get,null):ServerInterface = null;
	static function get_instance() : ServerInterface {
		if(instance==null)
			instance = new ServerInterface();
		return instance;
	}
	
	private var mCnx:haxe.remoting.HttpAsyncConnection;
	
	public function new() {
		connect();
	}
	
	function connect() {
		#if production
			mCnx = haxe.remoting.HttpAsyncConnection.urlConnect("http://78.47.92.222/pvs/");
		#else
			mCnx = haxe.remoting.HttpAsyncConnection.urlConnect("http://78.47.92.222/pvsdev/");
		#end
		mCnx.setErrorHandler(function(e:Dynamic) {
			Sys.println("Connection error: " + Std.string(e));
		});
	}
	
	public function getHouseDescriptor(houseId:Int) : HouseDescriptor {
		var hd:HouseDescriptor = null;
		var done = false;
		mCnx.Api.getHouseDescriptor.call([houseId], function(data:Dynamic) {
			hd = data;
			done = true;
		});
		while(done==false)
			Sys.sleep(0.1);
		return hd;
	}
	
	public function setOutletColor(houseId:Int, outletId:Int, color:String) : Void {
		mCnx.Api.setOutletColor.call([houseId, outletId, color], function(d:Dynamic){});
	}
	
	public function setRoomColor(houseId:Int, roomId:Int, color:String) {
		mCnx.Api.setRoomColor.call([houseId, roomId, color], function(d:Dynamic){});
	}
	
	
	public function removeFutureHistoryData(houseId:Int, from:Date) {
		#if production
			//This functionality is only allowed on the development server!
		#else
			mCnx.Api.removeHistoryDataOnwards.call([houseId, from], function(d:Dynamic) {});
		#end
	}
} 



