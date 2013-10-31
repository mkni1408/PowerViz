
import haxe.remoting.HttpAsyncConnection;

import Config;


class ServerInterface {

	public static var instance(get,null):ServerInterface;
	static function get_instance() : ServerInterface {
		if(instance==null)
			instance = new ServerInterface();
		return instance;
	}
	
	
	private var mCnx : HttpAsyncConnection;
	
	public function new() {
		this.connect();
	}
	
	public function connect() {
		mCnx = HttpAsyncConnection.urlConnect("http://78.47.92.222/pvsdev/");
		mCnx.setErrorHandler(function(e:Dynamic) {
			Sys.println("Remoting error: " + e);
		});
	}
	
	public function sendLoadData(houseId:Int, outletId:Int, load:Float) {
		mCnx.Api.setOutletLoad.call([houseId, outletId, load], function(v:Dynamic) {});
	}
	
	public function sendHistData(houseId:Int, outletId:Int, time:Date, load:Float) {
		mCnx.Api.addOutletHistory.call([houseId, outletId, time, load], function(v:Dynamic) {});
	}
	
	public function sendLayoutData(houseId:Int, data:Array<LayoutData>) {
		mCnx.Api.setZenseLayout.call([houseId, data], function(v:Dynamic) {});
	}
	
	public function deletePreviousData(houseId:Int, from:Date) {
		mCnx.Api.removeHistoryDataOnwards.call([houseId, from], function(v:Dynamic){});
	}
	
	public function configure(houseId:Int) {
		
		var done=false;
		mCnx.Api.getBoxConfig.call([houseId], function(v:Dynamic) {
			Config.instance.sleepTime = v.sleepTime;
			Config.instance.historyInterval = v.historyTime;
			done = true;
		});
		while(done==false)
			Sys.sleep(0.1);
		
	}

}
