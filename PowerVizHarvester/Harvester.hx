
import sys.net.Socket;
import sys.net.Host;
import haxe.remoting.HttpAsyncConnection;

import Configuration;
import LayoutData;
import OutletBuffer;

class Harvester {

	public static function main() {
		Sys.println("Harvester is running!");
		Harvester.instance.runMain();
	}
	
	//----------------------------------
	
	public static var instance(get,null) : Harvester = null;
	static function get_instance() : Harvester {
		if(instance==null)
			instance = new Harvester();
		return instance;
	}
	
	
	private var mConfig:Configuration;
	
	private var mTcpSock:Socket;
	private var mRemote:HttpAsyncConnection; //RemotingConnection.
	
	private var mBuffers:Map<String, OutletBuffer>; //Array of buffers that stores usage over time.
	
	private function new() {
		mTcpSock = null;
		mRemote = null;
		mConfig = new Configuration();
		mBuffers = new Map<String, OutletBuffer>();
	}
	
	private function runMain() {
	
		remoteConnect();
		mConfig.readHouseId();
		mConfig.read(mRemote);
		
		var layoutData = getLayoutData();
		sendLayoutData(layoutData);
		
		for(layout in layoutData) {
			mBuffers.set(layout.outletId, new OutletBuffer(mConfig.houseId, Std.parseInt(layout.outletId), mRemote, mConfig.historyTime));
		}
		
		if(layoutData.length==0) {
			sendLogData("No layout data obtained!");
			return;
		}
		
		sendLogData("Starting the Harvester loop");
		
		var load:Int=0;
		while(true) { //The neverending loop!!!!
		
			if(mAttemptRemotingReconnection==true) //If we should reconnect.
				remoteReconnect();
		
			for(outlet in layoutData) {
				load = getOutletWNow(outlet.outletId);
				sendLoad(Std.parseInt(outlet.outletId), load);
				mBuffers.get(outlet.outletId).update(getServerTime(), load);
			
			}
			
		}
		
	}
	
	private var mAttemptRemotingReconnection:Bool = false; //True if Harvester should try to reconnect the mRemote connection.
	//Connects to the PowerVizServer using remoting.
	private function remoteConnect() {
		mRemote = HttpAsyncConnection.urlConnect(mConfig.serverUrl);
		if(mRemote==null) {
			sendLogData("Could not connect");
			return;
		}
		mAttemptRemotingReconnection = false; //We will not attempt connection, since we are connected already.
		mRemote.setErrorHandler(remoteConnectionErrorHandler);
	}
	
	private function remoteConnectionErrorHandler(err:Dynamic) {
		sendLogData("Error: " + Std.string(err));
		mAttemptRemotingReconnection = true;
	}
	
	//Disconnects from the PowerVizServer.
	private function remoteReconnect() {
	
		if(mRemote!=null)
			mRemote.setErrorHandler(null);
			
		mRemote = null;
		mAttemptRemotingReconnection = false;
		remoteConnect();
	}
	
	private function sendLayoutData(data:Array<LayoutData>) {
		if(data.length==0) //Don't send if we do not have data.
			return; 
			
		if(mRemote==null) {
			sendLogData("Could not send LayoutData - connection==null");
			return;
		}

		var f = function(v:Dynamic) : Void {};
		mRemote.Api.setZenseLayout.call([mConfig.houseId, data],f);
	}

	
	private function sendLoad(outletId:Int, load:Int) {
		if(mRemote==null) {
			sendLogData("Could not send Load data - connection==null");
			return;
		}
		var f = function(v:Dynamic) : Void {};
		mRemote.Api.setOutletLoad.call([mConfig.houseId, outletId, load], f);
	}
	
	//Sends log data to the server, if connected.
	private function sendLogData(msg:String, ?pi:haxe.PosInfos) {
		var str = Std.string(pi.fileName) + " - " + Std.string(pi.lineNumber) +": " + msg;
		Sys.println(str);
		
		if(mRemote==null)
			return;
		
		var f = function(v:Dynamic) {};
		mRemote.Api.logBox.call([mConfig.houseId, getServerTime(), str]);
	}
	
	//Gets and returns the current time on the server.
	public function getServerTime() : Date {
		var time:Date=null;
		var done=false;
		mRemote.Api.getTime.call([], function(d:Dynamic) {
			time = d;
			done = true;
		});
		while(done==false)
			Sys.sleep(0.05);
			
		return time;
	}


