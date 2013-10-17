
import haxe.remoting.HttpAsyncConnection;
import sys.io.File;
import sys.io.FileInput;

class Configuration {

	public function new() {
		#if production
			serverUrl = "http://78.47.92.222/pvs/";
		#else
			serverUrl = "http://78.47.92.222/pvsdev/";
		#end
		
		sleepTime = 1; //Seconds between calls to outlets.
		historyTime = 15; //Minutes between sending history data.
	}
	
	public var serverUrl:String;
	public var houseId:Int;
	
	public var boxIp:String;
	public var boxPort:Int;
	public var boxId:String;
	public var sleepTime:Int;
	public var historyTime:Int;
	
	//Reads the houseId from the file HOUSE.ID on disk.
	public function readHouseId() {
		var file = File.read("HOUSE.ID", false);
		var line = file.readLine();
		houseId = Std.parseInt(line);
		Sys.println("HouseId: " + houseId);
	}
	
	//The reading callback usage is quite experimental, so test properly!!!!
	
	//Connects to the server and reads the config data.
	public function read(cnx:HttpAsyncConnection) : Bool {	
		mReadDone = false;
		cnx.Api.getBoxConfig.call([houseId], onReadDone);
		while(mReadDone==false) {
			Sys.sleep(0.1);
		}
		return true;
	}
	
	private var mReadDone:Bool;
	private function onReadDone(v:Dynamic) : Void {
		//Set the variables with the stuff obtained from the server.
		
		Sys.print("Config: " + v);
		
		if(v==null) {
			mReadDone = true;
			return;
		}
		
		boxIp = v.boxIP==null ? "192.168.1.1" : v.boxIP;
		boxId = v.boxID==null ? "00000" : v.boxID;
		boxPort = v.boxPort==null ? 10001 : v.boxPort;
		sleepTime = v.sleepTime==null ? 1 : v.sleepTime;
		historyTime = v.historyTime==null ? 15 : v.historyTime;		
		
		mReadDone = true;
	}

}