	//Connects to the box. Remember to disconnect from the box as soon
	//as data has been obtained.
	private function connectToBox() : Bool {
		mTcpSock = new Socket();
		try {
			mTcpSock.connect(new Host(mConfig.boxIp), mConfig.boxPort);
			mTcpSock.setTimeout(10);
		}
		catch(e:Dynamic) {
			sendLogData("Error connecting to box (socket error): " + Std.string(e));
			return false;
		}
		
		var r = writeZenseString(">>Login " + mConfig.boxId + "<<");
		var ri = isolateZenseString(r);
		if(ri != "Login Ok") {
			sendLogData("Error loggin' in to box. Got this answer: " + r);
			return false;
		}
		return true;
	}
	
	//Disconnencts from the box. Call this as soon as possible.
	private function disconnectFromBox() : Void {
	
		//Send Logout:
		var r = writeZenseString(">>Logout<<");
		var ri = isolateZenseString(r);
		if(ri != "Logout Ok") {
			sendLogData("Failed to log out of box");
			return;
		}
			
		try {
			mTcpSock.close();
		}
		catch(e:Dynamic) {
			sendLogData("Error closing socket: " + Std.string(e));
		}
	}
	
	
	//Writes a string to the zense PC-boks, then returns the response string from the box.
	private function writeZenseString(str:String) : String {
		if(mTcpSock==null) {
			sendLogData("Socket == null");
			return "";
		}
		
		try {
			mTcpSock.write(str);
		}
		catch(e:Dynamic) {
			sendLogData("Error writing string: " + str + " : " + Std.string(e));
		}
		
		var r = "";
		try {
			r = mTcpSock.input.readLine();
		}
		catch(e:Dynamic) {
			sendLogData("Error reading string: " + Std.string(e));
		}

		return r;

	}
	
	//Only removes the >> and <<.
	private function isolateZenseString(str:String) : String {
		var start = str.indexOf(">>");
		var end = str.indexOf("<<");
		return str.substring(start+2, end);
	}
	
	//Removes the >> and <<, then splits the result at the spaces.
	private function splitZenseString(str:String) : Array<String> {
		return isolateZenseString(str).split(" ");
	}
	
	
	//----------------------------------------
	
	//Returns an array of all electrical outlets Ids.
	private function getOutletIds() : Array<String> {
		Sys.sleep(mConfig.sleepTime);

		if(!connectToBox())
			return null;

		var r = writeZenseString(">>Get Devices<<");
		disconnectFromBox();
		
		var pieces = splitZenseString(r);
		var devices = new Array<String>();
		for(p in pieces.slice(2)) {
			devices.push(StringTools.replace(p, ",", ""));
		}
		return devices;
	}
	
	/**
	Gets a property. Available properties are:
	Type, Name, Room, Floor.
	**/
	private function getOutletProperty(id:String, property:String) : String {
	
		//Check that the supplied property is valid:
		var availableProps = ["Type", "Name", "Room", "Floor"];
		if(Lambda.has(availableProps, property)==false) {
			sendLogData("Property not ok: " + property);
			return "";
		}
	
		//Sleep, to avoid blocking the zense system:
		Sys.sleep(mConfig.sleepTime);
		
		//Connect to the box and get the data:
		if(!connectToBox())
			return "";
			
		var r = writeZenseString(">>Get " + property + " " + StringTools.trim(id) + "<<");
		disconnectFromBox();
		
		//Handle the data:
		var pieces = splitZenseString(r);
		var result = "";
		for(p in pieces.slice(2)) {
			result += p;
		}
		return result;
	}
	
	private function getOutletWNow(outletId:String) : Int {
		Sys.sleep(mConfig.sleepTime);
		
		connectToBox();
		var r = writeZenseString(">>WNow " + StringTools.trim(outletId) + "<<");
		disconnectFromBox();
		
		var pieces = splitZenseString(r);
		var result = "";
		for(p in pieces.slice(1)) {
			result += p;
		}
		var w:Null<Int> = Std.parseInt(result);
		return w!=null ? w : -1;
	}
	
	//-------------------------------------------------------
	
	
	//Gets the outlet layout of the house.
	private function getLayoutData() : Array<LayoutData> {
		var rv = new Array<LayoutData>();
		
		var data:LayoutData = null;
		
		var ids = getOutletIds();
		ids == null ? return [] : 0;
		for(id in ids) {
			data = new LayoutData();
			data.outletId = id;
			data.name = getOutletProperty(id, "Name");
			data.room = getOutletProperty(id, "Room");
			data.floor = getOutletProperty(id, "Floor");
			
			rv.push(data);
		}
		
		return rv;
	}
	
	
	
}



